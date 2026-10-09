<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Helper to extract and flash-clear session messages
    String sessionSuccess = (String) session.getAttribute("successMessage");
    if (sessionSuccess != null) {
        request.setAttribute("successMessage", sessionSuccess);
        session.removeAttribute("successMessage");
    }

    String sessionError = (String) session.getAttribute("errorMessage");
    if (sessionError != null) {
        request.setAttribute("errorMessage", sessionError);
        session.removeAttribute("errorMessage");
    }

    String sessionWarning = (String) session.getAttribute("warningMessage");
    if (sessionWarning != null) {
        request.setAttribute("warningMessage", sessionWarning);
        session.removeAttribute("warningMessage");
    }
%>

<% if (request.getAttribute("successMessage") != null) { %>
    <div class="alert alert-success alert-auto-dismiss" role="alert">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
            <polyline points="22 4 12 14.01 9 11.01"></polyline>
        </svg>
        <div><%= com.slotsync.util.ValidationUtil.escapeHtml((String)request.getAttribute("successMessage")) %></div>
        <button type="button" class="alert-close-btn" onclick="this.parentElement.remove()" aria-label="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
    </div>
<% } %>

<% if (request.getAttribute("errorMessage") != null) { %>
    <div class="alert alert-danger" role="alert">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
        </svg>
        <div><%= com.slotsync.util.ValidationUtil.escapeHtml((String)request.getAttribute("errorMessage")) %></div>
        <button type="button" class="alert-close-btn" onclick="this.parentElement.remove()" aria-label="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
    </div>
<% } %>

<% if (request.getAttribute("warningMessage") != null) { %>
    <div class="alert alert-warning alert-auto-dismiss" role="alert">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"></path>
            <line x1="12" y1="9" x2="12" y2="13"></line>
            <line x1="12" y1="17" x2="12.01" y2="17"></line>
        </svg>
        <div><%= com.slotsync.util.ValidationUtil.escapeHtml((String)request.getAttribute("warningMessage")) %></div>
        <button type="button" class="alert-close-btn" onclick="this.parentElement.remove()" aria-label="Close">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
        </button>
    </div>
<% } %>
