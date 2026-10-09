<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.slotsync.model.User" %>
<%
    User currentUserFooter = (User) session.getAttribute("currentUser");
%>
<% if (currentUserFooter != null) { %>
            </main>
            <footer style="padding: 1.5rem 2rem; border-top: 1px solid var(--border-subtle); color: var(--text-subtle); font-size: 0.8rem; display: flex; justify-content: space-between; align-items: center;">
                <div>&copy; <%= java.time.Year.now().getValue() %> <strong>SlotSync</strong> — Resource Booking & Reservation System</div>
                <div>Enterprise Edition &bull; Tomcat 11 Ready</div>
            </footer>
        </div>
    </div>
<% } else { %>
    </div>
    <footer style="padding: 2rem 3rem; border-top: 1px solid var(--border-subtle); color: var(--text-subtle); font-size: 0.85rem; text-align: center;">
        <div>&copy; <%= java.time.Year.now().getValue() %> <strong>SlotSync</strong> — Intelligent Resource & Facility Reservation Platform</div>
    </footer>
<% } %>

    <script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>
