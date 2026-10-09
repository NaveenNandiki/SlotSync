package com.slotsync.service;

import com.slotsync.dao.UserDAO;
import com.slotsync.model.User;
import com.slotsync.util.PasswordUtil;
import com.slotsync.util.ValidationUtil;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Service handling user authentication, registration, and profile management.
 */
public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    /**
     * Registers a standard USER account.
     * Public registration strictly assigns ROLE_USER.
     */
    public User register(String fullName, String email, String password, String confirmPassword) throws IllegalArgumentException {
        if (!ValidationUtil.isValidName(fullName)) {
            throw new IllegalArgumentException("Full name must be between 2 and 100 characters.");
        }
        if (!ValidationUtil.isValidEmail(email)) {
            throw new IllegalArgumentException("Please provide a valid email address.");
        }
        if (!ValidationUtil.isValidPassword(password)) {
            throw new IllegalArgumentException("Password must be at least 6 characters in length.");
        }
        if (confirmPassword == null || !password.equals(confirmPassword)) {
            throw new IllegalArgumentException("Passwords do not match.");
        }

        if (userDAO.emailExists(email)) {
            throw new IllegalArgumentException("An account with this email address already exists.");
        }

        String passwordHash = PasswordUtil.hashPassword(password);

        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setPasswordHash(passwordHash);
        user.setRole(User.ROLE_USER);
        user.setActive(true);
        user.setCreatedAt(LocalDateTime.now());

        boolean created = userDAO.create(user);
        if (!created) {
            throw new RuntimeException("Failed to create user account due to a database error.");
        }

        return user;
    }

    /**
     * Authenticates a user with email and password.
     */
    public User authenticate(String email, String password) {
        if (!ValidationUtil.isNotBlank(email) || !ValidationUtil.isNotBlank(password)) {
            return null;
        }

        User user = userDAO.findByEmail(email.trim());
        if (user == null || !user.isActive()) {
            return null;
        }

        if (PasswordUtil.checkPassword(password, user.getPasswordHash())) {
            return user;
        }

        return null;
    }

    public User getUserById(long userId) {
        return userDAO.findById(userId);
    }

    public User getUserByEmail(String email) {
        return userDAO.findByEmail(email);
    }

    public List<User> getAllUsers() {
        return userDAO.findAll();
    }

    public int getTotalUsersCount() {
        return userDAO.countUsers();
    }
}
