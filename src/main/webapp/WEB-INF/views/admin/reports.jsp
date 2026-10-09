<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Usage Analytics & Reports — SlotSync");
    @SuppressWarnings("unchecked")
    Map<String, Object> summary = (Map<String, Object>) request.getAttribute("summary");
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> utilizationList = (List<Map<String, Object>>) request.getAttribute("utilizationList");
    @SuppressWarnings("unchecked")
    Map<String, Integer> statusDistribution = (Map<String, Integer>) request.getAttribute("statusDistribution");

    int totalUsers = summary != null && summary.get("totalUsers") != null ? (Integer) summary.get("totalUsers") : 0;
    int totalResources = summary != null && summary.get("totalResources") != null ? (Integer) summary.get("totalResources") : 0;
    int activeResources = summary != null && summary.get("activeResources") != null ? (Integer) summary.get("activeResources") : 0;
    int totalReservations = summary != null && summary.get("totalReservations") != null ? (Integer) summary.get("totalReservations") : 0;

    int pending = statusDistribution != null && statusDistribution.get("PENDING") != null ? statusDistribution.get("PENDING") : 0;
    int approved = statusDistribution != null && statusDistribution.get("APPROVED") != null ? statusDistribution.get("APPROVED") : 0;
    int rejected = statusDistribution != null && statusDistribution.get("REJECTED") != null ? statusDistribution.get("REJECTED") : 0;
    int cancelled = statusDistribution != null && statusDistribution.get("CANCELLED") != null ? statusDistribution.get("CANCELLED") : 0;
    int completed = statusDistribution != null && statusDistribution.get("COMPLETED") != null ? statusDistribution.get("COMPLETED") : 0;
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Analytics & Resource Utilization Reports</h1>
        <p class="page-subtitle">Examine facility demand, booking success rates, and allocation hours across the organization</p>
    </div>
</div>

<!-- Key Figures Summary -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-icon indigo">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        </div>
        <div class="stat-info">
            <div class="stat-label">Registered Users</div>
            <div class="stat-value"><%= totalUsers %></div>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon cyan">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
        </div>
        <div class="stat-info">
            <div class="stat-label">Total Facilities</div>
            <div class="stat-value"><%= activeResources %> <span style="font-size: 0.95rem; color: var(--text-muted); font-weight: 500;">/ <%= totalResources %> Active</span></div>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon emerald">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
        </div>
        <div class="stat-info">
            <div class="stat-label">Total Lifetime Bookings</div>
            <div class="stat-value"><%= totalReservations %></div>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon amber">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
        </div>
        <div class="stat-info">
            <div class="stat-label">Pending Approval</div>
            <div class="stat-value" style="color: #fbbf24;"><%= pending %></div>
        </div>
    </div>
</div>

<!-- Status Distribution Breakdown Cards -->
<div class="card" style="margin-bottom: 2rem;">
    <div class="card-header">
        <div class="card-title">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><path d="M12 2a10 10 0 0 1 10 10"></path></svg>
            <span>Reservation Status Breakdown</span>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1rem; padding: 0.5rem 0;">
        <div style="background: var(--bg-surface-elevated); padding: 1rem; border-radius: var(--radius-md); border-left: 4px solid #34d399;">
            <div style="font-size: 0.775rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700;">Approved</div>
            <div style="font-size: 1.5rem; font-weight: 800; color: #34d399; margin-top: 0.25rem;"><%= approved %></div>
            <div style="font-size: 0.75rem; color: var(--text-subtle);"><%= totalReservations > 0 ? (approved * 100 / totalReservations) : 0 %>% of all requests</div>
        </div>

        <div style="background: var(--bg-surface-elevated); padding: 1rem; border-radius: var(--radius-md); border-left: 4px solid #fbbf24;">
            <div style="font-size: 0.775rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700;">Pending</div>
            <div style="font-size: 1.5rem; font-weight: 800; color: #fbbf24; margin-top: 0.25rem;"><%= pending %></div>
            <div style="font-size: 0.75rem; color: var(--text-subtle);"><%= totalReservations > 0 ? (pending * 100 / totalReservations) : 0 %>% awaiting review</div>
        </div>

        <div style="background: var(--bg-surface-elevated); padding: 1rem; border-radius: var(--radius-md); border-left: 4px solid #38bdf8;">
            <div style="font-size: 0.775rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700;">Completed</div>
            <div style="font-size: 1.5rem; font-weight: 800; color: #38bdf8; margin-top: 0.25rem;"><%= completed %></div>
            <div style="font-size: 0.75rem; color: var(--text-subtle);">Successfully finished</div>
        </div>

        <div style="background: var(--bg-surface-elevated); padding: 1rem; border-radius: var(--radius-md); border-left: 4px solid #fb7185;">
            <div style="font-size: 0.775rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700;">Rejected</div>
            <div style="font-size: 1.5rem; font-weight: 800; color: #fb7185; margin-top: 0.25rem;"><%= rejected %></div>
            <div style="font-size: 0.75rem; color: var(--text-subtle);"><%= totalReservations > 0 ? (rejected * 100 / totalReservations) : 0 %>% declined</div>
        </div>

        <div style="background: var(--bg-surface-elevated); padding: 1rem; border-radius: var(--radius-md); border-left: 4px solid #94a3b8;">
            <div style="font-size: 0.775rem; text-transform: uppercase; color: var(--text-muted); font-weight: 700;">Cancelled</div>
            <div style="font-size: 1.5rem; font-weight: 800; color: #94a3b8; margin-top: 0.25rem;"><%= cancelled %></div>
            <div style="font-size: 0.75rem; color: var(--text-subtle);">Released by users</div>
        </div>
    </div>
</div>

<!-- Resource Utilization Table -->
<div class="card">
    <div class="card-header">
        <div class="card-title">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
            <span>Facility Utilization Breakdown</span>
        </div>
    </div>

    <% if (utilizationList == null || utilizationList.isEmpty()) { %>
        <div class="empty-state">
            <h3 class="empty-state-title">No Utilization Data Available</h3>
        </div>
    <% } else { %>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Resource Name</th>
                        <th>Category</th>
                        <th>Total Bookings</th>
                        <th>Approved</th>
                        <th>Pending</th>
                        <th>Total Hours Booked</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> u : utilizationList) { %>
                        <tr>
                            <td><strong><%= ValidationUtil.escapeHtml((String) u.get("name")) %></strong></td>
                            <td>
                                <span style="font-weight: 600; color: var(--accent-cyan);"><%= ValidationUtil.escapeHtml((String) u.get("resourceType")) %></span>
                            </td>
                            <td><strong><%= u.get("totalBookings") %></strong></td>
                            <td><span style="color: #34d399; font-weight: 700;"><%= u.get("approvedBookings") %></span></td>
                            <td><span style="color: #fbbf24; font-weight: 700;"><%= u.get("pendingBookings") %></span></td>
                            <td>
                                <span style="font-family: var(--font-mono); font-weight: 700; color: #38bdf8;">
                                    <%= u.get("totalHoursBooked") %> hrs
                                </span>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } %>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
