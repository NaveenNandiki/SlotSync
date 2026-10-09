package com.slotsync.controller;

import com.slotsync.exception.BookingConflictException;
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
 * Controller processing administrator reservation reviews (approvals and rejections).
 */
@WebServlet(name = "ReservationReviewServlet", urlPatterns = {"/admin/reservations/review"})
public class ReservationReviewServlet extends HttpServlet {
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

        if (currentUser == null || !currentUser.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Administrator access required.");
            return;
        }

        long reservationId = ValidationUtil.parseLong(request.getParameter("reservationId"), 0);
        String action = request.getParameter("action");
        String reason = request.getParameter("reason");

        if (reservationId <= 0 || !ValidationUtil.isNotBlank(action)) {
            session.setAttribute("errorMessage", "Invalid review request parameters.");
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
            return;
        }

        try {
            if ("APPROVE".equalsIgnoreCase(action.trim())) {
                reservationService.approveReservation(reservationId, currentUser.getUserId(), reason);
                session.setAttribute("successMessage", "Reservation #" + reservationId + " has been APPROVED.");
            } else if ("REJECT".equalsIgnoreCase(action.trim())) {
                if (!ValidationUtil.isNotBlank(reason)) {
                    session.setAttribute("errorMessage", "A reason is mandatory when rejecting a reservation.");
                    response.sendRedirect(request.getContextPath() + "/admin/reservations");
                    return;
                }
                reservationService.rejectReservation(reservationId, currentUser.getUserId(), reason);
                session.setAttribute("successMessage", "Reservation #" + reservationId + " has been REJECTED.");
            } else {
                session.setAttribute("errorMessage", "Unknown review action: " + action);
            }
        } catch (BookingConflictException e) {
            session.setAttribute("errorMessage", e.getMessage());
        } catch (InvalidReservationException e) {
            session.setAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            session.setAttribute("errorMessage", "An error occurred while updating the reservation status: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/reservations");
    }
}
