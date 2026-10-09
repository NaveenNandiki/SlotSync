<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%
    request.setAttribute("pageTitle", "Sign In — SlotSync");
    String email = (String) request.getAttribute("email");
    String csrfToken = (String) request.getAttribute("csrfToken");
    if (csrfToken == null) csrfToken = (String) session.getAttribute("csrfToken");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="auth-wrapper">
    <div class="auth-card">
        <div class="auth-header">
            <div style="display: inline-flex; justify-content: center; margin-bottom: 0.5rem;">
                <div class="brand-icon" style="width: 52px; height: 52px; font-size: 1.5rem;">S</div>
            </div>
            <h1 class="auth-title">Welcome to SlotSync</h1>
            <p class="auth-subtitle">Sign in to manage and reserve organization resources</p>
        </div>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <input type="hidden" name="_csrf" value="<%= csrfToken %>">

            <div class="form-group">
                <label for="email" class="form-label">Email Address <span class="required">*</span></label>
                <input type="email" id="email" name="email" class="form-control" 
                       placeholder="name@organization.edu" required autofocus
                       value="<%= email != null ? ValidationUtil.escapeHtml(email) : "" %>">
            </div>

            <div class="form-group">
                <label for="password" class="form-label">Password <span class="required">*</span></label>
                <input type="password" id="password" name="password" class="form-control" 
                       placeholder="••••••••••••" required>
            </div>

            <button type="submit" class="btn btn-primary btn-lg" style="width: 100%; margin-top: 0.5rem;">
                <span>Sign In</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
            </button>
        </form>

        <div style="margin-top: 1.75rem; padding-top: 1.25rem; border-top: 1px solid var(--border-subtle); text-align: center; font-size: 0.875rem; color: var(--text-muted);">
            Don't have an account? <a href="${pageContext.request.contextPath}/register" style="font-weight: 700;">Create an account</a>
        </div>

        <!-- Quick Demo Credentials helper box -->
        <div style="margin-top: 1.5rem; background: rgba(30, 41, 59, 0.5); border: 1px dashed var(--border-medium); border-radius: var(--radius-md); padding: 0.85rem 1rem; font-size: 0.775rem; color: var(--text-muted);">
            <div style="font-weight: 700; color: #cbd5e1; margin-bottom: 0.25rem;">Quick Demo Credentials:</div>
            <div><strong>Admin:</strong> <code>admin@slotsync.com</code> / <code>Admin@12345</code></div>
            <div><strong>User:</strong> <code>john.doe@slotsync.com</code> / <code>User@12345</code></div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
