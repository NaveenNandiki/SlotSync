package com.slotsync.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Resource entity representing labs, meeting rooms, projectors, computer systems, etc.
 */
public class Resource implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long resourceId;
    private String name;
    private String resourceType;
    private String location;
    private int capacity;
    private String description;
    private boolean active;
    private LocalDateTime createdAt;

    public Resource() {
        this.capacity = 1;
        this.active = true;
    }

    public Resource(Long resourceId, String name, String resourceType, String location, int capacity, String description, boolean active, LocalDateTime createdAt) {
        this.resourceId = resourceId;
        this.name = name;
        this.resourceType = resourceType;
        this.location = location;
        this.capacity = capacity;
        this.description = description;
        this.active = active;
        this.createdAt = createdAt;
    }

    public Long getResourceId() {
        return resourceId;
    }

    public void setResourceId(Long resourceId) {
        this.resourceId = resourceId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getResourceType() {
        return resourceType;
    }

    public void setResourceType(String resourceType) {
        this.resourceType = resourceType;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Resource{" +
                "resourceId=" + resourceId +
                ", name='" + name + '\'' +
                ", resourceType='" + resourceType + '\'' +
                ", location='" + location + '\'' +
                ", capacity=" + capacity +
                ", active=" + active +
                '}';
    }
}
