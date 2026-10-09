<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.User" %>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String currentPath = request.getServletPath();
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null || pageTitle.isEmpty()) {
        pageTitle = "SlotSync — Resource Booking & Reservation System";
    }
    String csrfToken = (String) request.getAttribute("csrfToken");
    if (csrfToken == null) {
        csrfToken = (String) session.getAttribute("csrfToken");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= ValidationUtil.escapeHtml(pageTitle) %></title>
    <meta name="description" content="SlotSync - High Performance Enterprise Resource Booking and Reservation Management System">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<% if (currentUser != null) { %>
    <!-- Authenticated App Shell -->
    <div class="app-layout">
        <!-- Sidebar Navigation -->
        <aside class="app-sidebar" id="appSidebar">
            <div class="sidebar-brand">
                <div class="brand-icon">S</div>
                <div class="brand-text">SlotSync</div>
                <span class="brand-badge"><%= currentUser.isAdmin() ? "ADMIN" : "PORTAL" %></span>
            </div>

            <nav class="sidebar-nav">
                <div class="nav-section-title">Main Menu</div>
                
                <a href="${pageContext.request.contextPath}/dashboard" class="nav-link <%= "/dashboard".equals(currentPath) ? "active" : "" %>">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
                    <span>Dashboard</span>
                </a>

                <a href="${pageContext.request.contextPath}/resources" class="nav-link <%= "/resources".equals(currentPath) && !currentPath.contains("admin") ? "active" : "" %>">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="m21 16-4 4-4-4"></path><path d="M17 20V4"></path><path d="m3 8 4-4 4 4"></path><path d="M7 4v16"></path></svg>
                    <span>Browse Resources</span>
                </a>

                <a href="${pageContext.request.contextPath}/reservations/new" class="nav-link <%= "/reservations/new".equals(currentPath) ? "active" : "" %>">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>
                    <span>New Reservation</span>
                </a>

                <a href="${pageContext.request.contextPath}/my-reservations" class="nav-link <%= "/my-reservations".equals(currentPath) ? "active" : "" %>">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                    <span>My Reservations</span>
                </a>

                <% if (currentUser.isAdmin()) { %>
                    <div class="nav-section-title" style="margin-top: 1rem;">Administration</div>

                    <a href="${pageContext.request.contextPath}/admin/resources" class="nav-link <%= currentPath.startsWith("/admin/resources") ? "active" : "" %>">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
                        <span>Resource Inventory</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/reservations" class="nav-link <%= "/admin/reservations".equals(currentPath) ? "active" : "" %>">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        <span>Manage Requests</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/reports" class="nav-link <%= "/admin/reports".equals(currentPath) ? "active" : "" %>">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
                        <span>Analytics & Reports</span>
                    </a>
                <% } %>
            </nav>

            <div class="sidebar-footer">
                <div class="user-card">
                    <div class="user-avatar">
                        <%= currentUser.getFullName() != null && !currentUser.getFullName().isEmpty() ? currentUser.getFullName().substring(0, 1).toUpperCase() : "U" %>
                    </div>
                    <div class="user-meta">
                        <div class="user-name"><%= ValidationUtil.escapeHtml(currentUser.getFullName()) %></div>
                        <span class="user-role-badge <%= currentUser.isAdmin() ? "admin" : "" %>"><%= currentUser.getRole() %></span>
                    </div>
                </div>
            </div>
        </aside>

        <!-- Main Content Wrapper -->
        <div class="app-main">
            <!-- Topbar Header -->
            <header class="app-topbar">
                <div style="display: flex; align-items: center; gap: 1rem;">
                    <button class="mobile-menu-btn" id="mobileMenuBtn" aria-label="Toggle Sidebar">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
                    </button>
                    <div class="topbar-title"><%= ValidationUtil.escapeHtml(pageTitle) %></div>
                </div>

                <div class="topbar-actions">
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display: inline;">
                        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                        <button type="submit" class="btn btn-secondary btn-sm" title="Sign out of SlotSync">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
                            <span>Sign Out</span>
                        </button>
                    </form>
                </div>
            </header>

            <main class="page-container">
                <jsp:include page="/WEB-INF/views/common/messages.jsp" />
<% } else { %>
    <!-- Public Navbar -->
    <nav class="public-navbar">
        <a href="${pageContext.request.contextPath}/" style="display: flex; align-items: center; gap: 0.75rem;">
            <div class="brand-icon">S</div>
            <div class="brand-text">SlotSync</div>
        </a>

        <div class="public-nav-links">
            <a href="${pageContext.request.contextPath}/resources" class="btn btn-secondary btn-sm">Explore Catalog</a>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-secondary btn-sm">Sign In</a>
            <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-sm">Get Started</a>
        </div>
    </nav>
    
    <div style="flex: 1; display: flex; flex-direction: column;">
        <jsp:include page="/WEB-INF/views/common/messages.jsp" />
<% } %>
