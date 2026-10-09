<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.User" %>
<%@ page import="com.slotsync.model.Reservation" %>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "User Dashboard — SlotSync");
    User user = (User) session.getAttribute("currentUser");

    int totalCount = request.getAttribute("totalCount") != null ? (Integer) request.getAttribute("totalCount") : 0;
    int pendingCount = request.getAttribute("pendingCount") != null ? (Integer) request.getAttribute("pendingCount") : 0;
    int approvedCount = request.getAttribute("approvedCount") != null ? (Integer) request.getAttribute("approvedCount") : 0;
    int upcomingApprovedCount = request.getAttribute("upcomingApprovedCount") != null ? (Integer) request.getAttribute("upcomingApprovedCount") : 0;

    @SuppressWarnings("unchecked")
    List<Reservation> recentReservations = (List<Reservation>) request.getAttribute("recentReservations");
    @SuppressWarnings("unchecked")
    List<Reservation> upcomingApproved = (List<Reservation>) request.getAttribute("upcomingApproved");

    String csrfToken = (String) request.getAttribute("csrfToken");
    if (csrfToken == null) csrfToken = (String) session.getAttribute("csrfToken");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Welcome back, <%= ValidationUtil.escapeHtml(user.getFullName()) %></h1>
        <p class="page-subtitle">Manage your facility bookings, check schedules, and reserve shared resources</p>
    </div>
    <div style="display: flex; gap: 0.75rem;">
        <a href="${pageContext.request.contextPath}/resources" class="btn btn-secondary">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            <span>Search Resources</span>
        </a>
        <a href="${pageContext.request.contextPath}/reservations/new" class="btn btn-primary">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            <span>Book a Slot</span>
        </a>
    </div>
</div>

<!-- Metrics Cards -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-icon indigo">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
        </div>
        <div class="stat-info">
            <div class="stat-label">Total Reservations</div>
            <div class="stat-value"><%= totalCount %></div>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon amber">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
        </div>
        <div class="stat-info">
            <div class="stat-label">Pending Approval</div>
            <div class="stat-value"><%= pendingCount %></div>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon emerald">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        </div>
        <div class="stat-info">
            <div class="stat-label">Upcoming Approved</div>
            <div class="stat-value"><%= upcomingApprovedCount %></div>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon cyan">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
        </div>
        <div class="stat-info">
            <div class="stat-label">All Approved</div>
            <div class="stat-value"><%= approvedCount %></div>
        </div>
    </div>
</div>

<!-- Upcoming Approved Bookings Banner / Section -->
<% if (upcomingApproved != null && !upcomingApproved.isEmpty()) { %>
    <div class="card" style="margin-bottom: 2rem; border-color: rgba(16, 185, 129, 0.3); background: linear-gradient(145deg, var(--bg-surface) 0%, rgba(16, 185, 129, 0.05) 100%);">
        <div class="card-header">
            <div class="card-title" style="color: #34d399;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                <span>Upcoming Confirmed Sessions</span>
            </div>
            <a href="${pageContext.request.contextPath}/my-reservations?status=APPROVED" class="btn btn-secondary btn-sm">View All Confirmed</a>
        </div>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Resource</th>
                        <th>Type & Location</th>
                        <th>Scheduled Time</th>
                        <th>Purpose</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Reservation r : upcomingApproved) { %>
                        <tr>
                            <td>
                                <strong><%= ValidationUtil.escapeHtml(r.getResourceName()) %></strong>
                            </td>
                            <td>
                                <span style="color: var(--accent-cyan); font-weight: 600;"><%= ValidationUtil.escapeHtml(r.getResourceType()) %></span><br>
                                <span style="font-size: 0.8rem; color: var(--text-muted);"><%= ValidationUtil.escapeHtml(r.getResourceLocation()) %></span>
                            </td>
                            <td>
                                <strong><%= ValidationUtil.formatDisplay(r.getStartTime()) %></strong><br>
                                <span style="font-size: 0.8rem; color: var(--text-muted);">to <%= ValidationUtil.formatDisplay(r.getEndTime()) %></span>
                            </td>
                            <td><%= ValidationUtil.escapeHtml(r.getPurpose()) %></td>
                            <td>
                                <button type="button" class="btn btn-outline-danger btn-sm" 
                                        onclick="openCancelModal('<%= r.getReservationId() %>', '<%= ValidationUtil.escapeHtml(r.getResourceName()) %>')">
                                    Cancel
                                </button>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
<% } %>

