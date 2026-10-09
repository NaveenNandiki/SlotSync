<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%
    request.setAttribute("pageTitle", "403 Forbidden — SlotSync");
    String errorMessage = (String) request.getAttribute("errorMessage");
    if (errorMessage == null || errorMessage.isEmpty()) {
        errorMessage = "You do not have sufficient permissions or privileges to access this resource.";
    }
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="card" style="max-width: 600px; margin: 3rem auto; text-align: center; padding: 3rem 2rem;">
    <div style="font-size: 4rem; font-weight: 800; color: var(--accent-rose); line-height: 1; margin-bottom: 1rem; font-family: var(--font-mono);">
        403
    </div>
    <h2 style="font-size: 1.5rem; font-weight: 700; color: #ffffff; margin-bottom: 0.75rem;">Access Prohibited</h2>
    <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 2rem;">
        <%= ValidationUtil.escapeHtml(errorMessage) %>
    </p>
    <div style="display: flex; justify-content: center; gap: 1rem;">
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">Return to Dashboard</a>
        <a href="${pageContext.request.contextPath}/resources" class="btn btn-secondary">Browse Catalog</a>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
