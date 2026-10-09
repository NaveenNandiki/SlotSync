package com.slotsync.exception;

/**
 * Thrown when reservation details (times, purpose, state transitions) violate business rules.
 */
public class InvalidReservationException extends Exception {
    private static final long serialVersionUID = 1L;

    public InvalidReservationException(String message) {
        super(message);
    }

    public InvalidReservationException(String message, Throwable cause) {
        super(message, cause);
    }
}
