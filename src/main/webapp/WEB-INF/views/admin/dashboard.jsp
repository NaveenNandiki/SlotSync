<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.User"%>
<%@ page import="com.slotsync.model.Reservation"%>
<%@ page import="com.slotsync.util.ValidationUtil"%>
<%@ page import="java.util.List"%>
<%
request.setAttribute("pageTitle", "Administrator Dashboard — SlotSync");
User admin = (User) session.getAttribute("currentUser");

//Ternory Operators
int activeResourcesCount = request.getAttribute("activeResourcesCount") != null
		? (Integer) request.getAttribute("activeResourcesCount")
		: 0;
int totalResourcesCount = request.getAttribute("totalResourcesCount") != null
		? (Integer) request.getAttribute("totalResourcesCount")
		: 0;
int pendingCount = request.getAttribute("pendingCount") != null ? (Integer) request.getAttribute("pendingCount") : 0;
int approvedCount = request.getAttribute("approvedCount") != null ? (Integer) request.getAttribute("approvedCount") : 0;
int upcomingApprovedCount = request.getAttribute("upcomingApprovedCount") != null
		? (Integer) request.getAttribute("upcomingApprovedCount")
		: 0;
int completedCount = request.getAttribute("completedCount") != null ? (Integer) request.getAttribute("completedCount")
		: 0;
int cancelledCount = request.getAttribute("cancelledCount") != null ? (Integer) request.getAttribute("cancelledCount")
		: 0;

@SuppressWarnings("unchecked")
List<Reservation> recentReservations = (List<Reservation>) request.getAttribute("recentReservations");

String csrfToken = (String) request.getAttribute("csrfToken");
if (csrfToken == null)
	csrfToken = (String) session.getAttribute("csrfToken");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-header">
	<div>
		<h1 class="page-title">Administration Console</h1>
		<p class="page-subtitle">Overview of campus facilities, booking
			approval queues, and capacity utilization</p>
	</div>
	<div style="display: flex; gap: 0.75rem;">
		<a href="${pageContext.request.contextPath}/admin/resources/create"
			class="btn btn-secondary"> <svg width="18" height="18"
				viewBox="0 0 24 24" fill="none" stroke="currentColor"
				stroke-width="2">
				<line x1="12" y1="5" x2="12" y2="19"></line>
				<line x1="5" y1="12" x2="19" y2="12"></line></svg> <span>Add
				Resource</span>
		</a> <a
			href="${pageContext.request.contextPath}/admin/reservations?status=PENDING"
			class="btn btn-primary"> <svg width="18" height="18"
				viewBox="0 0 24 24" fill="none" stroke="currentColor"
				stroke-width="2">
				<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
				<polyline points="14 2 14 8 20 8"></polyline>
				<line x1="16" y1="13" x2="8" y2="13"></line>
				<line x1="16" y1="17" x2="8" y2="17"></line>
				<polyline points="10 9 9 9 8 9"></polyline></svg> <span>Review
				Pending (<%=pendingCount%>)
		</span>
		</a>
	</div>
</div>

<!-- Admin Metrics Stats Grid -->
<div class="stats-grid">
	<div class="stat-card">
		<div class="stat-icon indigo">
			<svg width="28" height="28" viewBox="0 0 24 24" fill="none"
				stroke="currentColor" stroke-width="2">
				<path
					d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
		</div>
		<div class="stat-info">
			<div class="stat-label">Active Resources</div>
			<div class="stat-value"><%=activeResourcesCount%>
				<span
					style="font-size: 1rem; color: var(--text-muted); font-weight: 500;">/
					<%=totalResourcesCount%></span>
			</div>
		</div>
	</div>

	<div class="stat-card">
		<div class="stat-icon amber">
			<svg width="28" height="28" viewBox="0 0 24 24" fill="none"
				stroke="currentColor" stroke-width="2">
				<circle cx="12" cy="12" r="10"></circle>
				<polyline points="12 6 12 12 16 14"></polyline></svg>
		</div>
		<div class="stat-info">
			<div class="stat-label">Pending Approval</div>
			<div class="stat-value" style="color: #fbbf24;"><%=pendingCount%></div>
		</div>
	</div>

	<div class="stat-card">
		<div class="stat-icon emerald">
			<svg width="28" height="28" viewBox="0 0 24 24" fill="none"
				stroke="currentColor" stroke-width="2">
				<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
				<polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
		</div>
		<div class="stat-info">
			<div class="stat-label">Upcoming Approved</div>
			<div class="stat-value"><%=upcomingApprovedCount%></div>
		</div>
	</div>

	<div class="stat-card">
		<div class="stat-icon cyan">
			<svg width="28" height="28" viewBox="0 0 24 24" fill="none"
				stroke="currentColor" stroke-width="2">
				<line x1="18" y1="20" x2="18" y2="10"></line>
				<line x1="12" y1="20" x2="12" y2="4"></line>
				<line x1="6" y1="20" x2="6" y2="14"></line></svg>
		</div>
		<div class="stat-info">
			<div class="stat-label">Completed Sessions</div>
			<div class="stat-value"><%=completedCount%></div>
		</div>
	</div>
</div>

<!-- Pending Requests Alert Banner if any -->
<%
if (pendingCount > 0) {
%>
<div class="alert alert-warning">
	<svg width="20" height="20" viewBox="0 0 24 24" fill="none"
		stroke="currentColor" stroke-width="2">
		<path
			d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"></path>
		<line x1="12" y1="9" x2="12" y2="13"></line>
		<line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
	<div style="flex: 1;">
		<strong>Action Required:</strong> There are
		<%=pendingCount%>
		reservation request<%=pendingCount > 1 ? "s" : ""%>
		awaiting administrator approval.
	</div>
	<a
		href="${pageContext.request.contextPath}/admin/reservations?status=PENDING"
		class="btn btn-sm btn-primary" style="margin-left: auto;"> Review
		Queue </a>
</div>
<%
}
%>

