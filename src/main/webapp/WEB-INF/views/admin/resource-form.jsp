<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.Resource" %>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    boolean isEdit = Boolean.TRUE.equals(request.getAttribute("isEdit"));
    Resource resource = (Resource) request.getAttribute("resource");
    @SuppressWarnings("unchecked")
    List<String> resourceTypes = (List<String>) request.getAttribute("resourceTypes");

    request.setAttribute("pageTitle", (isEdit ? "Edit Resource" : "Create Resource") + " — SlotSync");

    String name = resource != null ? resource.getName() : (String) request.getAttribute("name");
    String resourceType = resource != null ? resource.getResourceType() : (String) request.getAttribute("resourceType");
    String location = resource != null ? resource.getLocation() : (String) request.getAttribute("location");
    int capacity = resource != null ? resource.getCapacity() : (request.getAttribute("capacity") != null ? (Integer)request.getAttribute("capacity") : 1);
    String description = resource != null ? resource.getDescription() : (String) request.getAttribute("description");
    boolean active = resource != null ? resource.isActive() : (request.getAttribute("active") != null ? (Boolean)request.getAttribute("active") : true);

    String csrfToken = (String) request.getAttribute("csrfToken");
    if (csrfToken == null) csrfToken = (String) session.getAttribute("csrfToken");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title"><%= isEdit ? "Edit Resource" : "Add New Resource" %></h1>
        <p class="page-subtitle"><%= isEdit ? "Update resource specifications, capacity, or location" : "Add a laboratory, conference room, projector, or workstation to the catalog" %></p>
    </div>
    <a href="${pageContext.request.contextPath}/admin/resources" class="btn btn-secondary">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
        <span>Back to Inventory</span>
    </a>
</div>

<div class="card" style="max-width: 800px; margin: 0 auto;">
    <form action="${pageContext.request.contextPath}/admin/resources/<%= isEdit ? "edit" : "create" %>" method="post">
        <input type="hidden" name="_csrf" value="<%= csrfToken %>">
        <% if (isEdit && resource != null) { %>
            <input type="hidden" name="resourceId" value="<%= resource.getResourceId() %>">
        <% } %>

        <div class="form-group">
            <label for="name" class="form-label">Resource Name <span class="required">*</span></label>
            <input type="text" id="name" name="name" class="form-control" required
                   placeholder="e.g. Advanced AI & Cloud Computing Lab (Room 204)"
                   value="<%= name != null ? ValidationUtil.escapeHtml(name) : "" %>">
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="resourceType" class="form-label">Resource Category / Type <span class="required">*</span></label>
                <input type="text" list="typeSuggestions" id="resourceType" name="resourceType" class="form-control" required
                       placeholder="e.g. Computer Laboratory, Meeting Room, Projector"
                       value="<%= resourceType != null ? ValidationUtil.escapeHtml(resourceType) : "" %>">
                <datalist id="typeSuggestions">
                    <option value="Computer Laboratory">
                    <option value="Meeting Room">
                    <option value="Conference Hall">
                    <option value="Projector">
                    <option value="Computer System">
                    <option value="Audio/Video Equipment">
                </datalist>
            </div>

            <div class="form-group">
                <label for="capacity" class="form-label">Capacity / Units <span class="required">*</span></label>
                <input type="number" id="capacity" name="capacity" class="form-control" required min="1" max="1000"
                       value="<%= capacity %>">
                <div class="form-hint">Number of seating stations or unit count</div>
            </div>
        </div>

        <div class="form-group">
            <label for="location" class="form-label">Physical Location / Room <span class="required">*</span></label>
            <input type="text" id="location" name="location" class="form-control" required
                   placeholder="e.g. Tech Block A, 2nd Floor, Room 204"
                   value="<%= location != null ? ValidationUtil.escapeHtml(location) : "" %>">
        </div>

        <div class="form-group">
            <label for="description" class="form-label">Detailed Description & Equipment Specifications</label>
            <textarea id="description" name="description" class="form-control" rows="4"
                      placeholder="Specify hardware specs, software installed, audiovisual equipment, HDMI connectivity, Wi-Fi details..."><%= description != null ? ValidationUtil.escapeHtml(description) : "" %></textarea>
        </div>

        <div class="form-group" style="display: flex; align-items: center; gap: 0.75rem; padding: 0.5rem 0;">
            <input type="checkbox" id="active" name="active" value="true" style="width: 18px; height: 18px; accent-color: var(--primary);" <%= active ? "checked" : "" %>>
            <label for="active" style="color: var(--text-main); font-weight: 600; cursor: pointer; margin-bottom: 0;">
                Resource is Active & Available for Booking
            </label>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 1.5rem; border-top: 1px solid var(--border-subtle); padding-top: 1.25rem;">
            <a href="${pageContext.request.contextPath}/admin/resources" class="btn btn-secondary">Cancel</a>
            <button type="submit" class="btn btn-primary btn-lg">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path><polyline points="17 21 17 13 7 13 7 21"></polyline><polyline points="7 3 7 8 15 8"></polyline></svg>
                <span><%= isEdit ? "Save Changes" : "Create Resource" %></span>
            </button>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
