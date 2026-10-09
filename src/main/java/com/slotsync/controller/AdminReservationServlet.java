package com.slotsync.controller;

import com.slotsync.model.Reservation;
import com.slotsync.model.Resource;
import com.slotsync.service.ReservationService;
import com.slotsync.service.ResourceService;
import com.slotsync.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Controller displaying administrator reservation management console with filters and review queues.
 */
@WebServlet(name = "AdminReservationServlet", urlPatterns = {"/admin/reservations"})
public class AdminReservationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ReservationService reservationService;
    private ResourceService resourceService;

    @Override
    public void init() throws ServletException {
        this.reservationService = new ReservationService();
        this.resourceService = new ResourceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String statusFilter = request.getParameter("status");
        long resourceIdFilter = ValidationUtil.parseLong(request.getParameter("resourceId"), 0);
        String searchQuery = request.getParameter("search");

        List<Reservation> reservations = reservationService.getAllReservations(
            statusFilter,
            resourceIdFilter > 0 ? resourceIdFilter : null,
            searchQuery
        );

        List<Resource> allResources = resourceService.getAllResources(false);

        request.setAttribute("reservations", reservations);
        request.setAttribute("resources", allResources);
        request.setAttribute("selectedStatus", statusFilter);
        request.setAttribute("selectedResourceId", resourceIdFilter);
        request.setAttribute("searchQuery", searchQuery);

        request.getRequestDispatcher("/WEB-INF/views/admin/reservations.jsp").forward(request, response);
    }
}
