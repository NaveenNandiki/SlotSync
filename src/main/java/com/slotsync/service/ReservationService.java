package com.slotsync.service;

import com.slotsync.dao.ReservationDAO;
import com.slotsync.dao.ReservationStatusHistoryDAO;
import com.slotsync.dao.ResourceDAO;
import com.slotsync.exception.BookingConflictException;
import com.slotsync.exception.InvalidReservationException;
import com.slotsync.exception.ResourceNotFoundException;
import com.slotsync.model.Reservation;
import com.slotsync.model.ReservationStatusHistory;
import com.slotsync.model.Resource;
import com.slotsync.util.DBConnection;
import com.slotsync.util.ValidationUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Core business service for transactional reservation management and concurrency conflict prevention.
 */
public class ReservationService {

    private static final Logger LOGGER = Logger.getLogger(ReservationService.class.getName());

    private final ReservationDAO reservationDAO;
    private final ResourceDAO resourceDAO;
    private final ReservationStatusHistoryDAO historyDAO;

    public ReservationService() {
        this.reservationDAO = new ReservationDAO();
        this.resourceDAO = new ResourceDAO();
        this.historyDAO = new ReservationStatusHistoryDAO();
    }

    public ReservationService(ReservationDAO reservationDAO, ResourceDAO resourceDAO, ReservationStatusHistoryDAO historyDAO) {
        this.reservationDAO = reservationDAO;
        this.resourceDAO = resourceDAO;
        this.historyDAO = historyDAO;
    }

