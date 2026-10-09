package com.slotsync.controller;

import com.slotsync.exception.ResourceNotFoundException;
import com.slotsync.model.Resource;
import com.slotsync.service.ResourceService;
import com.slotsync.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Controller handling Administrator Resource Inventory Management (CRUD and active toggling).
 */
@WebServlet(name = "AdminResourceServlet", urlPatterns = {
    "/admin/resources",
    "/admin/resources/create",
    "/admin/resources/edit",
    "/admin/resources/deactivate",
    "/admin/resources/activate"
})
public class AdminResourceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ResourceService resourceService;

    @Override
    public void init() throws ServletException {
        this.resourceService = new ResourceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/admin/resources/create".equals(path)) {
            request.setAttribute("isEdit", false);
            request.setAttribute("resourceTypes", resourceService.getResourceTypes());
            request.getRequestDispatcher("/WEB-INF/views/admin/resource-form.jsp").forward(request, response);
            return;
        }

        if ("/admin/resources/edit".equals(path)) {
            long resourceId = ValidationUtil.parseLong(request.getParameter("id"), 0);
            if (resourceId <= 0) {
                response.sendRedirect(request.getContextPath() + "/admin/resources");
                return;
            }
            try {
                Resource resource = resourceService.getResourceById(resourceId);
                request.setAttribute("resource", resource);
                request.setAttribute("isEdit", true);
                request.setAttribute("resourceTypes", resourceService.getResourceTypes());
                request.getRequestDispatcher("/WEB-INF/views/admin/resource-form.jsp").forward(request, response);
            } catch (ResourceNotFoundException e) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/resources");
            }
            return;
        }

        // Default: /admin/resources listing
        String type = request.getParameter("type");
        String location = request.getParameter("location");
        String search = request.getParameter("search");
        String statusFilter = request.getParameter("status");

        Boolean activeOnly = null;
        if ("ACTIVE".equalsIgnoreCase(statusFilter)) {
            activeOnly = true;
        } else if ("INACTIVE".equalsIgnoreCase(statusFilter)) {
            activeOnly = false;
        }

        List<Resource> resources = resourceService.searchResources(type, location, search, activeOnly);

        request.setAttribute("resources", resources);
        request.setAttribute("resourceTypes", resourceService.getResourceTypes());
        request.setAttribute("selectedType", type);
        request.setAttribute("selectedLocation", location);
        request.setAttribute("searchQuery", search);
        request.setAttribute("selectedStatus", statusFilter);

        request.getRequestDispatcher("/WEB-INF/views/admin/resources.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        HttpSession session = request.getSession();

        if ("/admin/resources/create".equals(path)) {
            String name = request.getParameter("name");
            String resourceType = request.getParameter("resourceType");
            String location = request.getParameter("location");
            int capacity = ValidationUtil.parseInt(request.getParameter("capacity"), 1);
            String description = request.getParameter("description");
            boolean active = "true".equalsIgnoreCase(request.getParameter("active")) || "on".equalsIgnoreCase(request.getParameter("active"));

            try {
                Resource created = resourceService.createResource(name, resourceType, location, capacity, description, active);
                session.setAttribute("successMessage", "Resource '" + created.getName() + "' created successfully.");
                response.sendRedirect(request.getContextPath() + "/admin/resources");
            } catch (Exception e) {
                request.setAttribute("errorMessage", e.getMessage());
                request.setAttribute("isEdit", false);
                request.setAttribute("resourceTypes", resourceService.getResourceTypes());
                request.setAttribute("name", name);
                request.setAttribute("resourceType", resourceType);
                request.setAttribute("location", location);
                request.setAttribute("capacity", capacity);
                request.setAttribute("description", description);
                request.setAttribute("active", active);
                request.getRequestDispatcher("/WEB-INF/views/admin/resource-form.jsp").forward(request, response);
            }
            return;
        }

        if ("/admin/resources/edit".equals(path)) {
            long resourceId = ValidationUtil.parseLong(request.getParameter("resourceId"), 0);
            String name = request.getParameter("name");
            String resourceType = request.getParameter("resourceType");
            String location = request.getParameter("location");
            int capacity = ValidationUtil.parseInt(request.getParameter("capacity"), 1);
            String description = request.getParameter("description");
            boolean active = "true".equalsIgnoreCase(request.getParameter("active")) || "on".equalsIgnoreCase(request.getParameter("active"));

            try {
                Resource updated = resourceService.updateResource(resourceId, name, resourceType, location, capacity, description, active);
                session.setAttribute("successMessage", "Resource '" + updated.getName() + "' updated successfully.");
                response.sendRedirect(request.getContextPath() + "/admin/resources");
            } catch (Exception e) {
                request.setAttribute("errorMessage", e.getMessage());
                request.setAttribute("isEdit", true);
                request.setAttribute("resourceTypes", resourceService.getResourceTypes());
                Resource temp = new Resource(resourceId, name, resourceType, location, capacity, description, active, null);
                request.setAttribute("resource", temp);
                request.getRequestDispatcher("/WEB-INF/views/admin/resource-form.jsp").forward(request, response);
            }
            return;
        }

        if ("/admin/resources/deactivate".equals(path) || "/admin/resources/activate".equals(path)) {
            long resourceId = ValidationUtil.parseLong(request.getParameter("resourceId"), 0);
            boolean newActiveState = "/admin/resources/activate".equals(path);
            try {
                resourceService.toggleResourceActive(resourceId, newActiveState);
                session.setAttribute("successMessage", "Resource has been " + (newActiveState ? "activated" : "deactivated") + ".");
            } catch (Exception e) {
                session.setAttribute("errorMessage", e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/admin/resources");
        }
    }
}
