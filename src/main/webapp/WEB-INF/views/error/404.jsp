<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<%
    request.setAttribute("pageTitle", "404 Not Found — SlotSync");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="card" style="max-width: 600px; margin: 3rem auto; text-align: center; padding: 3rem 2rem;">
    <div style="font-size: 4rem; font-weight: 800; color: var(--accent-amber); line-height: 1; margin-bottom: 1rem; font-family: var(--font-mono);">
        404
    </div>
    <h2 style="font-size: 1.5rem; font-weight: 700; color: #ffffff; margin-bottom: 0.75rem;">Page or Resource Not Found</h2>
    <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 2rem;">
        The requested URL or resource could not be found on SlotSync. It may have been relocated or deactivated.
    </p>
    <div style="display: flex; justify-content: center; gap: 1rem;">
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">Go to Dashboard</a>
        <a href="${pageContext.request.contextPath}/resources" class="btn btn-secondary">Search Catalog</a>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
