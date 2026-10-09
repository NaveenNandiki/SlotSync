package com.slotsync.controller;

import com.slotsync.model.User;
import com.slotsync.service.UserService;
import com.slotsync.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Controller handling user authentication and session establishment.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserService userService;

    @Override
    public void init() throws ServletException {
        this.userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        if (request.getParameter("logout") != null) {
            request.setAttribute("successMessage", "You have been logged out successfully.");
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (!ValidationUtil.isNotBlank(email) || !ValidationUtil.isNotBlank(password)) {
            request.setAttribute("errorMessage", "Please provide both your email and password.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        User user = userService.authenticate(email, password);

        if (user == null) {
            request.setAttribute("errorMessage", "Invalid email address or password. Please try again.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        // Rotate session ID to protect against session fixation attacks
        request.changeSessionId();
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);

        // Flash welcome message
        session.setAttribute("successMessage", "Welcome back, " + user.getFullName() + "!");

        // Handle redirect to originally requested URL if present
        String redirectUrl = (String) session.getAttribute("redirectUrl");
        if (redirectUrl != null && !redirectUrl.isEmpty()) {
            session.removeAttribute("redirectUrl");
            response.sendRedirect(redirectUrl);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/dashboard");
    }
}
