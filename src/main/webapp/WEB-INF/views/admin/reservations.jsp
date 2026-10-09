<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.Reservation" %>
<%@ page import="com.slotsync.model.Resource" %>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Reservation Requests Management — SlotSync");
    @SuppressWarnings("unchecked")
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    @SuppressWarnings("unchecked")
    List<Resource> resources = (List<Resource>) request.getAttribute("resources");

    String selectedStatus = (String) request.getAttribute("selectedStatus");
    long selectedResourceId = request.getAttribute("selectedResourceId") != null ? (Long) request.getAttribute("selectedResourceId") : 0;
    String searchQuery = (String) request.getAttribute("searchQuery");

    String csrfToken = (String) request.getAttribute("csrfToken");
    if (csrfToken == null) csrfToken = (String) session.getAttribute("csrfToken");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Manage Reservation Requests</h1>
        <p class="page-subtitle">Review booking submissions, manage approvals, and enforce allocation policies</p>
    </div>
</div>

<!-- Filter Bar -->
<form action="${pageContext.request.contextPath}/admin/reservations" method="get" class="filter-bar">
    <div style="flex: 2; min-width: 200px;">
        <input type="text" name="search" class="form-control" placeholder="Search by user name, email, or purpose..."
               value="<%= searchQuery != null ? ValidationUtil.escapeHtml(searchQuery) : "" %>">
    </div>

    <div style="flex: 1.5; min-width: 170px;">
        <select name="status" class="form-select">
            <option value="ALL">All Statuses</option>
            <option value="PENDING" <%= "PENDING".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Pending Review</option>
            <option value="APPROVED" <%= "APPROVED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Approved</option>
            <option value="REJECTED" <%= "REJECTED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Rejected</option>
            <option value="CANCELLED" <%= "CANCELLED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Cancelled</option>
            <option value="COMPLETED" <%= "COMPLETED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Completed</option>
        </select>
    </div>

    <div style="flex: 1.5; min-width: 180px;">
        <select name="resourceId" class="form-select">
            <option value="0">All Resources</option>
            <% if (resources != null) {
                for (Resource res : resources) { %>
                    <option value="<%= res.getResourceId() %>" <%= res.getResourceId() == selectedResourceId ? "selected" : "" %>>
                        <%= ValidationUtil.escapeHtml(res.getName()) %>
                    </option>
            <%  }
               } %>
        </select>
    </div>

    <div style="display: flex; gap: 0.5rem;">
        <button type="submit" class="btn btn-primary">Filter</button>
        <a href="${pageContext.request.contextPath}/admin/reservations" class="btn btn-secondary">Reset</a>
    </div>
</form>

