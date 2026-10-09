package com.slotsync.service;

import com.slotsync.dao.ReservationDAO;
import com.slotsync.dao.ResourceDAO;
import com.slotsync.dao.UserDAO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service providing statistical reports and analytics for administrators.
 */
public class AdminReportService {

    private final ReservationDAO reservationDAO;
    private final ResourceDAO resourceDAO;
    private final UserDAO userDAO;

    public AdminReportService() {
        this.reservationDAO = new ReservationDAO();
        this.resourceDAO = new ResourceDAO();
        this.userDAO = new UserDAO();
    }

    public AdminReportService(ReservationDAO reservationDAO, ResourceDAO resourceDAO, UserDAO userDAO) {
        this.reservationDAO = reservationDAO;
        this.resourceDAO = resourceDAO;
        this.userDAO = userDAO;
    }

    public Map<String, Object> getOverallSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalUsers", userDAO.countUsers());
        summary.put("totalResources", resourceDAO.countTotalResources());
        summary.put("activeResources", resourceDAO.countActiveResources());
        summary.put("totalReservations", reservationDAO.countTotal());
        summary.put("statusDistribution", reservationDAO.getStatusDistributionStats());
        summary.put("resourceUtilization", reservationDAO.getResourceUtilizationStats());
        return summary;
    }

    public List<Map<String, Object>> getResourceUtilization() {
        return reservationDAO.getResourceUtilizationStats();
    }

    public Map<String, Integer> getStatusDistribution() {
        return reservationDAO.getStatusDistributionStats();
    }
}