    /**
     * Creates a new reservation within an ACID transaction with pessimistic locking.
     * Prevents double booking by locking the resource row and checking overlaps atomically.
     */
    public Reservation createReservation(long userId, long resourceId, LocalDateTime start, LocalDateTime end, String purpose)
            throws BookingConflictException, ResourceNotFoundException, InvalidReservationException, SQLException {

        Connection conn = null;
        try {
            // 1. Basic validation
            if (start == null || end == null) {
                throw new InvalidReservationException("Reservation start and end times are required.");
            }
            if (!end.isAfter(start)) {
                throw new InvalidReservationException("Reservation end time must be strictly after the start time.");
            }
            if (start.isBefore(LocalDateTime.now().minusMinutes(5))) {
                throw new InvalidReservationException("Cannot create reservations in the past.");
            }
            if (!ValidationUtil.isNotBlank(purpose)) {
                throw new InvalidReservationException("Please specify a purpose for the reservation.");
            }

            // 2. Obtain connection and disable auto-commit
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 3. Pessimistic lock on resource row
            Resource resource = resourceDAO.findByIdForUpdate(conn, resourceId);
            if (resource == null) {
                throw new ResourceNotFoundException("Resource with ID " + resourceId + " does not exist.");
            }
            if (!resource.isActive()) {
                throw new ResourceNotFoundException("Resource '" + resource.getName() + "' is currently deactivated.");
            }

            // 4. Overlap check within the transaction
            // Condition: existing.start_time < requested.end_time AND existing.end_time > requested.start_time
            List<Reservation> conflicts = reservationDAO.findOverlappingReservations(conn, resourceId, start, end, null);
            if (!conflicts.isEmpty()) {
                Reservation conflict = conflicts.get(0);
                String conflictMsg = String.format(
                    "Time conflict: Resource '%s' is already booked/requested from %s to %s (Status: %s).",
                    resource.getName(),
                    ValidationUtil.formatDisplay(conflict.getStartTime()),
                    ValidationUtil.formatDisplay(conflict.getEndTime()),
                    conflict.getStatus()
                );
                throw new BookingConflictException(conflictMsg);
            }

            // 5. Insert new reservation
            Reservation reservation = new Reservation();
            reservation.setUserId(userId);
            reservation.setResourceId(resourceId);
            reservation.setStartTime(start);
            reservation.setEndTime(end);
            reservation.setPurpose(purpose.trim());
            reservation.setStatus(Reservation.STATUS_PENDING);
            reservation.setCreatedAt(LocalDateTime.now());
            reservation.setUpdatedAt(LocalDateTime.now());

            boolean created = reservationDAO.create(conn, reservation);
            if (!created) {
                throw new SQLException("Failed to insert reservation into the database.");
            }

            // 6. Record initial audit history
            ReservationStatusHistory history = new ReservationStatusHistory();
            history.setReservationId(reservation.getReservationId());
            history.setChangedBy(userId);
            history.setOldStatus(null);
            history.setNewStatus(Reservation.STATUS_PENDING);
            history.setReason("Initial reservation request submitted.");
            history.setChangedAt(LocalDateTime.now());

            historyDAO.create(conn, history);

            // 7. Commit transaction
            conn.commit();
            return reservation;

        } catch (SQLException | BookingConflictException | ResourceNotFoundException | InvalidReservationException e) {
            DBConnection.rollback(conn);
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Approves a pending reservation within a transaction.
     * Re-locks the resource and re-checks for conflicts before committing.
     */
    public boolean approveReservation(long reservationId, long adminId, String reason)
            throws ResourceNotFoundException, BookingConflictException, InvalidReservationException, SQLException {

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            Reservation reservation = reservationDAO.findById(conn, reservationId);
            if (reservation == null) {
                throw new InvalidReservationException("Reservation with ID " + reservationId + " not found.");
            }

            if (!Reservation.STATUS_PENDING.equals(reservation.getStatus())) {
                throw new InvalidReservationException("Only PENDING reservations can be approved. Current status: " + reservation.getStatus());
            }

            // Lock the resource
            Resource resource = resourceDAO.findByIdForUpdate(conn, reservation.getResourceId());
            if (resource == null || !resource.isActive()) {
                throw new ResourceNotFoundException("Resource associated with this reservation is inactive or not found.");
            }

            // Re-verify no other APPROVED reservation overlaps
            List<Reservation> conflicts = reservationDAO.findOverlappingReservations(
                conn, reservation.getResourceId(), reservation.getStartTime(), reservation.getEndTime(), reservationId
            );

            for (Reservation c : conflicts) {
                if (Reservation.STATUS_APPROVED.equals(c.getStatus())) {
                    throw new BookingConflictException(
                        "Cannot approve: An approved reservation already exists for this slot (" +
                        ValidationUtil.formatDisplay(c.getStartTime()) + " - " + ValidationUtil.formatDisplay(c.getEndTime()) + ")."
                    );
                }
            }

            String oldStatus = reservation.getStatus();
            String reviewNote = ValidationUtil.isNotBlank(reason) ? reason.trim() : "Approved by administrator.";

            reservationDAO.updateStatus(conn, reservationId, Reservation.STATUS_APPROVED, adminId, reviewNote);

            // Audit history
            ReservationStatusHistory history = new ReservationStatusHistory();
            history.setReservationId(reservationId);
            history.setChangedBy(adminId);
            history.setOldStatus(oldStatus);
            history.setNewStatus(Reservation.STATUS_APPROVED);
            history.setReason(reviewNote);
            history.setChangedAt(LocalDateTime.now());
            historyDAO.create(conn, history);

            conn.commit();
            return true;

        } catch (SQLException | BookingConflictException | ResourceNotFoundException | InvalidReservationException e) {
            DBConnection.rollback(conn);
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Rejects a reservation with a mandatory reason.
     */
    public boolean rejectReservation(long reservationId, long adminId, String reason)
            throws InvalidReservationException, SQLException {

        if (!ValidationUtil.isNotBlank(reason)) {
            throw new InvalidReservationException("Rejection reason is mandatory.");
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            Reservation reservation = reservationDAO.findById(conn, reservationId);
            if (reservation == null) {
                throw new InvalidReservationException("Reservation with ID " + reservationId + " not found.");
            }

            if (Reservation.STATUS_REJECTED.equals(reservation.getStatus()) || Reservation.STATUS_CANCELLED.equals(reservation.getStatus())) {
                throw new InvalidReservationException("Reservation is already " + reservation.getStatus() + ".");
            }

            String oldStatus = reservation.getStatus();
            reservationDAO.updateStatus(conn, reservationId, Reservation.STATUS_REJECTED, adminId, reason.trim());

            ReservationStatusHistory history = new ReservationStatusHistory();
            history.setReservationId(reservationId);
            history.setChangedBy(adminId);
            history.setOldStatus(oldStatus);
            history.setNewStatus(Reservation.STATUS_REJECTED);
            history.setReason(reason.trim());
            history.setChangedAt(LocalDateTime.now());
            historyDAO.create(conn, history);

            conn.commit();
            return true;

        } catch (SQLException | InvalidReservationException e) {
            DBConnection.rollback(conn);
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Cancels an eligible reservation.
     * Enforces ownership validation: standard users can only cancel their own reservations.
     */
    public boolean cancelReservation(long reservationId, long currentUserId, boolean isAdmin, String reason)
            throws InvalidReservationException, SQLException {

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            Reservation reservation = reservationDAO.findById(conn, reservationId);
            if (reservation == null) {
                throw new InvalidReservationException("Reservation with ID " + reservationId + " not found.");
            }

            // Verify ownership if not admin
            if (!isAdmin && !reservation.getUserId().equals(currentUserId)) {
                throw new InvalidReservationException("You are not authorized to cancel this reservation.");
            }

            if (!reservation.isCancellable()) {
                throw new InvalidReservationException("This reservation cannot be cancelled (Current status: " + reservation.getStatus() + ").");
            }

            String oldStatus = reservation.getStatus();
            String cancelReason = ValidationUtil.isNotBlank(reason) ? reason.trim() : (isAdmin ? "Cancelled by Administrator" : "Cancelled by User");

            reservationDAO.updateStatus(conn, reservationId, Reservation.STATUS_CANCELLED, isAdmin ? currentUserId : null, cancelReason);

            ReservationStatusHistory history = new ReservationStatusHistory();
            history.setReservationId(reservationId);
            history.setChangedBy(currentUserId);
            history.setOldStatus(oldStatus);
            history.setNewStatus(Reservation.STATUS_CANCELLED);
            history.setReason(cancelReason);
            history.setChangedAt(LocalDateTime.now());
            historyDAO.create(conn, history);

            conn.commit();
            return true;

        } catch (SQLException | InvalidReservationException e) {
            DBConnection.rollback(conn);
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
    }

    public Reservation getReservationById(long reservationId) {
        return reservationDAO.findById(reservationId);
    }

    public List<Reservation> getUserReservations(long userId, String statusFilter) {
        return reservationDAO.findByUserId(userId, statusFilter);
    }

    public List<Reservation> getAllReservations(String statusFilter, Long resourceIdFilter, String searchUser) {
        return reservationDAO.findAll(statusFilter, resourceIdFilter, searchUser);
    }

    public List<ReservationStatusHistory> getReservationHistory(long reservationId) {
        return historyDAO.findByReservationId(reservationId);
    }

    public Map<String, Object> getUserDashboardData(long userId) {
        Map<String, Object> data = new HashMap<>();
        data.put("totalCount", reservationDAO.countTotalForUser(userId));
        data.put("pendingCount", reservationDAO.countByStatusForUser(userId, Reservation.STATUS_PENDING));
        data.put("approvedCount", reservationDAO.countByStatusForUser(userId, Reservation.STATUS_APPROVED));
        data.put("upcomingApprovedCount", reservationDAO.countUpcomingApprovedForUser(userId));
        data.put("rejectedCount", reservationDAO.countByStatusForUser(userId, Reservation.STATUS_REJECTED));
        data.put("cancelledCount", reservationDAO.countByStatusForUser(userId, Reservation.STATUS_CANCELLED));

        data.put("recentReservations", reservationDAO.getRecentReservationsForUser(userId, 5));
        data.put("upcomingApproved", reservationDAO.getUpcomingApprovedForUser(userId, 5));
        return data;
    }

    public Map<String, Object> getAdminDashboardData() {
        Map<String, Object> data = new HashMap<>();
        data.put("activeResourcesCount", resourceDAO.countActiveResources());
        data.put("totalResourcesCount", resourceDAO.countTotalResources());
        data.put("totalReservationsCount", reservationDAO.countTotal());
        data.put("pendingCount", reservationDAO.countByStatus(Reservation.STATUS_PENDING));
        data.put("approvedCount", reservationDAO.countByStatus(Reservation.STATUS_APPROVED));
        data.put("upcomingApprovedCount", reservationDAO.countUpcomingApproved());
        data.put("completedCount", reservationDAO.countByStatus(Reservation.STATUS_COMPLETED));
        data.put("cancelledCount", reservationDAO.countByStatus(Reservation.STATUS_CANCELLED));
        data.put("rejectedCount", reservationDAO.countByStatus(Reservation.STATUS_REJECTED));

        data.put("recentReservations", reservationDAO.getRecentReservations(8));
        data.put("upcomingApproved", reservationDAO.getUpcomingApproved(5));
        return data;
    }
}
