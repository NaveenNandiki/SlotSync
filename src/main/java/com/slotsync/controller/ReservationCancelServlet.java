package com.slotsync.controller;

import com.slotsync.exception.InvalidReservationException;
import com.slotsync.model.User;
import com.slotsync.service.ReservationService;
import com.slotsync.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller handling reservation cancellation requests from users and administrators.
 */
@WebServlet(name = "ReservationCancelServlet", urlPatterns = {"/reservations/cancel"})
public class ReservationCancelServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ReservationService reservationService;

    @Override
    public void init() throws ServletException {
        this.reservationService = new ReservationService();
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

        long reservationId = ValidationUtil.parseLong(request.getParameter("reservationId"), 0);
        String reason = request.getParameter("reason");
        String returnTo = request.getParameter("returnTo");

        if (reservationId <= 0) {
            session.setAttribute("errorMessage", "Invalid reservation specified for cancellation.");
            redirectBack(request, response, returnTo, currentUser);
            return;
        }

        try {
            reservationService.cancelReservation(
                reservationId, currentUser.getUserId(), currentUser.isAdmin(), reason
            );
            session.setAttribute("successMessage", "Reservation #" + reservationId + " has been cancelled.");
        } catch (InvalidReservationException e) {
            session.setAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("errorMessage", "An error occurred while attempting to cancel the reservation.");
        }

        redirectBack(request, response, returnTo, currentUser);
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, String returnTo, User currentUser)
            throws IOException {
        if ("admin".equalsIgnoreCase(returnTo) && currentUser.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
        } else {
            response.sendRedirect(request.getContextPath() + "/my-reservations");
        }
    }
}
