package com.slotsync.controller;

import com.slotsync.exception.BookingConflictException;
import com.slotsync.exception.InvalidReservationException;
import com.slotsync.exception.ResourceNotFoundException;
import com.slotsync.model.Reservation;
import com.slotsync.model.Resource;
import com.slotsync.model.User;
import com.slotsync.service.ReservationService;
import com.slotsync.service.ResourceService;
import com.slotsync.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Controller managing reservation creation and booking form submissions.
 */
@WebServlet(name = "ReservationCreateServlet", urlPatterns = {"/reservations/new", "/reservations/create"})
public class ReservationCreateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ReservationCreateServlet.class.getName());

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

        long resourceId = ValidationUtil.parseLong(request.getParameter("resourceId"), 0);
        String startStr = request.getParameter("start");
        String endStr = request.getParameter("end");

        if (resourceId > 0) {
            try {
                Resource resource = resourceService.getResourceById(resourceId);
                request.setAttribute("selectedResource", resource);
            } catch (ResourceNotFoundException ignored) {}
        }

        List<Resource> activeResources = resourceService.getAllResources(true);
        request.setAttribute("resources", activeResources);
        request.setAttribute("startVal", startStr);
        request.setAttribute("endVal", endStr);

        request.getRequestDispatcher("/WEB-INF/views/resources/booking-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        long resourceId = ValidationUtil.parseLong(request.getParameter("resourceId"), 0);
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");
        String purpose = request.getParameter("purpose");

        LocalDateTime startTime = ValidationUtil.parseDateTime(startTimeStr);
        LocalDateTime endTime = ValidationUtil.parseDateTime(endTimeStr);

        try {
            if (resourceId <= 0) {
                throw new InvalidReservationException("Please select a resource to reserve.");
            }
            if (startTime == null || endTime == null) {
                throw new InvalidReservationException("Please provide valid start and end dates/times.");
            }

            Reservation reservation = reservationService.createReservation(
                currentUser.getUserId(), resourceId, startTime, endTime, purpose
            );

            session.setAttribute("successMessage", "Reservation request #" + reservation.getReservationId() + " submitted successfully! Your booking is currently PENDING approval.");
            response.sendRedirect(request.getContextPath() + "/my-reservations");

        } catch (BookingConflictException e) {
            LOGGER.log(Level.WARNING, "Booking conflict detected: {0}", e.getMessage());
            request.setAttribute("errorMessage", e.getMessage());
            populateFormAndForward(request, response, resourceId, startTimeStr, endTimeStr, purpose);
        } catch (InvalidReservationException | ResourceNotFoundException e) {
            request.setAttribute("errorMessage", e.getMessage());
            populateFormAndForward(request, response, resourceId, startTimeStr, endTimeStr, purpose);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error creating reservation", e);
            request.setAttribute("errorMessage", "A database or system error occurred while processing your reservation. Please try again.");
            populateFormAndForward(request, response, resourceId, startTimeStr, endTimeStr, purpose);
        }
    }

    private void populateFormAndForward(HttpServletRequest request, HttpServletResponse response,
                                        long resourceId, String startTimeStr, String endTimeStr, String purpose)
            throws ServletException, IOException {
        List<Resource> activeResources = resourceService.getAllResources(true);
        request.setAttribute("resources", activeResources);
        request.setAttribute("resourceId", resourceId);
        request.setAttribute("startVal", startTimeStr);
        request.setAttribute("endVal", endTimeStr);
        request.setAttribute("purpose", purpose);

        if (resourceId > 0) {
            try {
                Resource resource = resourceService.getResourceById(resourceId);
                request.setAttribute("selectedResource", resource);
            } catch (ResourceNotFoundException ignored) {}
        }

        request.getRequestDispatcher("/WEB-INF/views/resources/booking-form.jsp").forward(request, response);
    }
}
