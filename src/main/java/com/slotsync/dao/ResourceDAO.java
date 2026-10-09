package com.slotsync.dao;

import com.slotsync.model.Resource;
import com.slotsync.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Data Access Object for Resource entity.
 */
public class ResourceDAO {

    private static final Logger LOGGER = Logger.getLogger(ResourceDAO.class.getName());

    public Resource findById(long resourceId) {
        String sql = "SELECT resource_id, name, resource_type, location, capacity, description, active, created_at FROM resources WHERE resource_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, resourceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding resource by id: " + resourceId, e);
        }
        return null;
    }

    public Resource findById(Connection conn, long resourceId) throws SQLException {
        String sql = "SELECT resource_id, name, resource_type, location, capacity, description, active, created_at FROM resources WHERE resource_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, resourceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Locks the resource row for transactional concurrency control using SELECT ... FOR UPDATE.
     */
    public Resource findByIdForUpdate(Connection conn, long resourceId) throws SQLException {
        String sql = "SELECT resource_id, name, resource_type, location, capacity, description, active, created_at FROM resources WHERE resource_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, resourceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<Resource> findAll(boolean activeOnly) {
        List<Resource> list = new ArrayList<>();
        String sql = "SELECT resource_id, name, resource_type, location, capacity, description, active, created_at FROM resources "
                   + (activeOnly ? "WHERE active = TRUE " : "")
                   + "ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error listing all resources", e);
        }
        return list;
    }

    public List<Resource> findWithFilters(String type, String location, String search, Boolean activeOnly) {
        List<Resource> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT resource_id, name, resource_type, location, capacity, description, active, created_at FROM resources WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (activeOnly != null) {
            sql.append("AND active = ? ");
            params.add(activeOnly);
        }
        if (type != null && !type.trim().isEmpty() && !"ALL".equalsIgnoreCase(type.trim())) {
            sql.append("AND resource_type = ? ");
            params.add(type.trim());
        }
        if (location != null && !location.trim().isEmpty() && !"ALL".equalsIgnoreCase(location.trim())) {
            sql.append("AND location LIKE ? ");
            params.add("%" + location.trim() + "%");
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (name LIKE ? OR description LIKE ? OR location LIKE ?) ");
            String q = "%" + search.trim() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
        }
        sql.append("ORDER BY name ASC");

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
            LOGGER.log(Level.SEVERE, "Error filtering resources", e);
        }
        return list;
    }

    /**
     * Search available resources for a specific date/time window.
     * Excludes resources with overlapping PENDING or APPROVED reservations.
     */
    public List<Resource> findAvailableResources(String type, String location, String search, LocalDateTime start, LocalDateTime end) {
        List<Resource> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.resource_id, r.name, r.resource_type, r.location, r.capacity, r.description, r.active, r.created_at ");
        sql.append("FROM resources r ");
        sql.append("WHERE r.active = TRUE ");

        List<Object> params = new ArrayList<>();

        if (type != null && !type.trim().isEmpty() && !"ALL".equalsIgnoreCase(type.trim())) {
            sql.append("AND r.resource_type = ? ");
            params.add(type.trim());
        }
        if (location != null && !location.trim().isEmpty() && !"ALL".equalsIgnoreCase(location.trim())) {
            sql.append("AND r.location LIKE ? ");
            params.add("%" + location.trim() + "%");
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (r.name LIKE ? OR r.description LIKE ? OR r.location LIKE ?) ");
            String q = "%" + search.trim() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
        }

        if (start != null && end != null) {
            sql.append("AND NOT EXISTS ( ");
            sql.append("  SELECT 1 FROM reservations res ");
            sql.append("  WHERE res.resource_id = r.resource_id ");
            sql.append("    AND res.status IN ('PENDING', 'APPROVED') ");
            sql.append("    AND res.start_time < ? ");
            sql.append("    AND res.end_time > ? ");
            sql.append(") ");
            params.add(Timestamp.valueOf(end));
            params.add(Timestamp.valueOf(start));
        }

        sql.append("ORDER BY r.name ASC");

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
            LOGGER.log(Level.SEVERE, "Error finding available resources", e);
        }
        return list;
    }

    public boolean create(Resource resource) {
        String sql = "INSERT INTO resources (name, resource_type, location, capacity, description, active, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, resource.getName().trim());
            ps.setString(2, resource.getResourceType().trim());
            ps.setString(3, resource.getLocation().trim());
            ps.setInt(4, resource.getCapacity());
            ps.setString(5, resource.getDescription());
            ps.setBoolean(6, resource.isActive());
            ps.setTimestamp(7, resource.getCreatedAt() != null ? Timestamp.valueOf(resource.getCreatedAt()) : new Timestamp(System.currentTimeMillis()));

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        resource.setResourceId(rs.getLong(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating resource: " + resource.getName(), e);
        }
        return false;
    }

    public boolean update(Resource resource) {
        String sql = "UPDATE resources SET name = ?, resource_type = ?, location = ?, capacity = ?, description = ?, active = ? WHERE resource_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, resource.getName().trim());
            ps.setString(2, resource.getResourceType().trim());
            ps.setString(3, resource.getLocation().trim());
            ps.setInt(4, resource.getCapacity());
            ps.setString(5, resource.getDescription());
            ps.setBoolean(6, resource.isActive());
            ps.setLong(7, resource.getResourceId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating resource: " + resource.getResourceId(), e);
        }
        return false;
    }

    public boolean setActive(long resourceId, boolean active) {
        String sql = "UPDATE resources SET active = ? WHERE resource_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setLong(2, resourceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error toggling active status for resource: " + resourceId, e);
        }
        return false;
    }

    public List<String> getDistinctTypes() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT resource_type FROM resources ORDER BY resource_type ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString(1));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching distinct resource types", e);
        }
        return list;
    }

    public int countActiveResources() {
        String sql = "SELECT COUNT(*) FROM resources WHERE active = TRUE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting active resources", e);
        }
        return 0;
    }

    public int countTotalResources() {
        String sql = "SELECT COUNT(*) FROM resources";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting total resources", e);
        }
        return 0;
    }

    private Resource mapRow(ResultSet rs) throws SQLException {
        Resource r = new Resource();
        r.setResourceId(rs.getLong("resource_id"));
        r.setName(rs.getString("name"));
        r.setResourceType(rs.getString("resource_type"));
        r.setLocation(rs.getString("location"));
        r.setCapacity(rs.getInt("capacity"));
        r.setDescription(rs.getString("description"));
        r.setActive(rs.getBoolean("active"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            r.setCreatedAt(ts.toLocalDateTime());
        }
        return r;
    }
}