<!-- Recent Booking Activity -->
<div class="card">
    <div class="card-header">
        <div class="card-title">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
            <span>Recent Booking Activity</span>
        </div>
        <a href="${pageContext.request.contextPath}/my-reservations" class="btn btn-secondary btn-sm">Full History</a>
    </div>

    <% if (recentReservations == null || recentReservations.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-state-icon">
                <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
            </div>
            <h3 class="empty-state-title">No Reservations Yet</h3>
            <p class="empty-state-desc">You haven't requested any resources yet. Explore the campus inventory to book labs, meeting rooms, or equipment.</p>
            <a href="${pageContext.request.contextPath}/resources" class="btn btn-primary">Browse Available Resources</a>
        </div>
    <% } else { %>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Resource</th>
                        <th>Time Window</th>
                        <th>Purpose</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Reservation r : recentReservations) { %>
                        <tr>
                            <td>#<%= r.getReservationId() %></td>
                            <td>
                                <strong><%= ValidationUtil.escapeHtml(r.getResourceName()) %></strong><br>
                                <span style="font-size: 0.775rem; color: var(--text-muted);"><%= ValidationUtil.escapeHtml(r.getResourceLocation()) %></span>
                            </td>
                            <td>
                                <strong><%= ValidationUtil.formatDisplay(r.getStartTime()) %></strong><br>
                                <span style="font-size: 0.775rem; color: var(--text-muted);">to <%= ValidationUtil.formatDisplay(r.getEndTime()) %></span>
                            </td>
                            <td><%= ValidationUtil.escapeHtml(r.getPurpose()) %></td>
                            <td>
                                <% if (r.isPending()) { %>
                                    <span class="badge badge-pending"><span class="badge-dot"></span> PENDING</span>
                                <% } else if (r.isApproved()) { %>
                                    <span class="badge badge-approved"><span class="badge-dot"></span> APPROVED</span>
                                <% } else if (r.isRejected()) { %>
                                    <span class="badge badge-rejected"><span class="badge-dot"></span> REJECTED</span>
                                <% } else if (r.isCancelled()) { %>
                                    <span class="badge badge-cancelled"><span class="badge-dot"></span> CANCELLED</span>
                                <% } else { %>
                                    <span class="badge badge-completed"><span class="badge-dot"></span> COMPLETED</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (r.isCancellable()) { %>
                                    <button type="button" class="btn btn-outline-danger btn-sm" 
                                            onclick="openCancelModal('<%= r.getReservationId() %>', '<%= ValidationUtil.escapeHtml(r.getResourceName()) %>')">
                                        Cancel
                                    </button>
                                <% } else { %>
                                    <span style="font-size: 0.8rem; color: var(--text-subtle);">None</span>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } %>
</div>

<!-- Cancellation Modal Dialog -->
<div class="modal-overlay" id="cancelModal">
    <div class="modal-dialog">
        <form action="${pageContext.request.contextPath}/reservations/cancel" method="post">
            <input type="hidden" name="_csrf" value="<%= csrfToken %>">
            <input type="hidden" name="reservationId" id="cancelReservationId" value="">
            <input type="hidden" name="returnTo" value="dashboard">

            <div class="modal-header">
                <h3 style="font-size: 1.15rem; font-weight: 700; color: #ffffff;">Confirm Reservation Cancellation</h3>
                <button type="button" class="alert-close-btn" onclick="closeModal('cancelModal')">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: var(--text-muted); margin-bottom: 1rem;">
                    Are you sure you want to cancel your booking for <strong id="cancelResourceName" style="color: #ffffff;"></strong>? This will release the allocated slot back to the public pool.
                </p>
                <div class="form-group">
                    <label for="cancelReason" class="form-label">Optional Cancellation Reason:</label>
                    <textarea name="reason" id="cancelReason" class="form-control" rows="2" placeholder="e.g., Session rescheduled, no longer required..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('cancelModal')">Keep Reservation</button>
                <button type="submit" class="btn btn-danger">Confirm Cancellation</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
