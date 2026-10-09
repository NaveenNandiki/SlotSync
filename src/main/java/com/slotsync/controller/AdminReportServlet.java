package com.slotsync.controller;

import com.slotsync.service.AdminReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Map;

/**
 * Controller generating administrator reports, metrics, and resource utilization summaries.
 */
@WebServlet(name = "AdminReportServlet", urlPatterns = {"/admin/reports"})
public class AdminReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AdminReportService reportService;

    @Override
    public void init() throws ServletException {
        this.reportService = new AdminReportService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Map<String, Object> summary = reportService.getOverallSummary();
        request.setAttribute("summary", summary);
        request.setAttribute("utilizationList", summary.get("resourceUtilization"));
        request.setAttribute("statusDistribution", summary.get("statusDistribution"));

        request.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(request, response);
    }
}
