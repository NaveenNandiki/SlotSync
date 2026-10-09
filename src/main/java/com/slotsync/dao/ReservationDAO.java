package com.slotsync.dao;

import com.slotsync.model.Reservation;
import com.slotsync.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Reservation entity and booking conflict queries.
 */
public class ReservationDAO {

    private static final Logger LOGGER = Logger.getLogger(ReservationDAO.class.getName());

    private static final String BASE_SELECT_JOIN = 
        "SELECT res.reservation_id, res.user_id, res.resource_id, res.start_time, res.end_time, " +
        "       res.purpose, res.status, res.reviewed_by, res.review_reason, res.created_at, res.updated_at, " +
        "       u.full_name AS user_name, u.email AS user_email, " +
        "       r.name AS resource_name, r.resource_type, r.location AS resource_location, " +
        "       rev.full_name AS reviewer_name " +
        "FROM reservations res " +
        "JOIN users u ON res.user_id = u.user_id " +
        "JOIN resources r ON res.resource_id = r.resource_id " +
        "LEFT JOIN users rev ON res.reviewed_by = rev.user_id ";

    /**
     * Inserts a reservation using the provided transactional connection.
     */
    public boolean create(Connection conn, Reservation reservation) throws SQLException {
        String sql = "INSERT INTO reservations (user_id, resource_id, start_time, end_time, purpose, status, reviewed_by, review_reason, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, reservation.getUserId());
            ps.setLong(2, reservation.getResourceId());
            ps.setTimestamp(3, Timestamp.valueOf(reservation.getStartTime()));
            ps.setTimestamp(4, Timestamp.valueOf(reservation.getEndTime()));
            ps.setString(5, reservation.getPurpose());
            ps.setString(6, reservation.getStatus() != null ? reservation.getStatus() : Reservation.STATUS_PENDING);

            if (reservation.getReviewedBy() != null) {
                ps.setLong(7, reservation.getReviewedBy());
            } else {
                ps.setNull(7, Types.BIGINT);
            }
            ps.setString(8, reservation.getReviewReason());

            Timestamp now = new Timestamp(System.currentTimeMillis());
            ps.setTimestamp(9, reservation.getCreatedAt() != null ? Timestamp.valueOf(reservation.getCreatedAt()) : now);
            ps.setTimestamp(10, reservation.getUpdatedAt() != null ? Timestamp.valueOf(reservation.getUpdatedAt()) : now);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        reservation.setReservationId(rs.getLong(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public Reservation findById(long reservationId) {
        String sql = BASE_SELECT_JOIN + "WHERE res.reservation_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, reservationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding reservation by id: " + reservationId, e);
        }
        return null;
    }

    public Reservation findById(Connection conn, long reservationId) throws SQLException {
        String sql = BASE_SELECT_JOIN + "WHERE res.reservation_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, reservationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Checks for overlapping reservations for a given resource.
     * Concurrency rule: existing.start_time < requested.end_time AND existing.end_time > requested.start_time
     * Only applies to PENDING and APPROVED reservations.
     */
    public List<Reservation> findOverlappingReservations(Connection conn, long resourceId,
                                                         LocalDateTime start, LocalDateTime end,
                                                         Long excludeReservationId) throws SQLException {
        List<Reservation> conflicts = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT reservation_id, user_id, resource_id, start_time, end_time, purpose, status, reviewed_by, review_reason, created_at, updated_at ");
        sql.append("FROM reservations ");
        sql.append("WHERE resource_id = ? ");
        sql.append("  AND status IN ('PENDING', 'APPROVED') ");
        sql.append("  AND start_time < ? ");
        sql.append("  AND end_time > ? ");

        if (excludeReservationId != null) {
            sql.append("  AND reservation_id <> ? ");
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, resourceId);
            ps.setTimestamp(2, Timestamp.valueOf(end));
            ps.setTimestamp(3, Timestamp.valueOf(start));
            if (excludeReservationId != null) {
                ps.setLong(4, excludeReservationId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Reservation r = new Reservation();
                    r.setReservationId(rs.getLong("reservation_id"));
                    r.setUserId(rs.getLong("user_id"));
                    r.setResourceId(rs.getLong("resource_id"));
                    r.setStartTime(rs.getTimestamp("start_time").toLocalDateTime());
                    r.setEndTime(rs.getTimestamp("end_time").toLocalDateTime());
                    r.setPurpose(rs.getString("purpose"));
                    r.setStatus(rs.getString("status"));
                    conflicts.add(r);
                }
            }
        }
        return conflicts;
    }

    public List<Reservation> findByUserId(long userId, String statusFilter) {
        List<Reservation> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT_JOIN);
        sql.append("WHERE res.user_id = ? ");

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND res.status = ? ");
        }
        sql.append("ORDER BY res.start_time DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setLong(1, userId);
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
                ps.setString(2, statusFilter.trim().toUpperCase());
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching reservations for user: " + userId, e);
        }
        return list;
    }

    public List<Reservation> findAll(String statusFilter, Long resourceIdFilter, String searchUser) {
        List<Reservation> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT_JOIN);
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter.trim())) {
            sql.append("AND res.status = ? ");
            params.add(statusFilter.trim().toUpperCase());
        }
        if (resourceIdFilter != null && resourceIdFilter > 0) {
            sql.append("AND res.resource_id = ? ");
            params.add(resourceIdFilter);
        }
        if (searchUser != null && !searchUser.trim().isEmpty()) {
            sql.append("AND (u.full_name LIKE ? OR u.email LIKE ? OR res.purpose LIKE ?) ");
            String q = "%" + searchUser.trim() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
        }
        sql.append("ORDER BY res.start_time DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error listing all reservations", e);
        }
        return list;
    }

    public boolean updateStatus(Connection conn, long reservationId, String newStatus, Long reviewedBy, String reviewReason) throws SQLException {
        String sql = "UPDATE reservations SET status = ?, reviewed_by = ?, review_reason = ?, updated_at = NOW() WHERE reservation_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            if (reviewedBy != null) {
                ps.setLong(2, reviewedBy);
            } else {
                ps.setNull(2, Types.BIGINT);
            }
            ps.setString(3, reviewReason);
            ps.setLong(4, reservationId);
            return ps.executeUpdate() > 0;
        }
    }

    public int countTotalForUser(long userId) {
        String sql = "SELECT COUNT(*) FROM reservations WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting reservations for user: " + userId, e);
        }
        return 0;
    }

    public int countByStatusForUser(long userId, String status) {
        String sql = "SELECT COUNT(*) FROM reservations WHERE user_id = ? AND status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting status for user: " + userId, e);
        }
        return 0;
    }

    public int countUpcomingApprovedForUser(long userId) {
        String sql = "SELECT COUNT(*) FROM reservations WHERE user_id = ? AND status = 'APPROVED' AND start_time > NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting upcoming approved for user: " + userId, e);
        }
        return 0;
    }

    public int countTotal() {
        String sql = "SELECT COUNT(*) FROM reservations";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting total reservations", e);
        }
        return 0;
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM reservations WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting reservations by status: " + status, e);
        }
        return 0;
    }

    public int countUpcomingApproved() {
        String sql = "SELECT COUNT(*) FROM reservations WHERE status = 'APPROVED' AND start_time > NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting upcoming approved reservations", e);
        }
        return 0;
    }

    public List<Reservation> getRecentReservationsForUser(long userId, int limit) {
        List<Reservation> list = new ArrayList<>();
        String sql = BASE_SELECT_JOIN + "WHERE res.user_id = ? ORDER BY res.created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching recent reservations for user: " + userId, e);
        }
        return list;
    }

    public List<Reservation> getUpcomingApprovedForUser(long userId, int limit) {
        List<Reservation> list = new ArrayList<>();
        String sql = BASE_SELECT_JOIN + "WHERE res.user_id = ? AND res.status = 'APPROVED' AND res.start_time >= NOW() ORDER BY res.start_time ASC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching upcoming approved for user: " + userId, e);
        }
        return list;
    }

    public List<Reservation> getRecentReservations(int limit) {
        List<Reservation> list = new ArrayList<>();
        String sql = BASE_SELECT_JOIN + "ORDER BY res.created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching recent reservations", e);
        }
        return list;
    }

    public List<Reservation> getUpcomingApproved(int limit) {
        List<Reservation> list = new ArrayList<>();
        String sql = BASE_SELECT_JOIN + "WHERE res.status = 'APPROVED' AND res.start_time >= NOW() ORDER BY res.start_time ASC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching upcoming approved reservations", e);
        }
        return list;
    }

    public List<Map<String, Object>> getResourceUtilizationStats() {
        List<Map<String, Object>> stats = new ArrayList<>();
        String sql = "SELECT r.resource_id, r.name, r.resource_type, " +
                     "       COUNT(res.reservation_id) AS total_bookings, " +
                     "       SUM(CASE WHEN res.status = 'APPROVED' THEN 1 ELSE 0 END) AS approved_bookings, " +
                     "       SUM(CASE WHEN res.status = 'PENDING' THEN 1 ELSE 0 END) AS pending_bookings, " +
                     "       COALESCE(SUM(CASE WHEN res.status IN ('APPROVED', 'COMPLETED') THEN TIMESTAMPDIFF(MINUTE, res.start_time, res.end_time) / 60.0 ELSE 0 END), 0) AS total_hours_booked " +
                     "FROM resources r " +
                     "LEFT JOIN reservations res ON r.resource_id = res.resource_id " +
                     "GROUP BY r.resource_id, r.name, r.resource_type " +
                     "ORDER BY total_bookings DESC, r.name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("resourceId", rs.getLong("resource_id"));
                row.put("name", rs.getString("name"));
                row.put("resourceType", rs.getString("resource_type"));
                row.put("totalBookings", rs.getInt("total_bookings"));
                row.put("approvedBookings", rs.getInt("approved_bookings"));
                row.put("pendingBookings", rs.getInt("pending_bookings"));
                row.put("totalHoursBooked", Math.round(rs.getDouble("total_hours_booked") * 10.0) / 10.0);
                stats.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving resource utilization stats", e);
        }
        return stats;
    }

    public Map<String, Integer> getStatusDistributionStats() {
        Map<String, Integer> map = new HashMap<>();
        map.put("PENDING", 0);
        map.put("APPROVED", 0);
        map.put("REJECTED", 0);
        map.put("CANCELLED", 0);
        map.put("COMPLETED", 0);

        String sql = "SELECT status, COUNT(*) AS cnt FROM reservations GROUP BY status";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving status distribution stats", e);
        }
        return map;
    }

    private Reservation mapRow(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setReservationId(rs.getLong("reservation_id"));
        r.setUserId(rs.getLong("user_id"));
        r.setResourceId(rs.getLong("resource_id"));

        Timestamp st = rs.getTimestamp("start_time");
        if (st != null) r.setStartTime(st.toLocalDateTime());

        Timestamp et = rs.getTimestamp("end_time");
        if (et != null) r.setEndTime(et.toLocalDateTime());

        r.setPurpose(rs.getString("purpose"));
        r.setStatus(rs.getString("status"));

        long revBy = rs.getLong("reviewed_by");
        if (!rs.wasNull()) {
            r.setReviewedBy(revBy);
        }
        r.setReviewReason(rs.getString("review_reason"));

        Timestamp ct = rs.getTimestamp("created_at");
        if (ct != null) r.setCreatedAt(ct.toLocalDateTime());

        Timestamp ut = rs.getTimestamp("updated_at");
        if (ut != null) r.setUpdatedAt(ut.toLocalDateTime());

        // Joined columns if available
        try {
            r.setUserName(rs.getString("user_name"));
            r.setUserEmail(rs.getString("user_email"));
            r.setResourceName(rs.getString("resource_name"));
            r.setResourceType(rs.getString("resource_type"));
            r.setResourceLocation(rs.getString("resource_location"));
            r.setReviewedByName(rs.getString("reviewer_name"));
        } catch (SQLException ignored) {
            // Columns not in single-table query
        }

        return r;
    }
}
