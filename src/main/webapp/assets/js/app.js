/**
 * SlotSync — Frontend JavaScript Helpers
 * Accessible, lightweight client-side interactions.
 */

document.addEventListener('DOMContentLoaded', () => {
    // 1. Mobile Sidebar Toggle
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    const appSidebar = document.getElementById('appSidebar');

    if (mobileMenuBtn && appSidebar) {
        mobileMenuBtn.addEventListener('click', () => {
            appSidebar.classList.toggle('open');
        });

        // Close when clicking outside
        document.addEventListener('click', (e) => {
            if (!appSidebar.contains(e.target) && !mobileMenuBtn.contains(e.target) && appSidebar.classList.contains('open')) {
                appSidebar.classList.remove('open');
            }
        });
    }

    // 2. Auto-dismiss alerts after 6 seconds
    const dismissibleAlerts = document.querySelectorAll('.alert-auto-dismiss');
    dismissibleAlerts.forEach(alert => {
        setTimeout(() => {
            alert.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
            alert.style.opacity = '0';
            alert.style.transform = 'translateY(-8px)';
            setTimeout(() => alert.remove(), 400);
        }, 6000);
    });

    // 3. Date & Time booking helper
    const startTimeInput = document.getElementById('startTime');
    const endTimeInput = document.getElementById('endTime');

    if (startTimeInput && endTimeInput) {
        // Set min date to current time
        const now = new Date();
        now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
        const minIso = now.toISOString().slice(0, 16);
        startTimeInput.min = minIso;

        startTimeInput.addEventListener('change', () => {
            if (startTimeInput.value) {
                // Ensure end time min is at least start time
                endTimeInput.min = startTimeInput.value;

                // If end time is blank or before start time, set end time to start time + 1 hour
                if (!endTimeInput.value || endTimeInput.value <= startTimeInput.value) {
                    const startDt = new Date(startTimeInput.value);
                    startDt.setHours(startDt.getHours() + 1);
                    endTimeInput.value = startDt.toISOString().slice(0, 16);
                }
            }
        });
    }

    // 4. Modal Helpers
    window.openModal = function(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.add('active');
            document.body.style.overflow = 'hidden';
        }
    };

    window.closeModal = function(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.classList.remove('active');
            document.body.style.overflow = '';
        }
    };

    // Close modal on Escape or clicking backdrop
    document.querySelectorAll('.modal-overlay').forEach(modal => {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.classList.remove('active');
                document.body.style.overflow = '';
            }
        });
    });

    // 5. Rejection Modal Helper
    window.openRejectModal = function(reservationId, resourceName) {
        const idInput = document.getElementById('rejectReservationId');
        const nameSpan = document.getElementById('rejectResourceName');
        if (idInput) idInput.value = reservationId;
        if (nameSpan) nameSpan.textContent = resourceName || ('#' + reservationId);
        openModal('rejectModal');
    };

    // 6. Cancellation Modal Helper
    window.openCancelModal = function(reservationId, resourceName) {
        const idInput = document.getElementById('cancelReservationId');
        const nameSpan = document.getElementById('cancelResourceName');
        if (idInput) idInput.value = reservationId;
        if (nameSpan) nameSpan.textContent = resourceName || ('#' + reservationId);
        openModal('cancelModal');
    };
});
