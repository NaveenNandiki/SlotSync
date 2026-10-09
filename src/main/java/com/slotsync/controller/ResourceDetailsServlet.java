package com.slotsync.controller;

import com.slotsync.exception.ResourceNotFoundException;
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
 * Controller displaying detailed information and schedule for a specific resource.
 */
@WebServlet(name = "ResourceDetailsServlet", urlPatterns = {"/resources/details"})
public class ResourceDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ResourceService resourceService;
    private ReservationService reservationService;

    @Override
    public void init() throws ServletException {
        this.resourceService = new ResourceService();
        this.reservationService = new ReservationService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        long resourceId = ValidationUtil.parseLong(request.getParameter("id"), 0);
        if (resourceId <= 0) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Missing or invalid resource ID.");
            return;
        }

        try {
            Resource resource = resourceService.getResourceById(resourceId);
            request.setAttribute("resource", resource);

            // Fetch upcoming reservations for this resource
            List<Reservation> resourceReservations = reservationService.getAllReservations(null, resourceId, null);
            request.setAttribute("reservations", resourceReservations);

            request.getRequestDispatcher("/WEB-INF/views/resources/details.jsp").forward(request, response);
        } catch (ResourceNotFoundException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }
}
