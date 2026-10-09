package com.slotsync.dao;

import com.slotsync.model.ReservationStatusHistory;
import com.slotsync.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for ReservationStatusHistory entity.
 */
public class ReservationStatusHistoryDAO {

    private static final Logger LOGGER = Logger.getLogger(ReservationStatusHistoryDAO.class.getName());

    public boolean create(Connection conn, ReservationStatusHistory history) throws SQLException {
        String sql = "INSERT INTO reservation_status_history (reservation_id, changed_by, old_status, new_status, reason, changed_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, history.getReservationId());
            ps.setLong(2, history.getChangedBy());
            ps.setString(3, history.getOldStatus());
            ps.setString(4, history.getNewStatus());
            ps.setString(5, history.getReason());
            ps.setTimestamp(6, history.getChangedAt() != null ? Timestamp.valueOf(history.getChangedAt()) : new Timestamp(System.currentTimeMillis()));

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        history.setHistoryId(rs.getLong(1));
                    }
                }
                return true;
            }
        }
        return false;
    }

    public List<ReservationStatusHistory> findByReservationId(long reservationId) {
        List<ReservationStatusHistory> list = new ArrayList<>();
        String sql = "SELECT h.history_id, h.reservation_id, h.changed_by, h.old_status, h.new_status, h.reason, h.changed_at, " +
                     "       u.full_name AS changed_by_name " +
                     "FROM reservation_status_history h " +
                     "JOIN users u ON h.changed_by = u.user_id " +
                     "WHERE h.reservation_id = ? " +
                     "ORDER BY h.changed_at ASC, h.history_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, reservationId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReservationStatusHistory h = new ReservationStatusHistory();
                    h.setHistoryId(rs.getLong("history_id"));
                    h.setReservationId(rs.getLong("reservation_id"));
                    h.setChangedBy(rs.getLong("changed_by"));
                    h.setOldStatus(rs.getString("old_status"));
                    h.setNewStatus(rs.getString("new_status"));
                    h.setReason(rs.getString("reason"));
                    Timestamp ts = rs.getTimestamp("changed_at");
                    if (ts != null) {
                        h.setChangedAt(ts.toLocalDateTime());
                    }
                    h.setChangedByName(rs.getString("changed_by_name"));
                    list.add(h);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching reservation history for: " + reservationId, e);
        }
        return list;
    }
}
