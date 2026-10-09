<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.Resource" %>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDateTime" %>
<%
    request.setAttribute("pageTitle", "Resource Catalog & Availability — SlotSync");
    @SuppressWarnings("unchecked")
    List<Resource> resources = (List<Resource>) request.getAttribute("resources");
    @SuppressWarnings("unchecked")
    List<String> resourceTypes = (List<String>) request.getAttribute("resourceTypes");

    String selectedType = (String) request.getAttribute("selectedType");
    String selectedLocation = (String) request.getAttribute("selectedLocation");
    String searchQuery = (String) request.getAttribute("searchQuery");
    String selectedDate = (String) request.getAttribute("selectedDate");
    String selectedStartTime = (String) request.getAttribute("selectedStartTime");
    String selectedEndTime = (String) request.getAttribute("selectedEndTime");

    Boolean availabilitySearch = (Boolean) request.getAttribute("availabilitySearch");
    LocalDateTime searchedStart = (LocalDateTime) request.getAttribute("searchedStart");
    LocalDateTime searchedEnd = (LocalDateTime) request.getAttribute("searchedEnd");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Resource Catalog</h1>
        <p class="page-subtitle">Search laboratories, meeting rooms, smart projectors, and high-performance workstations</p>
    </div>
    <a href="${pageContext.request.contextPath}/reservations/new" class="btn btn-primary">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        <span>Direct Booking</span>
    </a>
</div>

<!-- Search & Availability Filter Form -->
<form action="${pageContext.request.contextPath}/resources" method="get" class="filter-bar">
    <div style="flex: 2; min-width: 200px;">
        <input type="text" name="search" class="form-control" placeholder="Search by name or keyword..."
               value="<%= searchQuery != null ? ValidationUtil.escapeHtml(searchQuery) : "" %>">
    </div>

    <div style="flex: 1.5; min-width: 170px;">
        <select name="type" class="form-select">
            <option value="ALL">All Resource Types</option>
            <% if (resourceTypes != null) {
                for (String t : resourceTypes) { %>
                    <option value="<%= ValidationUtil.escapeHtml(t) %>" <%= t.equalsIgnoreCase(selectedType) ? "selected" : "" %>>
                        <%= ValidationUtil.escapeHtml(t) %>
                    </option>
            <%  }
               } %>
        </select>
    </div>

    <div style="flex: 1.2; min-width: 140px;">
        <input type="date" name="date" class="form-control" title="Filter availability by date"
               value="<%= selectedDate != null ? ValidationUtil.escapeHtml(selectedDate) : "" %>">
    </div>

    <div style="flex: 1; min-width: 110px;">
        <input type="time" name="startTime" class="form-control" title="Start Time"
               value="<%= selectedStartTime != null ? ValidationUtil.escapeHtml(selectedStartTime) : "" %>">
    </div>

    <div style="flex: 1; min-width: 110px;">
        <input type="time" name="endTime" class="form-control" title="End Time"
               value="<%= selectedEndTime != null ? ValidationUtil.escapeHtml(selectedEndTime) : "" %>">
    </div>

    <div style="display: flex; gap: 0.5rem;">
        <button type="submit" class="btn btn-primary">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            <span>Filter</span>
        </button>
        <a href="${pageContext.request.contextPath}/resources" class="btn btn-secondary">Reset</a>
    </div>
</form>

<% if (Boolean.TRUE.equals(availabilitySearch) && searchedStart != null && searchedEnd != null) { %>
    <div class="alert alert-info">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
        <div>
            Showing available resources for: <strong><%= ValidationUtil.formatDisplay(searchedStart) %></strong> to <strong><%= ValidationUtil.formatDisplay(searchedEnd) %></strong>.
        </div>
    </div>
<% } %>

<!-- Resources Grid -->
<% if (resources == null || resources.isEmpty()) { %>
    <div class="card">
        <div class="empty-state">
            <div class="empty-state-icon">
                <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            </div>
            <h3 class="empty-state-title">No Resources Match Your Search</h3>
            <p class="empty-state-desc">Try clearing your filters or changing the scheduled time slot to find available equipment or spaces.</p>
            <a href="${pageContext.request.contextPath}/resources" class="btn btn-primary">View All Resources</a>
        </div>
    </div>
<% } else { %>
    <div class="resource-grid">
        <% for (Resource r : resources) { %>
            <div class="resource-card">
                <div>
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
                        <span class="resource-type-tag"><%= ValidationUtil.escapeHtml(r.getResourceType()) %></span>
                        <% if (Boolean.TRUE.equals(availabilitySearch)) { %>
                            <span class="badge badge-approved" style="font-size: 0.65rem;"><span class="badge-dot"></span> Available</span>
                        <% } else { %>
                            <span class="badge <%= r.isActive() ? "badge-active" : "badge-inactive" %>" style="font-size: 0.65rem;">
                                <%= r.isActive() ? "Active" : "Inactive" %>
                            </span>
                        <% } %>
                    </div>

                    <h3 class="resource-name"><%= ValidationUtil.escapeHtml(r.getName()) %></h3>

                    <ul class="resource-meta-list">
                        <li class="resource-meta-item">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                            <span><%= ValidationUtil.escapeHtml(r.getLocation()) %></span>
                        </li>
                        <li class="resource-meta-item">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                            <span>Capacity: <strong><%= r.getCapacity() %> <%= r.getCapacity() == 1 ? "unit / person" : "people" %></strong></span>
                        </li>
                    </ul>

                    <% if (r.getDescription() != null && !r.getDescription().isEmpty()) { %>
                        <p class="resource-desc"><%= ValidationUtil.escapeHtml(r.getDescription()) %></p>
                    <% } %>
                </div>

                <div style="display: flex; gap: 0.5rem; margin-top: 1rem; border-top: 1px solid var(--border-subtle); padding-top: 1rem;">
                    <a href="${pageContext.request.contextPath}/resources/details?id=<%= r.getResourceId() %>" class="btn btn-secondary btn-sm" style="flex: 1;">
                        Details & Schedule
                    </a>
                    <% 
                        String bookUrl = request.getContextPath() + "/reservations/new?resourceId=" + r.getResourceId();
                        if (searchedStart != null && searchedEnd != null) {
                            bookUrl += "&start=" + ValidationUtil.formatForInput(searchedStart) + "&end=" + ValidationUtil.formatForInput(searchedEnd);
                        }
                    %>
                    <a href="<%= bookUrl %>" class="btn btn-primary btn-sm" style="flex: 1;">
                        Book Now
                    </a>
                </div>
            </div>
        <% } %>
    </div>
<% } %>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
