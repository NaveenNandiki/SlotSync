<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.util.ValidationUtil" %>
<%
    request.setAttribute("pageTitle", "Create an Account — SlotSync");
    String fullName = (String) request.getAttribute("fullName");
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
            <h1 class="auth-title">Get Started</h1>
            <p class="auth-subtitle">Create your personal reservation account</p>
        </div>

        <form action="${pageContext.request.contextPath}/register" method="post">
            <input type="hidden" name="_csrf" value="<%= csrfToken %>">

            <div class="form-group">
                <label for="fullName" class="form-label">Full Name <span class="required">*</span></label>
                <input type="text" id="fullName" name="fullName" class="form-control" 
                       placeholder="e.g. Dr. Alex Morgan" required autofocus
                       value="<%= fullName != null ? ValidationUtil.escapeHtml(fullName) : "" %>">
            </div>

            <div class="form-group">
                <label for="email" class="form-label">Email Address <span class="required">*</span></label>
                <input type="email" id="email" name="email" class="form-control" 
                       placeholder="name@organization.edu" required
                       value="<%= email != null ? ValidationUtil.escapeHtml(email) : "" %>">
            </div>

            <div class="form-group">
                <label for="password" class="form-label">Password <span class="required">*</span></label>
                <input type="password" id="password" name="password" class="form-control" 
                       placeholder="Minimum 6 characters" required minlength="6">
                <div class="form-hint">Must be at least 6 characters long</div>
            </div>

            <div class="form-group">
                <label for="confirmPassword" class="form-label">Confirm Password <span class="required">*</span></label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                       placeholder="Re-enter your password" required minlength="6">
            </div>

            <button type="submit" class="btn btn-primary btn-lg" style="width: 100%; margin-top: 0.5rem;">
                <span>Create Account</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
            </button>
        </form>

        <div style="margin-top: 1.75rem; padding-top: 1.25rem; border-top: 1px solid var(--border-subtle); text-align: center; font-size: 0.875rem; color: var(--text-muted);">
            Already have an account? <a href="${pageContext.request.contextPath}/login" style="font-weight: 700;">Sign in instead</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
