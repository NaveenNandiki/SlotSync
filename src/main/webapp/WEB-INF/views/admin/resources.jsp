<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.Resource" %>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Resource Inventory Management — SlotSync");
    @SuppressWarnings("unchecked")
    List<Resource> resources = (List<Resource>) request.getAttribute("resources");
    @SuppressWarnings("unchecked")
    List<String> resourceTypes = (List<String>) request.getAttribute("resourceTypes");

    String selectedType = (String) request.getAttribute("selectedType");
    String searchQuery = (String) request.getAttribute("searchQuery");
    String selectedStatus = (String) request.getAttribute("selectedStatus");

    String csrfToken = (String) request.getAttribute("csrfToken");
    if (csrfToken == null) csrfToken = (String) session.getAttribute("csrfToken");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Resource Inventory</h1>
        <p class="page-subtitle">Add, modify, and manage the active status of university facilities and bookable equipment</p>
    </div>
    <a href="${pageContext.request.contextPath}/admin/resources/create" class="btn btn-primary">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        <span>Add New Resource</span>
    </a>
</div>

<!-- Filter Bar -->
<form action="${pageContext.request.contextPath}/admin/resources" method="get" class="filter-bar">
    <div style="flex: 2; min-width: 220px;">
        <input type="text" name="search" class="form-control" placeholder="Search by name, location, description..."
               value="<%= searchQuery != null ? ValidationUtil.escapeHtml(searchQuery) : "" %>">
    </div>

    <div style="flex: 1.5; min-width: 180px;">
        <select name="type" class="form-select">
            <option value="ALL">All Categories</option>
            <% if (resourceTypes != null) {
                for (String t : resourceTypes) { %>
                    <option value="<%= ValidationUtil.escapeHtml(t) %>" <%= t.equalsIgnoreCase(selectedType) ? "selected" : "" %>>
                        <%= ValidationUtil.escapeHtml(t) %>
                    </option>
            <%  }
               } %>
        </select>
    </div>

    <div style="flex: 1.2; min-width: 150px;">
        <select name="status" class="form-select">
            <option value="ALL">All Statuses</option>
            <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Active Only</option>
            <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Inactive Only</option>
        </select>
    </div>

    <div style="display: flex; gap: 0.5rem;">
        <button type="submit" class="btn btn-primary">Filter</button>
        <a href="${pageContext.request.contextPath}/admin/resources" class="btn btn-secondary">Reset</a>
    </div>
</form>

<div class="card">
    <% if (resources == null || resources.isEmpty()) { %>
        <div class="empty-state">
            <h3 class="empty-state-title">No Resources Found</h3>
            <p class="empty-state-desc">No resources in inventory match your current filter criteria.</p>
            <a href="${pageContext.request.contextPath}/admin/resources/create" class="btn btn-primary">Create First Resource</a>
        </div>
    <% } else { %>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name & Details</th>
                        <th>Type</th>
                        <th>Location</th>
                        <th>Capacity</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Resource r : resources) { %>
                        <tr>
                            <td>#<%= r.getResourceId() %></td>
                            <td>
                                <strong><%= ValidationUtil.escapeHtml(r.getName()) %></strong>
                                <% if (r.getDescription() != null && !r.getDescription().isEmpty()) { %>
                                    <div style="font-size: 0.775rem; color: var(--text-muted); max-width: 320px; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">
                                        <%= ValidationUtil.escapeHtml(r.getDescription()) %>
                                    </div>
                                <% } %>
                            </td>
                            <td>
                                <span style="font-weight: 600; color: var(--accent-cyan);"><%= ValidationUtil.escapeHtml(r.getResourceType()) %></span>
                            </td>
                            <td><%= ValidationUtil.escapeHtml(r.getLocation()) %></td>
                            <td><strong><%= r.getCapacity() %></strong></td>
                            <td>
                                <span class="badge <%= r.isActive() ? "badge-active" : "badge-inactive" %>">
                                    <%= r.isActive() ? "Active" : "Inactive" %>
                                </span>
                            </td>
                            <td>
                                <div style="display: flex; gap: 0.5rem;">
                                    <a href="${pageContext.request.contextPath}/admin/resources/edit?id=<%= r.getResourceId() %>" class="btn btn-secondary btn-sm">
                                        Edit
                                    </a>

                                    <% if (r.isActive()) { %>
                                        <form action="${pageContext.request.contextPath}/admin/resources/deactivate" method="post" style="display: inline;">
                                            <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                                            <input type="hidden" name="resourceId" value="<%= r.getResourceId() %>">
                                            <button type="submit" class="btn btn-outline-danger btn-sm" onclick="return confirm('Are you sure you want to deactivate this resource? It will be hidden from user search.')">
                                                Deactivate
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <form action="${pageContext.request.contextPath}/admin/resources/activate" method="post" style="display: inline;">
                                            <input type="hidden" name="_csrf" value="<%= csrfToken %>">
                                            <input type="hidden" name="resourceId" value="<%= r.getResourceId() %>">
                                            <button type="submit" class="btn btn-success btn-sm">
                                                Activate
                                            </button>
                                        </form>
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

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
