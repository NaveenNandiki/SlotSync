<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.Reservation" %>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "My Reservations — SlotSync");
    @SuppressWarnings("unchecked")
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    if (selectedStatus == null) selectedStatus = "ALL";

    String csrfToken = (String) request.getAttribute("csrfToken");
    if (csrfToken == null) csrfToken = (String) session.getAttribute("csrfToken");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">My Reservations</h1>
        <p class="page-subtitle">Track your booking statuses, schedules, and review responses</p>
    </div>
    <a href="${pageContext.request.contextPath}/reservations/new" class="btn btn-primary">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        <span>New Booking Request</span>
    </a>
</div>

<!-- Filter Tabs -->
<div style="display: flex; gap: 0.5rem; margin-bottom: 1.5rem; flex-wrap: wrap;">
    <a href="${pageContext.request.contextPath}/my-reservations" 
       class="btn btn-sm <%= "ALL".equalsIgnoreCase(selectedStatus) || selectedStatus.isEmpty() ? "btn-primary" : "btn-secondary" %>">All</a>
    <a href="${pageContext.request.contextPath}/my-reservations?status=PENDING" 
       class="btn btn-sm <%= "PENDING".equalsIgnoreCase(selectedStatus) ? "btn-primary" : "btn-secondary" %>">Pending</a>
    <a href="${pageContext.request.contextPath}/my-reservations?status=APPROVED" 
       class="btn btn-sm <%= "APPROVED".equalsIgnoreCase(selectedStatus) ? "btn-primary" : "btn-secondary" %>">Approved</a>
    <a href="${pageContext.request.contextPath}/my-reservations?status=REJECTED" 
       class="btn btn-sm <%= "REJECTED".equalsIgnoreCase(selectedStatus) ? "btn-primary" : "btn-secondary" %>">Rejected</a>
    <a href="${pageContext.request.contextPath}/my-reservations?status=CANCELLED" 
       class="btn btn-sm <%= "CANCELLED".equalsIgnoreCase(selectedStatus) ? "btn-primary" : "btn-secondary" %>">Cancelled</a>
    <a href="${pageContext.request.contextPath}/my-reservations?status=COMPLETED" 
       class="btn btn-sm <%= "COMPLETED".equalsIgnoreCase(selectedStatus) ? "btn-primary" : "btn-secondary" %>">Completed</a>
</div>

<div class="card">
    <% if (reservations == null || reservations.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-state-icon">
                <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
            </div>
            <h3 class="empty-state-title">No Reservations Found</h3>
            <p class="empty-state-desc">No reservations match the selected filter category "<%= ValidationUtil.escapeHtml(selectedStatus) %>".</p>
            <a href="${pageContext.request.contextPath}/resources" class="btn btn-primary">Find Available Resources</a>
        </div>
    <% } else { %>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Resource & Location</th>
                        <th>Start Time</th>
                        <th>End Time</th>
                        <th>Purpose</th>
                        <th>Status</th>
                        <th>Admin Notes</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Reservation r : reservations) { %>
                        <tr>
                            <td><strong>#<%= r.getReservationId() %></strong></td>
                            <td>
                                <strong><%= ValidationUtil.escapeHtml(r.getResourceName()) %></strong><br>
                                <span style="font-size: 0.775rem; color: var(--accent-cyan);"><%= ValidationUtil.escapeHtml(r.getResourceType()) %></span> &bull;
                                <span style="font-size: 0.775rem; color: var(--text-muted);"><%= ValidationUtil.escapeHtml(r.getResourceLocation()) %></span>
                            </td>
                            <td>
                                <strong><%= ValidationUtil.formatDisplayDate(r.getStartTime()) %></strong><br>
                                <span style="font-size: 0.8rem; color: var(--text-muted);"><%= ValidationUtil.formatDisplayTime(r.getStartTime()) %></span>
                            </td>
                            <td>
                                <strong><%= ValidationUtil.formatDisplayDate(r.getEndTime()) %></strong><br>
                                <span style="font-size: 0.8rem; color: var(--text-muted);"><%= ValidationUtil.formatDisplayTime(r.getEndTime()) %></span>
                            </td>
                            <td style="max-width: 220px;"><%= ValidationUtil.escapeHtml(r.getPurpose()) %></td>
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
                            <td style="font-size: 0.825rem; max-width: 200px;">
                                <% if (r.getReviewReason() != null && !r.getReviewReason().isEmpty()) { %>
                                    <span style="color: <%= r.isRejected() ? "var(--accent-rose)" : "var(--text-muted)" %>;">
                                        <%= ValidationUtil.escapeHtml(r.getReviewReason()) %>
                                    </span>
                                <% } else { %>
                                    <span style="color: var(--text-subtle);">&mdash;</span>
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
            <input type="hidden" name="returnTo" value="my-reservations">

            <div class="modal-header">
                <h3 style="font-size: 1.15rem; font-weight: 700; color: #ffffff;">Cancel Reservation</h3>
                <button type="button" class="alert-close-btn" onclick="closeModal('cancelModal')">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: var(--text-muted); margin-bottom: 1rem;">
                    Are you sure you want to cancel your reservation for <strong id="cancelResourceName" style="color: #ffffff;"></strong>?
                </p>
                <div class="form-group">
                    <label for="cancelReason" class="form-label">Reason for cancellation (optional):</label>
                    <textarea name="reason" id="cancelReason" class="form-control" rows="2" placeholder="e.g., Schedule changed..."></textarea>
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
