package com.slotsync.exception;

/**
 * Thrown when a reservation request conflicts with an existing overlapping reservation.
 */
public class BookingConflictException extends Exception {
    private static final long serialVersionUID = 1L;

    public BookingConflictException(String message) {
        super(message);
    }

    public BookingConflictException(String message, Throwable cause) {
        super(message, cause);
    }
}
