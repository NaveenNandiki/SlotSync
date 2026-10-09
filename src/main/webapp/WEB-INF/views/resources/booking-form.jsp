<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.Resource" %>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "Reserve Resource — SlotSync");
    Resource selectedResource = (Resource) request.getAttribute("selectedResource");
    @SuppressWarnings("unchecked")
    List<Resource> resources = (List<Resource>) request.getAttribute("resources");

    long preselectedId = 0;
    if (selectedResource != null) {
        preselectedId = selectedResource.getResourceId();
    } else if (request.getAttribute("resourceId") != null) {
        preselectedId = (Long) request.getAttribute("resourceId");
    }

    String startVal = (String) request.getAttribute("startVal");
    String endVal = (String) request.getAttribute("endVal");
    String purpose = (String) request.getAttribute("purpose");

    String csrfToken = (String) request.getAttribute("csrfToken");
    if (csrfToken == null) csrfToken = (String) session.getAttribute("csrfToken");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="page-header">
    <div>
        <h1 class="page-title">Submit Reservation Request</h1>
        <p class="page-subtitle">Reserve a facility, laboratory, or equipment for your upcoming academic or administrative session</p>
    </div>
    <a href="${pageContext.request.contextPath}/resources" class="btn btn-secondary">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
        <span>Back to Catalog</span>
    </a>
</div>

<div class="card" style="max-width: 800px; margin: 0 auto;">
    <form action="${pageContext.request.contextPath}/reservations/create" method="post">
        <input type="hidden" name="_csrf" value="<%= csrfToken %>">

        <div class="form-group">
            <label for="resourceId" class="form-label">Select Resource <span class="required">*</span></label>
            <select name="resourceId" id="resourceId" class="form-select" required>
                <option value="">-- Choose a shared resource --</option>
                <% if (resources != null) {
                    for (Resource r : resources) { %>
                        <option value="<%= r.getResourceId() %>" <%= r.getResourceId() == preselectedId ? "selected" : "" %>>
                            <%= ValidationUtil.escapeHtml(r.getName()) %> (<%= ValidationUtil.escapeHtml(r.getResourceType()) %> &bull; <%= ValidationUtil.escapeHtml(r.getLocation()) %>)
                        </option>
                <%  }
                   } %>
            </select>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="startTime" class="form-label">Start Date & Time <span class="required">*</span></label>
                <input type="datetime-local" id="startTime" name="startTime" class="form-control" required
                       value="<%= startVal != null ? ValidationUtil.escapeHtml(startVal) : "" %>">
                <div class="form-hint">Must be in the future</div>
            </div>

            <div class="form-group">
                <label for="endTime" class="form-label">End Date & Time <span class="required">*</span></label>
                <input type="datetime-local" id="endTime" name="endTime" class="form-control" required
                       value="<%= endVal != null ? ValidationUtil.escapeHtml(endVal) : "" %>">
                <div class="form-hint">Must be after the start time</div>
            </div>
        </div>

        <div class="form-group">
            <label for="purpose" class="form-label">Purpose of Booking / Reservation <span class="required">*</span></label>
            <textarea id="purpose" name="purpose" class="form-control" rows="4" required
                      placeholder="Please specify why you need this resource (e.g., Practical Lab Session for CSE Batch 2026, Departmental Faculty Review, Thesis Defense)..."><%= purpose != null ? ValidationUtil.escapeHtml(purpose) : "" %></textarea>
            <div class="form-hint">Detailed purpose assists administrators in reviewing your request faster.</div>
        </div>

        <div style="background: rgba(99, 102, 241, 0.08); border: 1px solid rgba(99, 102, 241, 0.2); border-radius: var(--radius-md); padding: 1rem; margin-bottom: 1.5rem; font-size: 0.825rem; color: #a5b4fc;">
            <strong>Double-Booking Protection Guarantee:</strong> SlotSync guarantees zero double-bookings. When you submit this request, the system atomically validates availability with concurrency locks before reserving the slot.
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 0.75rem;">
            <a href="${pageContext.request.contextPath}/resources" class="btn btn-secondary">Cancel</a>
            <button type="submit" class="btn btn-primary btn-lg">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                <span>Confirm & Submit Request</span>
            </button>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
