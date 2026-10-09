<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
    request.setAttribute("pageTitle", "SlotSync — High-Performance Resource Booking Platform");
%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div style="max-width: 1200px; margin: 3rem auto; padding: 0 1.5rem; text-align: center;">
    <div style="display: inline-flex; align-items: center; gap: 0.5rem; background: rgba(99, 102, 241, 0.1); border: 1px solid rgba(99, 102, 241, 0.25); border-radius: var(--radius-full); padding: 0.35rem 1rem; font-size: 0.8rem; font-weight: 700; color: #a5b4fc; margin-bottom: 1.5rem;">
        <span style="width: 8px; height: 8px; border-radius: 50%; background: var(--accent-cyan); display: inline-block;"></span>
        Enterprise Concurrency & Double-Booking Protection
    </div>

    <h1 style="font-size: 3.25rem; font-weight: 800; letter-spacing: -0.03em; line-height: 1.15; max-width: 860px; margin: 0 auto 1.25rem; background: linear-gradient(135deg, #ffffff 30%, #94a3b8 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">
        Intelligent Resource & Facility Reservation Platform
    </h1>

    <p style="font-size: 1.15rem; color: var(--text-muted); max-width: 680px; margin: 0 auto 2.5rem; line-height: 1.6;">
        Streamline reservations for computer laboratories, executive boardrooms, smart laser projectors, and specialized workstations with guaranteed zero booking conflicts.
    </p>

    <div style="display: flex; justify-content: center; gap: 1rem; flex-wrap: wrap; margin-bottom: 4rem;">
        <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-lg" style="padding: 1rem 2.25rem; font-size: 1.1rem;">
            <span>Create Free Account</span>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
        </a>
        <a href="${pageContext.request.contextPath}/resources" class="btn btn-secondary btn-lg" style="padding: 1rem 2rem; font-size: 1.1rem;">
            <span>Explore Campus Catalog</span>
        </a>
    </div>

    <!-- Feature Grid -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.75rem; text-align: left;">
        <div class="card">
            <div class="stat-icon indigo" style="margin-bottom: 1.25rem;">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
            </div>
            <h3 style="font-size: 1.2rem; font-weight: 700; color: #ffffff; margin-bottom: 0.5rem;">Pessimistic Lock Concurrency</h3>
            <p style="font-size: 0.9rem; color: var(--text-muted); line-height: 1.5;">
                Engineered with transactional <code>SELECT ... FOR UPDATE</code> locks to guarantee overlapping requests never result in double bookings.
            </p>
        </div>

        <div class="card">
            <div class="stat-icon cyan" style="margin-bottom: 1.25rem;">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
            </div>
            <h3 style="font-size: 1.2rem; font-weight: 700; color: #ffffff; margin-bottom: 0.5rem;">Real-Time Availability Filter</h3>
            <p style="font-size: 0.9rem; color: var(--text-muted); line-height: 1.5;">
                Check facility availability dynamically across dates and time slots with back-to-back booking support.
            </p>
        </div>

        <div class="card">
            <div class="stat-icon emerald" style="margin-bottom: 1.25rem;">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
            </div>
            <h3 style="font-size: 1.2rem; font-weight: 700; color: #ffffff; margin-bottom: 0.5rem;">Full Audit Lifecycle & Analytics</h3>
            <p style="font-size: 0.9rem; color: var(--text-muted); line-height: 1.5;">
                Every reservation state change records actor, timestamp, and review reason with complete admin reporting metrics.
            </p>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
