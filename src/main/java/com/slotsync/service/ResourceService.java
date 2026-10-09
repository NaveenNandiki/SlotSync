package com.slotsync.service;

import com.slotsync.dao.ResourceDAO;
import com.slotsync.exception.ResourceNotFoundException;
import com.slotsync.model.Resource;
import com.slotsync.util.ValidationUtil;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Service managing resource inventory, searches, filters, and lifecycle.
 */
public class ResourceService {

    private final ResourceDAO resourceDAO;

    public ResourceService() {
        this.resourceDAO = new ResourceDAO();
    }

    public ResourceService(ResourceDAO resourceDAO) {
        this.resourceDAO = resourceDAO;
    }

    public List<Resource> getAllResources(boolean activeOnly) {
        return resourceDAO.findAll(activeOnly);
    }

    public List<Resource> searchResources(String type, String location, String search, Boolean activeOnly) {
        return resourceDAO.findWithFilters(type, location, search, activeOnly);
    }

    public List<Resource> findAvailableResources(String type, String location, String search, LocalDateTime start, LocalDateTime end) {
        if (start != null && end != null && !end.isAfter(start)) {
            throw new IllegalArgumentException("End time must be strictly after start time.");
        }
        return resourceDAO.findAvailableResources(type, location, search, start, end);
    }

    public Resource getResourceById(long resourceId) throws ResourceNotFoundException {
        Resource r = resourceDAO.findById(resourceId);
        if (r == null) {
            throw new ResourceNotFoundException("Resource with ID " + resourceId + " was not found.");
        }
        return r;
    }

    public Resource createResource(String name, String resourceType, String location, int capacity, String description, boolean active) {
        if (!ValidationUtil.isNotBlank(name)) {
            throw new IllegalArgumentException("Resource name is required.");
        }
        if (!ValidationUtil.isNotBlank(resourceType)) {
            throw new IllegalArgumentException("Resource type is required.");
        }
        if (!ValidationUtil.isNotBlank(location)) {
            throw new IllegalArgumentException("Location is required.");
        }
        if (capacity <= 0) {
            throw new IllegalArgumentException("Capacity must be a positive number.");
        }

        Resource r = new Resource();
        r.setName(name.trim());
        r.setResourceType(resourceType.trim());
        r.setLocation(location.trim());
        r.setCapacity(capacity);
        r.setDescription(description != null ? description.trim() : null);
        r.setActive(active);
        r.setCreatedAt(LocalDateTime.now());

        boolean created = resourceDAO.create(r);
        if (!created) {
            throw new RuntimeException("Failed to save resource into the database.");
        }
        return r;
    }

    public Resource updateResource(long resourceId, String name, String resourceType, String location, int capacity, String description, boolean active) throws ResourceNotFoundException {
        Resource r = getResourceById(resourceId);

        if (!ValidationUtil.isNotBlank(name)) {
            throw new IllegalArgumentException("Resource name is required.");
        }
        if (!ValidationUtil.isNotBlank(resourceType)) {
            throw new IllegalArgumentException("Resource type is required.");
        }
        if (!ValidationUtil.isNotBlank(location)) {
            throw new IllegalArgumentException("Location is required.");
        }
        if (capacity <= 0) {
            throw new IllegalArgumentException("Capacity must be a positive number.");
        }

        r.setName(name.trim());
        r.setResourceType(resourceType.trim());
        r.setLocation(location.trim());
        r.setCapacity(capacity);
        r.setDescription(description != null ? description.trim() : null);
        r.setActive(active);

        boolean updated = resourceDAO.update(r);
        if (!updated) {
            throw new RuntimeException("Failed to update resource with ID " + resourceId);
        }
        return r;
    }

    public boolean toggleResourceActive(long resourceId, boolean active) throws ResourceNotFoundException {
        getResourceById(resourceId); // verify exists
        return resourceDAO.setActive(resourceId, active);
    }

    public List<String> getResourceTypes() {
        return resourceDAO.getDistinctTypes();
    }

    public int getActiveResourceCount() {
        return resourceDAO.countActiveResources();
    }

    public int getTotalResourceCount() {
        return resourceDAO.countTotalResources();
    }
}
