package com.slotsync.controller;

import com.slotsync.model.Resource;
import com.slotsync.service.ResourceService;
import com.slotsync.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * Controller providing resource catalog browsing, filtering, and availability search.
 */
@WebServlet(name = "ResourceListServlet", urlPatterns = {"/resources"})
public class ResourceListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ResourceService resourceService;

    @Override
    public void init() throws ServletException {
        this.resourceService = new ResourceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String type = request.getParameter("type");
        String location = request.getParameter("location");
        String search = request.getParameter("search");
        String dateStr = request.getParameter("date");
        String startTimeStr = request.getParameter("startTime");
        String endTimeStr = request.getParameter("endTime");

        LocalDateTime startDateTime = null;
        LocalDateTime endDateTime = null;
        boolean availabilitySearch = false;

        if (ValidationUtil.isNotBlank(dateStr) && ValidationUtil.isNotBlank(startTimeStr) && ValidationUtil.isNotBlank(endTimeStr)) {
            try {
                LocalDate date = LocalDate.parse(dateStr.trim());
                LocalTime startTime = LocalTime.parse(startTimeStr.trim());
                LocalTime endTime = LocalTime.parse(endTimeStr.trim());

                startDateTime = LocalDateTime.of(date, startTime);
                endDateTime = LocalDateTime.of(date, endTime);

                if (endDateTime.isAfter(startDateTime)) {
                    availabilitySearch = true;
                } else {
                    request.setAttribute("warningMessage", "End time must be after start time for availability search.");
                }
            } catch (Exception e) {
                request.setAttribute("warningMessage", "Invalid date or time format in search parameters.");
            }
        }

        List<Resource> resources;
        if (availabilitySearch && startDateTime != null && endDateTime != null) {
            resources = resourceService.findAvailableResources(type, location, search, startDateTime, endDateTime);
            request.setAttribute("availabilitySearch", true);
            request.setAttribute("searchedStart", startDateTime);
            request.setAttribute("searchedEnd", endDateTime);
        } else {
            resources = resourceService.searchResources(type, location, search, true);
        }

        request.setAttribute("resources", resources);
        request.setAttribute("resourceTypes", resourceService.getResourceTypes());
        request.setAttribute("selectedType", type);
        request.setAttribute("selectedLocation", location);
        request.setAttribute("searchQuery", search);
        request.setAttribute("selectedDate", dateStr);
        request.setAttribute("selectedStartTime", startTimeStr);
        request.setAttribute("selectedEndTime", endTimeStr);

        request.getRequestDispatcher("/WEB-INF/views/resources/list.jsp").forward(request, response);
    }
}
