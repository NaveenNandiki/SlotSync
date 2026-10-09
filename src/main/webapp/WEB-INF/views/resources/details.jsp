<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.Resource" %>
<%@ page import="com.slotsync.model.Reservation" %>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    Resource resource = (Resource) request.getAttribute("resource");
    @SuppressWarnings("unchecked")
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    request.setAttribute("pageTitle", (resource != null ? resource.getName() : "Resource Details") + " — SlotSync");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<% if (resource == null) { %>
    <div class="card">
        <div class="empty-state">
            <h3 class="empty-state-title">Resource Not Found</h3>
            <p class="empty-state-desc">The requested resource could not be located in our system.</p>
            <a href="${pageContext.request.contextPath}/resources" class="btn btn-primary">Return to Catalog</a>
        </div>
    </div>
<% } else { %>
    <div class="page-header">
        <div>
            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.25rem;">
                <span class="resource-type-tag" style="margin-bottom: 0;"><%= ValidationUtil.escapeHtml(resource.getResourceType()) %></span>
                <span class="badge <%= resource.isActive() ? "badge-active" : "badge-inactive" %>">
                    <%= resource.isActive() ? "Active" : "Inactive" %>
                </span>
            </div>
            <h1 class="page-title"><%= ValidationUtil.escapeHtml(resource.getName()) %></h1>
            <p class="page-subtitle"><%= ValidationUtil.escapeHtml(resource.getLocation()) %></p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/reservations/new?resourceId=<%= resource.getResourceId() %>" class="btn btn-primary btn-lg">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                <span>Reserve This Resource</span>
            </a>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 1.5rem; margin-bottom: 2rem;">
        <!-- Left: Specifications -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                    <span>Specifications</span>
                </div>
            </div>

            <div style="display: flex; flex-direction: column; gap: 1.25rem;">
                <div>
                    <div style="font-size: 0.775rem; font-weight: 700; text-transform: uppercase; color: var(--text-subtle);">Resource Type</div>
                    <div style="font-size: 1rem; font-weight: 600; color: var(--accent-cyan);"><%= ValidationUtil.escapeHtml(resource.getResourceType()) %></div>
                </div>
                <div>
                    <div style="font-size: 0.775rem; font-weight: 700; text-transform: uppercase; color: var(--text-subtle);">Location</div>
                    <div style="font-size: 0.95rem; color: var(--text-main);"><%= ValidationUtil.escapeHtml(resource.getLocation()) %></div>
                </div>
                <div>
                    <div style="font-size: 0.775rem; font-weight: 700; text-transform: uppercase; color: var(--text-subtle);">Capacity / Units</div>
                    <div style="font-size: 0.95rem; font-weight: 600; color: #ffffff;"><%= resource.getCapacity() %> <%= resource.getCapacity() == 1 ? "unit / person" : "people" %></div>
                </div>
                <% if (resource.getDescription() != null && !resource.getDescription().isEmpty()) { %>
                    <div>
                        <div style="font-size: 0.775rem; font-weight: 700; text-transform: uppercase; color: var(--text-subtle); margin-bottom: 0.35rem;">Facility Details</div>
                        <p style="font-size: 0.9rem; color: var(--text-muted); line-height: 1.6;"><%= ValidationUtil.escapeHtml(resource.getDescription()) %></p>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Right: Current Schedule & Booked Slots -->
        <div class="card">
            <div class="card-header">
                <div class="card-title">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                    <span>Upcoming Booked Slots & Activity</span>
                </div>
            </div>

            <% if (reservations == null || reservations.isEmpty()) { %>
                <div class="empty-state" style="padding: 2rem 1rem;">
                    <div class="empty-state-icon" style="width: 52px; height: 52px;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <h3 class="empty-state-title" style="font-size: 1.1rem;">Full Availability</h3>
                    <p class="empty-state-desc">There are no active or pending reservations for this resource. You can book any desired time slot.</p>
                </div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Reserved By</th>
                                <th>Start Time</th>
                                <th>End Time</th>
                                <th>Purpose</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Reservation r : reservations) { %>
                                <tr>
                                    <td><%= ValidationUtil.escapeHtml(r.getUserName()) %></td>
                                    <td>
                                        <strong><%= ValidationUtil.formatDisplayDate(r.getStartTime()) %></strong><br>
                                        <span style="font-size: 0.8rem; color: var(--text-muted);"><%= ValidationUtil.formatDisplayTime(r.getStartTime()) %></span>
                                    </td>
                                    <td>
                                        <strong><%= ValidationUtil.formatDisplayDate(r.getEndTime()) %></strong><br>
                                        <span style="font-size: 0.8rem; color: var(--text-muted);"><%= ValidationUtil.formatDisplayTime(r.getEndTime()) %></span>
                                    </td>
                                    <td style="font-size: 0.85rem;"><%= ValidationUtil.escapeHtml(r.getPurpose()) %></td>
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
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </div>
<% } %>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
