package com.slotsync.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Reservation entity representing resource bookings and lifecycle statuses.
 */
public class Reservation implements Serializable {
    private static final long serialVersionUID = 1L;

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_APPROVED = "APPROVED";
    public static final String STATUS_REJECTED = "REJECTED";
    public static final String STATUS_CANCELLED = "CANCELLED";
    public static final String STATUS_COMPLETED = "COMPLETED";

    private Long reservationId;
    private Long userId;
    private Long resourceId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String purpose;
    private String status;
    private Long reviewedBy;
    private String reviewReason;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Joined fields for view rendering
    private String userName;
    private String userEmail;
    private String resourceName;
    private String resourceType;
    private String resourceLocation;
    private String reviewedByName;

    public Reservation() {
        this.status = STATUS_PENDING;
    }

    public Reservation(Long reservationId, Long userId, Long resourceId, LocalDateTime startTime, LocalDateTime endTime,
                       String purpose, String status, Long reviewedBy, String reviewReason,
                       LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.reservationId = reservationId;
        this.userId = userId;
        this.resourceId = resourceId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.purpose = purpose;
        this.status = status;
        this.reviewedBy = reviewedBy;
        this.reviewReason = reviewReason;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getReservationId() {
        return reservationId;
    }

    public void setReservationId(Long reservationId) {
        this.reservationId = reservationId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getResourceId() {
        return resourceId;
    }

    public void setResourceId(Long resourceId) {
        this.resourceId = resourceId;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Long getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(Long reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public String getReviewReason() {
        return reviewReason;
    }

    public void setReviewReason(String reviewReason) {
        this.reviewReason = reviewReason;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getResourceName() {
        return resourceName;
    }

    public void setResourceName(String resourceName) {
        this.resourceName = resourceName;
    }

    public String getResourceType() {
        return resourceType;
    }

    public void setResourceType(String resourceType) {
        this.resourceType = resourceType;
    }

    public String getResourceLocation() {
        return resourceLocation;
    }

    public void setResourceLocation(String resourceLocation) {
        this.resourceLocation = resourceLocation;
    }

    public String getReviewedByName() {
        return reviewedByName;
    }

    public void setReviewedByName(String reviewedByName) {
        this.reviewedByName = reviewedByName;
    }

    public boolean isPending() {
        return STATUS_PENDING.equalsIgnoreCase(this.status);
    }

    public boolean isApproved() {
        return STATUS_APPROVED.equalsIgnoreCase(this.status);
    }

    public boolean isRejected() {
        return STATUS_REJECTED.equalsIgnoreCase(this.status);
    }

    public boolean isCancelled() {
        return STATUS_CANCELLED.equalsIgnoreCase(this.status);
    }

    public boolean isCompleted() {
        return STATUS_COMPLETED.equalsIgnoreCase(this.status);
    }

    public boolean isCancellable() {
        // Can only cancel if PENDING or APPROVED and not already past start time
        if (isCancelled() || isRejected() || isCompleted()) {
            return false;
        }
        return startTime == null || startTime.isAfter(LocalDateTime.now());
    }

    @Override
    public String toString() {
        return "Reservation{" +
                "reservationId=" + reservationId +
                ", userId=" + userId +
                ", resourceId=" + resourceId +
                ", startTime=" + startTime +
                ", endTime=" + endTime +
                ", status='" + status + '\'' +
                '}';
    }
}