<div class="card">
    <% if (reservations == null || reservations.isEmpty()) { %>
        <div class="empty-state">
            <div class="empty-state-icon">
                <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
            </div>
            <h3 class="empty-state-title">No Reservations Match Filters</h3>
            <p class="empty-state-desc">There are currently no bookings found for the selected criteria.</p>
        </div>
    <% } else { %>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Requester</th>
                        <th>Resource</th>
                        <th>Scheduled Time</th>
                        <th>Purpose</th>
                        <th>Status</th>
                        <th>Review Details</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Reservation r : reservations) { %>
                        <tr>
                            <td><strong>#<%= r.getReservationId() %></strong></td>
                            <td>
                                <strong><%= ValidationUtil.escapeHtml(r.getUserName()) %></strong><br>
                                <span style="font-size: 0.775rem; color: var(--text-muted);"><%= ValidationUtil.escapeHtml(r.getUserEmail()) %></span>
                            </td>
                            <td>
                                <strong><%= ValidationUtil.escapeHtml(r.getResourceName()) %></strong><br>
                                <span style="font-size: 0.775rem; color: var(--accent-cyan);"><%= ValidationUtil.escapeHtml(r.getResourceType()) %></span>
                            </td>
                            <td>
                                <strong><%= ValidationUtil.formatDisplayDate(r.getStartTime()) %></strong><br>
                                <span style="font-size: 0.8rem; color: var(--text-muted);">
                                    <%= ValidationUtil.formatDisplayTime(r.getStartTime()) %> - <%= ValidationUtil.formatDisplayTime(r.getEndTime()) %>
                                </span>
                            </td>
                            <td style="max-width: 200px;"><%= ValidationUtil.escapeHtml(r.getPurpose()) %></td>
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
                            <td style="font-size: 0.8rem; max-width: 180px;">
                                <% if (r.getReviewReason() != null && !r.getReviewReason().isEmpty()) { %>
                                    <div><%= ValidationUtil.escapeHtml(r.getReviewReason()) %></div>
                                    <% if (r.getReviewedByName() != null) { %>
                                        <div style="font-size: 0.725rem; color: var(--text-subtle);">By: <%= ValidationUtil.escapeHtml(r.getReviewedByName()) %></div>
                                    <% } %>
                                <% } else { %>
                                    <span style="color: var(--text-subtle);">&mdash;</span>
                                <% } %>
                            </td>
                            <td>
                                <div style="display: flex; gap: 0.35rem; flex-wrap: wrap;">
                                    <% if (r.isPending()) { %>
                                        <form action="${pageContext.request.contextPath}/admin/reservations/review" method="post" style="display: inline;">
                                            <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                                            <input type="hidden" name="reservationId" value="<%= r.getReservationId() %>">
                                            <input type="hidden" name="action" value="APPROVE">
                                            <input type="hidden" name="reason" value="Approved by administrator">
                                            <button type="submit" class="btn btn-success btn-sm">Approve</button>
                                        </form>

                                        <button type="button" class="btn btn-outline-danger btn-sm"
                                                onclick="openRejectModal('<%= r.getReservationId() %>', '<%= ValidationUtil.escapeHtml(r.getResourceName()) %>')">
                                            Reject
                                        </button>
                                    <% } else if (r.isApproved()) { %>
                                        <button type="button" class="btn btn-outline-danger btn-sm"
                                                onclick="openCancelModal('<%= r.getReservationId() %>', '<%= ValidationUtil.escapeHtml(r.getResourceName()) %>')">
                                            Cancel
                                        </button>
                                    <% } else { %>
                                        <span style="font-size: 0.8rem; color: var(--text-subtle);">Closed</span>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } %>
</div>

<!-- Rejection Modal Dialog -->
<div class="modal-overlay" id="rejectModal">
    <div class="modal-dialog">
        <form action="${pageContext.request.contextPath}/admin/reservations/review" method="post">
            <input type="hidden" name="_csrf" value="<%= csrfToken %>">
            <input type="hidden" name="reservationId" id="rejectReservationId" value="">
            <input type="hidden" name="action" value="REJECT">

            <div class="modal-header">
                <h3 style="font-size: 1.15rem; font-weight: 700; color: #ffffff;">Reject Reservation Request</h3>
                <button type="button" class="alert-close-btn" onclick="closeModal('rejectModal')">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: var(--text-muted); margin-bottom: 1rem;">
                    You are rejecting reservation request for <strong id="rejectResourceName" style="color: #ffffff;"></strong>. A reason is mandatory:
                </p>
                <div class="form-group">
                    <label for="rejectReason" class="form-label">Rejection Reason <span class="required">*</span></label>
                    <textarea name="reason" id="rejectReason" class="form-control" rows="3" required
                              placeholder="e.g., Resource undergoes scheduled maintenance, Exceeds allowed class duration..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal('rejectModal')">Cancel</button>
                <button type="submit" class="btn btn-danger">Confirm Rejection</button>
            </div>
        </form>
    </div>
</div>

<!-- Cancellation Modal Dialog for Admin -->
<div class="modal-overlay" id="cancelModal">
    <div class="modal-dialog">
        <form action="${pageContext.request.contextPath}/reservations/cancel" method="post">
            <input type="hidden" name="_csrf" value="<%= csrfToken %>">
            <input type="hidden" name="reservationId" id="cancelReservationId" value="">
            <input type="hidden" name="returnTo" value="admin">

            <div class="modal-header">
                <h3 style="font-size: 1.15rem; font-weight: 700; color: #ffffff;">Cancel Approved Reservation</h3>
                <button type="button" class="alert-close-btn" onclick="closeModal('cancelModal')">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: var(--text-muted); margin-bottom: 1rem;">
                    Are you sure you want to cancel this approved reservation for <strong id="cancelResourceName" style="color: #ffffff;"></strong>?
                </p>
                <div class="form-group">
                    <label for="cancelReason" class="form-label">Administrative Reason:</label>
                    <textarea name="reason" id="cancelReason" class="form-control" rows="2" placeholder="e.g., Emergency closure of facility..."></textarea>
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
