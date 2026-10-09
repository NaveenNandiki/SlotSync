package com.slotsync.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * ReservationStatusHistory entity tracking audit history of status changes.
 */
public class ReservationStatusHistory implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long historyId;
    private Long reservationId;
    private Long changedBy;
    private String oldStatus;
    private String newStatus;
    private String reason;
    private LocalDateTime changedAt;

    // Joined fields
    private String changedByName;

    public ReservationStatusHistory() {}

    public ReservationStatusHistory(Long historyId, Long reservationId, Long changedBy,
                                    String oldStatus, String newStatus, String reason,
                                    LocalDateTime changedAt) {
        this.historyId = historyId;
        this.reservationId = reservationId;
        this.changedBy = changedBy;
        this.oldStatus = oldStatus;
        this.newStatus = newStatus;
        this.reason = reason;
        this.changedAt = changedAt;
    }

    public Long getHistoryId() {
        return historyId;
    }

    public void setHistoryId(Long historyId) {
        this.historyId = historyId;
    }

    public Long getReservationId() {
        return reservationId;
    }

    public void setReservationId(Long reservationId) {
        this.reservationId = reservationId;
    }

    public Long getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(Long changedBy) {
        this.changedBy = changedBy;
    }

    public String getOldStatus() {
        return oldStatus;
    }

    public void setOldStatus(String oldStatus) {
        this.oldStatus = oldStatus;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        this.newStatus = newStatus;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public LocalDateTime getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(LocalDateTime changedAt) {
        this.changedAt = changedAt;
    }

    public String getChangedByName() {
        return changedByName;
    }

    public void setChangedByName(String changedByName) {
        this.changedByName = changedByName;
    }

    @Override
    public String toString() {
        return "ReservationStatusHistory{" +
                "historyId=" + historyId +
                ", reservationId=" + reservationId +
                ", oldStatus='" + oldStatus + '\'' +
                ", newStatus='" + newStatus + '\'' +
                ", changedAt=" + changedAt +
                '}';
    }
}
