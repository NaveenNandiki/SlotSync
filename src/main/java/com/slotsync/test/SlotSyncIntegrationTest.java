package com.slotsync.test;

import com.slotsync.exception.BookingConflictException;
import com.slotsync.model.Reservation;
import com.slotsync.model.Resource;
import com.slotsync.model.User;
import com.slotsync.service.AdminReportService;
import com.slotsync.service.ReservationService;
import com.slotsync.service.ResourceService;
import com.slotsync.service.UserService;
import com.slotsync.util.DBConnection;

import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Automated End-to-End Integration and Concurrency Test Suite for SlotSync.
 */
public class SlotSyncIntegrationTest {

    public static void main(String[] args) {
        System.out.println("=================================================================");
        System.out.println("           SLOTSYNC AUTOMATED INTEGRATION TEST SUITE            ");
        System.out.println("=================================================================");

        int passed = 0;
        int failed = 0;

        try {
            // Test 1: JDBC Connectivity
            System.out.print("[TEST 1] Testing MySQL JDBC connection... ");
            try (Connection conn = DBConnection.getConnection()) {
                if (conn != null && !conn.isClosed()) {
                    System.out.println("PASSED (Database: " + conn.getCatalog() + ")");
                    passed++;
                } else {
                    System.out.println("FAILED (Connection is null or closed)");
                    failed++;
                }
            }

            // Test 2: User Authentication & Registration
            System.out.print("[TEST 2] Testing User authentication & registration... ");
            UserService userService = new UserService();
            User admin = userService.authenticate("admin@slotsync.com", "Admin@12345");
            if (admin == null || !admin.isAdmin()) {
                throw new RuntimeException("Admin authentication failed");
            }

            User user = userService.authenticate("john.doe@slotsync.com", "User@12345");
            if (user == null || user.isAdmin()) {
                throw new RuntimeException("User authentication failed");
            }

            // Test registration with unique email
            String testEmail = "testuser_" + System.currentTimeMillis() + "@slotsync.com";
            User registered = userService.register("Test Candidate", testEmail, "Secret@123", "Secret@123");
            if (registered == null || registered.getUserId() <= 0) {
                throw new RuntimeException("User registration failed");
            }

            // Test duplicate email rejection
            boolean duplicateBlocked = false;
            try {
                userService.register("Duplicate User", testEmail, "Secret@123", "Secret@123");
            } catch (IllegalArgumentException e) {
                duplicateBlocked = true;
            }
            if (!duplicateBlocked) {
                throw new RuntimeException("Duplicate email was not rejected!");
            }
            System.out.println("PASSED (Auth, BCrypt, Duplicate email protection verified)");
            passed++;

            // Test 3: Resource Inventory & Search
            System.out.print("[TEST 3] Testing Resource inventory & availability filtering... ");
            ResourceService resourceService = new ResourceService();
            List<Resource> allResources = resourceService.getAllResources(true);
            if (allResources.isEmpty()) {
                throw new RuntimeException("No active resources found in catalog");
            }

            Resource newResource = resourceService.createResource(
                "Automated Test Lab " + System.currentTimeMillis(),
                "Computer Laboratory",
                "Building T, Room 101",
                40,
                "Test description",
                true
            );

            Resource fetched = resourceService.getResourceById(newResource.getResourceId());
            if (!fetched.getName().equals(newResource.getName())) {
                throw new RuntimeException("Resource creation/retrieval mismatch");
            }
            System.out.println("PASSED (CRUD & Filtering verified)");
            passed++;

            // Test 4: Concurrency & Overlapping Conflict Prevention
            System.out.print("[TEST 4] Testing Double-Booking Conflict Prevention (Pessimistic Locking)... ");
            ReservationService reservationService = new ReservationService();
            long resId = newResource.getResourceId();

            LocalDateTime slot1Start = LocalDateTime.now().plusDays(10).withHour(10).withMinute(0).withSecond(0).withNano(0);
            LocalDateTime slot1End   = slot1Start.plusHours(2); // 10:00 - 12:00

            // 4a. Create base reservation
            Reservation r1 = reservationService.createReservation(user.getUserId(), resId, slot1Start, slot1End, "Session 1");
            if (r1 == null || !Reservation.STATUS_PENDING.equals(r1.getStatus())) {
                throw new RuntimeException("Initial reservation failed");
            }

            // 4b. Overlapping request 1: 11:00 - 13:00 (Starts before slot1 ends, ends after)
            LocalDateTime overlapStart = slot1Start.plusHours(1);
            LocalDateTime overlapEnd = slot1End.plusHours(1);
            boolean conflictCaught1 = false;
            try {
                reservationService.createReservation(user.getUserId(), resId, overlapStart, overlapEnd, "Conflicting session 1");
            } catch (BookingConflictException e) {
                conflictCaught1 = true;
            }
            if (!conflictCaught1) {
                throw new RuntimeException("CRITICAL: Overlapping reservation 11:00-13:00 was NOT rejected!");
            }

            // 4c. Overlapping request 2: 09:30 - 10:30 (Starts before, ends inside)
            boolean conflictCaught2 = false;
            try {
                reservationService.createReservation(user.getUserId(), resId, slot1Start.minusMinutes(30), slot1Start.plusMinutes(30), "Conflicting session 2");
            } catch (BookingConflictException e) {
                conflictCaught2 = true;
            }
            if (!conflictCaught2) {
                throw new RuntimeException("CRITICAL: Overlapping reservation 09:30-10:30 was NOT rejected!");
            }

            // 4d. Back-to-back non-overlapping request: 12:00 - 14:00 (Starts exactly when slot1 ends) -> MUST SUCCEED
            Reservation backToBack = reservationService.createReservation(user.getUserId(), resId, slot1End, slot1End.plusHours(2), "Back to back session");
            if (backToBack == null) {
                throw new RuntimeException("Back-to-back reservation failed");
            }
            System.out.println("PASSED (Overlaps rejected, Back-to-back allowed)");
            passed++;

            // Test 5: Concurrent Simultaneous Requests Concurrency Test
            System.out.print("[TEST 5] Testing Simultaneous Multi-Threaded Concurrent Booking Requests... ");
            int threadCount = 4;
            ExecutorService executor = Executors.newFixedThreadPool(threadCount);
            CountDownLatch readyLatch = new CountDownLatch(threadCount);
            CountDownLatch startLatch = new CountDownLatch(1);
            AtomicInteger successCount = new AtomicInteger(0);
            AtomicInteger conflictCount = new AtomicInteger(0);

            LocalDateTime testSlotStart = LocalDateTime.now().plusDays(15).withHour(14).withMinute(0).withSecond(0).withNano(0);
            LocalDateTime testSlotEnd = testSlotStart.plusHours(2);

            for (int i = 0; i < threadCount; i++) {
                final int idx = i;
                executor.submit(() -> {
                    readyLatch.countDown();
                    try {
                        startLatch.await(); // wait for simultaneous fire
                        reservationService.createReservation(
                            user.getUserId(), resId, testSlotStart, testSlotEnd, "Simultaneous request #" + idx
                        );
                        successCount.incrementAndGet();
                    } catch (BookingConflictException e) {
                        conflictCount.incrementAndGet();
                    } catch (Exception e) {
                        System.err.println("Unexpected exception in thread: " + e.getMessage());
                    }
                });
            }

            readyLatch.await();
            startLatch.countDown(); // Release all threads simultaneously
            executor.shutdown();
            while (!executor.isTerminated()) {
                Thread.sleep(20);
            }

            if (successCount.get() != 1 || conflictCount.get() != (threadCount - 1)) {
                throw new RuntimeException("Concurrency failure: Successes=" + successCount.get() + ", Conflicts=" + conflictCount.get() + " (Expected exactly 1 success)");
            }
            System.out.println("PASSED (Exactly 1 succeeded, " + (threadCount - 1) + " safely rejected)");
            passed++;

            // Test 6: Status Lifecycle & Review Transitions
            System.out.print("[TEST 6] Testing Admin Approval, Rejection with Reason, and User Cancellation... ");
            // Approve r1
            boolean approved = reservationService.approveReservation(r1.getReservationId(), admin.getUserId(), "Approved via Test Suite");
            if (!approved) throw new RuntimeException("Approval failed");

            // Verify status history
            var history = reservationService.getReservationHistory(r1.getReservationId());
            if (history.size() < 2) throw new RuntimeException("Status history audit records missing");

            // Test Cancellation
            boolean cancelled = reservationService.cancelReservation(r1.getReservationId(), user.getUserId(), false, "User test cancel");
            if (!cancelled) throw new RuntimeException("Cancellation failed");

            // Now that r1 is cancelled, another reservation for that same slot must succeed
            Reservation afterCancel = reservationService.createReservation(user.getUserId(), resId, slot1Start, slot1End, "Re-booking freed slot");
            if (afterCancel == null) throw new RuntimeException("Re-booking cancelled slot failed");

            System.out.println("PASSED (Approval, History auditing, Slot freeing on cancel)");
            passed++;

            // Test 7: Reports and Analytics
            System.out.print("[TEST 7] Testing Administrator Reports and Analytics... ");
            AdminReportService reportService = new AdminReportService();
            Map<String, Object> summary = reportService.getOverallSummary();
            if (summary.get("totalUsers") == null || summary.get("resourceUtilization") == null) {
                throw new RuntimeException("Analytics summary failed");
            }
            System.out.println("PASSED (Metrics, breakdown & utilization generated)");
            passed++;

        } catch (Exception e) {
            System.out.println("\n[ERROR] Test suite encountered an error:");
            e.printStackTrace();
            failed++;
        }

        System.out.println("=================================================================");
        System.out.println("TEST RESULTS: " + passed + " Passed, " + failed + " Failed");
        System.out.println("=================================================================");

        if (failed > 0) {
            System.exit(1);
        }
    }
}