<!-- Recent Reservation Activity & Quick Approval -->
<div class="card">
	<div class="card-header">
		<div class="card-title">
			<svg width="20" height="20" viewBox="0 0 24 24" fill="none"
				stroke="currentColor" stroke-width="2">
				<polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
			<span>Recent System Reservations</span>
		</div>
		<a href="${pageContext.request.contextPath}/admin/reservations"
			class="btn btn-secondary btn-sm">All Bookings</a>
	</div>

	<%
	if (recentReservations == null || recentReservations.isEmpty()) {
	%>
	<div class="empty-state">
		<h3 class="empty-state-title">No Reservations In System</h3>
		<p class="empty-state-desc">No reservation requests have been
			submitted yet.</p>
	</div>
	<%
	} else {
	%>
	<div class="table-responsive">
		<table class="table">
			<thead>
				<tr>
					<th>ID</th>
					<th>User</th>
					<th>Resource</th>
					<th>Requested Time</th>
					<th>Purpose</th>
					<th>Status</th>
					<th>Quick Actions</th>
				</tr>
			</thead>
			<tbody>
				<%
				for (Reservation r : recentReservations) {
				%>
				<tr>
					<td>#<%=r.getReservationId()%></td>
					<td><strong><%=ValidationUtil.escapeHtml(r.getUserName())%></strong><br>
						<span style="font-size: 0.775rem; color: var(--text-muted);"><%=ValidationUtil.escapeHtml(r.getUserEmail())%></span>
					</td>
					<td><strong><%=ValidationUtil.escapeHtml(r.getResourceName())%></strong><br>
						<span style="font-size: 0.775rem; color: var(--accent-cyan);"><%=ValidationUtil.escapeHtml(r.getResourceType())%></span>
					</td>
					<td><strong><%=ValidationUtil.formatDisplay(r.getStartTime())%></strong><br>
						<span style="font-size: 0.775rem; color: var(--text-muted);">to
							<%=ValidationUtil.formatDisplay(r.getEndTime())%></span></td>
					<td style="max-width: 200px;"><%=ValidationUtil.escapeHtml(r.getPurpose())%></td>
					<td>
						<%
						if (r.isPending()) {
						%> <span class="badge badge-pending"><span
							class="badge-dot"></span> PENDING</span> <%
 } else if (r.isApproved()) {
 %>
						<span class="badge badge-approved"><span class="badge-dot"></span>
							APPROVED</span> <%
 } else if (r.isRejected()) {
 %> <span
						class="badge badge-rejected"><span class="badge-dot"></span>
							REJECTED</span> <%
 } else if (r.isCancelled()) {
 %> <span
						class="badge badge-cancelled"><span class="badge-dot"></span>
							CANCELLED</span> <%
 } else {
 %> <span class="badge badge-completed"><span
							class="badge-dot"></span> COMPLETED</span> <%
 }
 %>
					</td>
					<td>
						<%
						if (r.isPending()) {
						%>
						<div style="display: flex; gap: 0.35rem;">
							<form
								action="${pageContext.request.contextPath}/admin/reservations/review"
								method="post" style="display: inline;">
								<input type="hidden" name="_csrf" value="<%=csrfToken%>">
								<input type="hidden" name="reservationId"
									value="<%=r.getReservationId()%>"> <input
									type="hidden" name="action" value="APPROVE"> <input
									type="hidden" name="reason"
									value="Approved from Admin Dashboard">
								<button type="submit" class="btn btn-success btn-sm"
									title="Approve Request">Approve</button>
							</form>
							<button type="button" class="btn btn-outline-danger btn-sm"
								onclick="openRejectModal('<%=r.getReservationId()%>', '<%=ValidationUtil.escapeHtml(r.getResourceName())%>')"
								title="Reject Request">Reject</button>
						</div> <%
 } else {
 %> <span
						style="font-size: 0.8rem; color: var(--text-subtle);">Reviewed</span>
						<%
						}
						%>
					</td>
				</tr>
				<%
				}
				%>
			</tbody>
		</table>
	</div>
	<%
	}
	%>
</div>

<!-- Rejection Modal Dialog -->
<div class="modal-overlay" id="rejectModal">
	<div class="modal-dialog">
		<form
			action="${pageContext.request.contextPath}/admin/reservations/review"
			method="post">
			<input type="hidden" name="_csrf" value="<%=csrfToken%>"> <input
				type="hidden" name="reservationId" id="rejectReservationId" value="">
			<input type="hidden" name="action" value="REJECT">

			<div class="modal-header">
				<h3 style="font-size: 1.15rem; font-weight: 700; color: #ffffff;">Reject
					Reservation Request</h3>
				<button type="button" class="alert-close-btn"
					onclick="closeModal('rejectModal')">&times;</button>
			</div>
			<div class="modal-body">
				<p style="color: var(--text-muted); margin-bottom: 1rem;">
					You are rejecting reservation request for <strong
						id="rejectResourceName" style="color: #ffffff;"></strong>. A
					reason is mandatory so the user understands why.
				</p>
				<div class="form-group">
					<label for="rejectReason" class="form-label">Mandatory
						Rejection Reason <span class="required">*</span>
					</label>
					<textarea name="reason" id="rejectReason" class="form-control"
						rows="3" required
						placeholder="e.g., Facility reserved for semester examinations, Scheduled maintenance..."></textarea>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-secondary"
					onclick="closeModal('rejectModal')">Cancel</button>
				<button type="submit" class="btn btn-danger">Confirm
					Rejection</button>
			</div>
		</form>
	</div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
