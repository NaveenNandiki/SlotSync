package com.slotsync.filter;

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
import java.security.SecureRandom;
import java.util.Base64;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Filter providing Cross-Site Request Forgery (CSRF) protection.
 * Ensures state-changing POST requests submit a valid CSRF token.
 */
@WebFilter(filterName = "CsrfFilter", urlPatterns = {"/*"})
public class CsrfFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(CsrfFilter.class.getName());
    public static final String CSRF_SESSION_ATTR = "csrfToken";
    public static final String CSRF_PARAM_NAME = "_csrf";
    public static final String CSRF_HEADER_NAME = "X-CSRF-Token";

    private final SecureRandom random = new SecureRandom();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Skip static asset requests from CSRF validation
        String path = httpRequest.getRequestURI();
        if (path.contains("/assets/")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(true);
        String sessionToken = (String) session.getAttribute(CSRF_SESSION_ATTR);

        if (sessionToken == null) {
            byte[] bytes = new byte[24];
            random.nextBytes(bytes);
            sessionToken = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(CSRF_SESSION_ATTR, sessionToken);
        }

        // Always make token available to JSP view layer
        httpRequest.setAttribute(CSRF_SESSION_ATTR, sessionToken);

        // Validate on state-modifying POST requests
        if ("POST".equalsIgnoreCase(httpRequest.getMethod())) {
            String requestToken = httpRequest.getParameter(CSRF_PARAM_NAME);
            if (requestToken == null || requestToken.isEmpty()) {
                requestToken = httpRequest.getHeader(CSRF_HEADER_NAME);
            }

            if (requestToken == null || !sessionToken.equals(requestToken)) {
                LOGGER.log(Level.WARNING, "CSRF validation failed for request: {0}", path);
                httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
                httpRequest.setAttribute("errorMessage", "Security validation error: Invalid or missing CSRF token. Please refresh and try again.");
                httpRequest.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(request, response);
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
