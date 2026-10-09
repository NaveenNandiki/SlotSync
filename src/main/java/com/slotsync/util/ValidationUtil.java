package com.slotsync.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.regex.Pattern;

/**
 * Common input validation and formatting utility for SlotSync.
 */
public final class ValidationUtil {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$"
    );

    private static final DateTimeFormatter HTML5_DATETIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    private static final DateTimeFormatter DISPLAY_DATETIME_FORMAT = DateTimeFormatter.ofPattern("MMM dd, yyyy hh:mm a");
    private static final DateTimeFormatter DISPLAY_DATE_FORMAT = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    private static final DateTimeFormatter DISPLAY_TIME_FORMAT = DateTimeFormatter.ofPattern("hh:mm a");
    private static final DateTimeFormatter SQL_DATETIME_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private ValidationUtil() {}

    public static boolean isNotBlank(String str) {
        return str != null && !str.trim().isEmpty();
    }

    public static boolean isValidEmail(String email) {
        if (!isNotBlank(email)) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidPassword(String password) {
        return isNotBlank(password) && password.length() >= 6;
    }

    public static boolean isValidName(String name) {
        return isNotBlank(name) && name.trim().length() >= 2 && name.trim().length() <= 100;
    }

    public static LocalDateTime parseDateTime(String input) {
        if (!isNotBlank(input)) {
            return null;
        }
        String trimmed = input.trim();
        try {
            if (trimmed.contains("T")) {
                return LocalDateTime.parse(trimmed, HTML5_DATETIME_FORMAT);
            } else if (trimmed.length() == 16) {
                return LocalDateTime.parse(trimmed, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            } else {
                return LocalDateTime.parse(trimmed, SQL_DATETIME_FORMAT);
            }
        } catch (DateTimeParseException e) {
            try {
                return LocalDateTime.parse(trimmed);
            } catch (Exception ex) {
                return null;
            }
        }
    }

    public static String formatForInput(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        return dateTime.format(HTML5_DATETIME_FORMAT);
    }

    public static String formatDisplay(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        return dateTime.format(DISPLAY_DATETIME_FORMAT);
    }

    public static String formatDisplayDate(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        return dateTime.format(DISPLAY_DATE_FORMAT);
    }

    public static String formatDisplayTime(LocalDateTime dateTime) {
        if (dateTime == null) return "";
        return dateTime.format(DISPLAY_TIME_FORMAT);
    }

    public static String escapeHtml(String input) {
        if (input == null) return "";
        StringBuilder sb = new StringBuilder(input.length() + 16);
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '&': sb.append("&amp;"); break;
                case '"': sb.append("&quot;"); break;
                case '\'': sb.append("&#x27;"); break;
                default: sb.append(c); break;
            }
        }
        return sb.toString();
    }

    public static long parseLong(String str, long defaultValue) {
        if (!isNotBlank(str)) return defaultValue;
        try {
            return Long.parseLong(str.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static int parseInt(String str, int defaultValue) {
        if (!isNotBlank(str)) return defaultValue;
        try {
            return Integer.parseInt(str.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
