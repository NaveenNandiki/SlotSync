package com.slotsync.controller;

import com.slotsync.model.Reservation;
import com.slotsync.model.User;
import com.slotsync.service.ReservationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller displaying authenticated user's personal reservations and booking history.
 */
@WebServlet(name = "MyReservationsServlet", urlPatterns = {"/my-reservations"})
public class MyReservationsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ReservationService reservationService;

    @Override
    public void init() throws ServletException {
        this.reservationService = new ReservationService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String statusFilter = request.getParameter("status");
        List<Reservation> reservations = reservationService.getUserReservations(currentUser.getUserId(), statusFilter);

        request.setAttribute("reservations", reservations);
        request.setAttribute("selectedStatus", statusFilter);

        request.getRequestDispatcher("/WEB-INF/views/user/my-reservations.jsp").forward(request, response);
    }
}
