package com.slotsync.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Thread-safe Database Connection Utility for SlotSync.
 * Reads configuration from db.properties, environment variables, or fallback defaults.
 */
public final class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static final String DEFAULT_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/slotsync?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
    private static final String DEFAULT_USERNAME = "root";
    private static final String DEFAULT_PASSWORD = "Naveen@9989";

    private static String dbUrl;
    private static String dbUsername;
    private static String dbPassword;

    static {
        loadConfiguration();
    }

    private DBConnection() {}

    private static synchronized void loadConfiguration() {
        String driver = DEFAULT_DRIVER;
        String url = null;
        String username = null;
        String password = null;

        // 1. Try loading from db.properties in classpath
        try (InputStream is = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                driver = props.getProperty("db.driver", DEFAULT_DRIVER);
                url = props.getProperty("db.url");
                username = props.getProperty("db.username");
                password = props.getProperty("db.password");
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Unable to read db.properties, using fallback settings.", e);
        }

        // 2. Override with Environment Variables if present
        String envUrl = System.getenv("DB_URL");
        if (envUrl != null && !envUrl.trim().isEmpty()) {
            url = envUrl;
        }

        String envUsername = System.getenv("DB_USERNAME");
        if (envUsername != null && !envUsername.trim().isEmpty()) {
            username = envUsername;
        }

        String envPassword = System.getenv("DB_PASSWORD");
        if (envPassword != null && !envPassword.trim().isEmpty()) {
            password = envPassword;
        }

        // 3. Apply defaults if still null
        dbUrl = (url != null && !url.trim().isEmpty()) ? url : DEFAULT_URL;
        dbUsername = (username != null && !username.trim().isEmpty()) ? username : DEFAULT_USERNAME;
        dbPassword = (password != null) ? password : DEFAULT_PASSWORD;

        // Register JDBC Driver
        try {
            Class.forName(driver);
            LOGGER.info("MySQL JDBC Driver registered successfully.");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver class not found in classpath: " + driver, e);
            throw new RuntimeException("MySQL JDBC Driver not found", e);
        }
    }

    /**
     * Obtains a new JDBC Connection from DriverManager.
     * @return active java.sql.Connection
     * @throws SQLException if a connection cannot be established
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
    }

    /**
     * Safely rolls back a connection transaction.
     */
    public static void rollback(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error while rolling back transaction", e);
            }
        }
    }

    /**
     * Safely closes an AutoCloseable resource.
     */
    public static void closeQuietly(AutoCloseable resource) {
        if (resource != null) {
            try {
                resource.close();
            } catch (Exception ignored) {
            }
        }
    }
}
