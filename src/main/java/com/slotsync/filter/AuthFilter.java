package com.slotsync.filter;

import com.slotsync.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filter protecting routes that require authentication.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {
    "/dashboard",
    "/my-reservations",
    "/reservations/*",
    "/admin/*"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            // Save requested URL for post-login redirect
            String requestUri = httpRequest.getRequestURI();
            String queryString = httpRequest.getQueryString();
            String targetUrl = (queryString != null) ? requestUri + "?" + queryString : requestUri;

            HttpSession newSession = httpRequest.getSession(true);
            newSession.setAttribute("redirectUrl", targetUrl);
            newSession.setAttribute("errorMessage", "Please sign in to access that page.");

            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
