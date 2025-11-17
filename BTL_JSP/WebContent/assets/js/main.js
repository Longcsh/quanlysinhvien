// --- Xử lý khi DOM đã sẵn sàng ---
document.addEventListener('DOMContentLoaded', () => {
    // 🔹 Các phần tử sidebar
    const openBtn = document.getElementById('open-sidebar');
    const closeBtn = document.getElementById('close-sidebar');
    const overlay = document.getElementById('sidebar-overlay');
    const sidebar = document.getElementById('sidebar');

    // 🔹 Mở / đóng sidebar
    const openSidebar = () => {
        document.body.classList.add('sidebar-open');
    };

    const closeSidebar = () => {
        document.body.classList.remove('sidebar-open');
    };

    if (openBtn) openBtn.addEventListener('click', openSidebar);
    if (closeBtn) closeBtn.addEventListener('click', closeSidebar);
    if (overlay) overlay.addEventListener('click', closeSidebar);

    // ===================================================================
    // 1️⃣ Xử lý MỞ / ĐÓNG các submenu trong sidebar
    // ===================================================================
    const submenuToggles = document.querySelectorAll('.nav-link-toggle');
    submenuToggles.forEach(toggle => {
        toggle.addEventListener('click', (e) => {
            e.preventDefault();
            const parentItem = toggle.closest('.has-submenu'); // ✅ FIXED
            if (parentItem) {
                parentItem.classList.toggle('is-open');
            }
        });
    });

    // ===================================================================
    // 2️⃣ Xử lý Dropdown thông tin người dùng (avatar)
    // ===================================================================
    const userDropdown = document.querySelector('.user-profile-dropdown');
    const userDropdownBtn = document.querySelector('.user-profile-btn');

    if (userDropdownBtn) {
        userDropdownBtn.addEventListener('click', (e) => {
            e.stopPropagation(); // tránh việc click lan ra document
            userDropdown.classList.toggle('is-open');
        });
    }

    // 🔹 Đóng dropdown khi bấm ra ngoài
    document.addEventListener('click', (e) => {
        if (userDropdown && !userDropdown.contains(e.target)) {
            userDropdown.classList.remove('is-open');
        }
    });

    // ===================================================================
    // 5️⃣ HÀM XÁC NHẬN HÀNH ĐỘNG DÙNG CHUNG (Đăng ký / Hủy / Xóa ...)
    // ===================================================================
    window.confirmAction = function (url, msg) {
        const confirmed = confirm(msg);
        if (confirmed) {
            // Chuyển hướng sang URL xử lý (JSP)
            window.location.href = url;
        }
    };

    // ===================================================================
    // 6️⃣ TỰ ĐỘNG ẨN THÔNG BÁO (NẾU JSP CÓ ALERT DIV)
    // ===================================================================
    const toast = document.querySelector(".toast-message");
    if (toast) {
        setTimeout(() => {
            toast.classList.add("fade-out");
            setTimeout(() => toast.remove(), 500);
        }, 4000);
    }
});
