<%@ page import="java.sql.*" %>
<%@ page import="java.io.StringWriter, java.io.PrintWriter" %>

<%
    // Kết nối MySQL (đổi user/pass nếu khác)
    String JDBC_URL  = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String JDBC_USER = "root";
    String JDBC_PASS = "";

    int soSV = 0, soGV = 0, soMon = 0, soLop = 0;

    try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {
        // Đếm sinh viên (bảng sinhvien)
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM sinhvien");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) soSV = rs.getInt(1);
        }

        // Đếm giảng viên (bảng giangvien)
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM giangvien");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) soGV = rs.getInt(1);
        }

        // Đếm môn học (bảng monhoc)
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM monhoc");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) soMon = rs.getInt(1);
        }

        // Đếm lớp học (bảng lop)
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM lop");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) soLop = rs.getInt(1);
        }
        } catch (Exception e) {
            StringWriter sw = new StringWriter();
            e.printStackTrace(new PrintWriter(sw));   // hợp lệ vì dùng PrintWriter
            out.print("<pre>" + sw.toString() + "</pre>");
        }

%>


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | MONKEY</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/css/style.css">
<style>
    /* ==========================================================================
   MONKEY Admin – Global Styles
   Save as: BTL_JSP/WebContent/assets/css/style.css
   ========================================================================= */

/* ---------- CSS Variables (Theme) ---------- */
:root{
  --primary: #0B63E5;
  --primary-600: #0956c7;
  --primary-50: #eaf2ff;

  --bg: #f5f8fd;
  --card: #ffffff;
  --text: #1f2937;       /* gray-800 */
  --muted: #6b7280;      /* gray-500 */
  --border: #e5e7eb;     /* gray-200 */

  --success: #16a34a;
  --warning: #f59e0b;
  --danger:  #ef4444;

  --radius-lg: 16px;
  --radius-md: 12px;
  --radius-sm: 8px;

  --shadow-sm: 0 1px 2px rgba(0,0,0,.06);
  --shadow-md: 0 6px 20px rgba(2, 13, 41, .08);

  --space-xs: .375rem;
  --space-sm: .625rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;

  --sidebar-w: 260px;
  --header-h: 68px;
}

/* ---------- CSS Reset / Base ---------- */
*{ box-sizing: border-box; }
html,body{ height:100%; }
body{
  margin:0;
  color:var(--text);
  background:var(--bg);
  font: 15px/1.55 "Segoe UI", Roboto, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
img{ max-width:100%; display:block; }
a{ color:inherit; text-decoration: none; }
hr{ border:none; border-top:1px solid var(--border); margin: var(--space-sm) 0; }

/* Scrollbar (nice but subtle) */
*::-webkit-scrollbar{ width:10px; height:10px; }
*::-webkit-scrollbar-thumb{ background:#cbd5e1; border-radius:10px; }
*::-webkit-scrollbar-thumb:hover{ background:#94a3b8; }

/* ==========================================================================
   Layout
   ========================================================================== */

/* ----- Sidebar ----- */
.sidebar{
  position: fixed; inset: 0 auto 0 0;
  width: var(--sidebar-w);
  background: var(--card);
  border-right: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
  z-index: 1000;
  display: flex; flex-direction: column;
  transform: translateX(0);
  transition: transform .25s ease;
}
.sidebar-header{
  display:flex; align-items:center; gap: var(--space-sm);
  padding: var(--space-md) var(--space-md);
  min-height: 64px;
  border-bottom:1px solid var(--border);
}
.sidebar-logo{
  display:flex; align-items:center; gap:.625rem; font-weight:600;
}
.sidebar-logo img{ width:36px; height:36px; object-fit:contain; }
.btn-close-sidebar{ margin-left:auto; }

.sidebar-content{
  padding: var(--space-md);
  overflow:auto;
}

.nav-section-title{
  margin: var(--space-md) var(--space-sm) var(--space-sm);
  color: var(--muted);
  font-size:.8rem; text-transform: uppercase; letter-spacing:.04em;
}

.nav-list{ list-style:none; padding:0; margin:0; }
.nav-item{ margin-bottom: .25rem; }
.nav-link{
  display:flex; align-items:center; gap:.75rem;
  padding:.625rem .75rem;
  border-radius: var(--radius-sm);
  color:#334155;
  transition: background .15s ease, color .15s ease, transform .06s ease;
}
.nav-link .material-icons-outlined{ font-size:20px; color:#64748b; }
.nav-link:hover{
  background: var(--primary-50);
  color: var(--primary);
}
.nav-link.active{
  background: var(--primary);
  color: #fff;
  box-shadow: 0 6px 14px rgba(11, 99, 229, .22);
}
.nav-link.active .material-icons-outlined{ color:#fff; }

/* ----- Main Content ----- */
.main-content{
  margin-left: var(--sidebar-w);
  min-height:100vh;
  display:flex; flex-direction:column;
  transition: margin-left .25s ease;
}

/* ----- Header ----- */
.main-header{
  position: sticky; top:0; z-index:900;
  display:flex; align-items:center; justify-content:space-between;
  height: var(--header-h);
  padding: 0 var(--space-lg);
  background: var(--card);
  border-bottom: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
}
.header-left{ display:flex; align-items:center; gap: var(--space-md); }
.page-title{ font-size:1.25rem; margin:0; }
.header-right{ display:flex; align-items:center; gap: var(--space-md); }

/* ----- Buttons / Icon Buttons ----- */
.btn-icon{
  display:inline-flex; align-items:center; justify-content:center;
  width:38px; height:38px; border-radius:10px;
  border:1px solid var(--border);
  background:#fff; box-shadow: var(--shadow-sm);
  cursor:pointer; transition: transform .06s ease, border-color .15s ease;
}
.btn-icon:hover{ border-color:#cbd5e1; }
.btn-icon:active{ transform: translateY(1px); }

.btn-open-sidebar{ display:none; } /* shown on mobile via media query */

/* ----- User Profile Dropdown ----- */
.user-profile-dropdown{ position:relative; }
.user-profile-btn{
  display:flex; align-items:center; gap:.5rem;
  padding:.25rem .5rem; border-radius: 999px;
  border:1px solid var(--border); background:#fff; cursor:pointer;
}
.avatar{
  width:28px; height:28px; border-radius:50%; object-fit:cover;
}
.dropdown-content{
  position:absolute; right:0; top:calc(100% + 8px);
  width:220px; background:#fff; border:1px solid var(--border);
  border-radius: var(--radius-md); box-shadow: var(--shadow-md);
  padding: .5rem; display:none;
}
.user-profile-dropdown:focus-within .dropdown-content,
.user-profile-dropdown.open .dropdown-content{ display:block; }

.dropdown-user-info{ padding:.25rem .5rem .5rem; }
.dropdown-content a{
  display:flex; align-items:center; gap:.5rem;
  padding:.5rem .5rem; border-radius:8px; color:#334155;
}
.dropdown-content a:hover{ background:#f8fafc; }

/* ----- Page Content Wrapper ----- */
.page-content-wrapper{
  padding: var(--space-lg);
  display:flex; flex-direction:column; gap: var(--space-lg);
}
.section-title{
  font-size:1.1rem; margin:0 0 var(--space-sm) 0;
}

/* ----- Cards / Grids ----- */
.card{
  background: var(--card);
  border:1px solid var(--border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  padding: var(--space-lg);
}

.card-grid-summary{
  display:grid;
  grid-template-columns: repeat(4, minmax(0,1fr));
  gap: var(--space-lg);
}
.summary-card{
  background: var(--card);
  border:1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: var(--space-lg);
  box-shadow: var(--shadow-sm);
  position:relative; overflow:hidden;
}
.summary-title{ display:block; color:var(--muted); margin-bottom:.35rem; }
.summary-value{
  font-size:2rem; font-weight:700; letter-spacing:.02em;
}
.summary-card::after{
  content:""; position:absolute; inset:auto -40px -40px auto;
  width:160px; height:160px; border-radius:50%;
  background: radial-gradient(closest-side, rgba(11,99,229,.18), transparent 70%);
}
.summary-value.gpa{ color: var(--primary); }

/* ----- Sidebar Overlay (mobile) ----- */
.sidebar-overlay{
  position: fixed; inset:0;
  background: rgba(2, 6, 23, .45);
  z-index: 900; opacity:0; visibility:hidden;
  transition: opacity .25s ease, visibility .25s ease;
}

/* When sidebar is open on mobile, add the class .sidebar-open to body */
body.sidebar-open .sidebar{ transform: translateX(0); }
body.sidebar-open .sidebar-overlay{ opacity:1; visibility:visible; }

/* ==========================================================================
   Utilities
   ========================================================================== */
.badge{
  display:inline-block; padding:.2rem .5rem; font-size:.75rem;
  border-radius:999px; background:#eef2ff; color:var(--primary);
}
.text-muted{ color: var(--muted); }

/* ==========================================================================
   Responsive
   ========================================================================== */

/* <= 1200px: 3 columns summary */
@media (max-width: 1200px){
  .card-grid-summary{ grid-template-columns: repeat(3, minmax(0,1fr)); }
}

/* <= 992px: 2 columns summary, tighter header padding */
@media (max-width: 992px){
  .main-header{ padding: 0 var(--space-md); }
  .card-grid-summary{ grid-template-columns: repeat(2, minmax(0,1fr)); }
}

/* <= 768px: mobile drawer sidebar, 1 column summary */
@media (max-width: 768px){
  .btn-open-sidebar{ display:inline-flex; }
  .btn-close-sidebar{ display:inline-flex; }

  .sidebar{
    transform: translateX(-100%);
    box-shadow: 0 0 0 rgba(0,0,0,0); /* remove shadow when closed */
  }
  body.sidebar-open .sidebar{
    transform: translateX(0);
    box-shadow: var(--shadow-md);
  }

  .main-content{ margin-left: 0; }
  .card-grid-summary{ grid-template-columns: 1fr; }
}

/* ==========================================================================
   States / Small Interactions
   ========================================================================== */
.nav-link:active{ transform: translateY(1px); }
.nav-link:focus-visible, .btn-icon:focus-visible, .user-profile-btn:focus-visible{
  outline: 3px solid rgba(11,99,229,.35);
  outline-offset: 2px;
}

/* Notifications dot (if needed) */
.btn-icon[data-has="notif"]{
  position:relative;
}
.btn-icon[data-has="notif"]::after{
  content:""; position:absolute; top:6px; right:6px;
  width:8px; height:8px; border-radius:50%; background: var(--danger);
  box-shadow: 0 0 0 2px #fff;
}

</style>



    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
</head>
<body>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <a href="admin_dashboard.jsp" class="sidebar-logo">
            </a>
            <button class="btn-icon btn-close-sidebar" aria-label="Đóng menu" id="close-sidebar">
                <span class="material-icons-outlined">close</span>
            </button>
        </div>

        <div class="sidebar-content">
            <ul class="nav-list" role="menu">
                
                <li class="nav-item" role="menuitem">
                    <a href="admin_dashboard.jsp" class="nav-link active" aria-current="page">
                        <span class="material-icons-outlined">admin_panel_settings</span>
                        <span>Trang chủ Admin</span>
                    </a>
                </li>
                
                <li class="nav-section-title">Quản lý</li>

                <li class="nav-item" role="menuitem">
                    <a href="admin_qlsv.jsp" class="nav-link">
                        <span class="material-icons-outlined">school</span>
                        <span>Quản lý Sinh viên</span>
                    </a>
                </li>

                <li class="nav-item" role="menuitem">
                    <a href="admin_qlgv.jsp" class="nav-link">
                        <span class="material-icons-outlined">account_box</span>
                        <span>Quản lý Giảng viên</span>
                    </a>
                </li>
                
                <li class="nav-item" role="menuitem">
                    <a href="admin_qlmh.jsp" class="nav-link">
                        <span class="material-icons-outlined">book</span>
                        <span>Quản lý Môn học</span>
                    </a>
                </li>

                <li class="nav-item" role="menuitem">
                    <a href="admin_qllop.jsp" class="nav-link">
                        <span class="material-icons-outlined">corporate_fare</span>
                        <span>Quản lý Khoa/Lớp</span>
                    </a>
                </li>
                
                <li class="nav-section-title">Nghiệp vụ</li>

                <li class="nav-item" role="menuitem">
                    <a href="admin_xemdiem.jsp" class="nav-link">
                        <span class="material-icons-outlined">grade</span>
                        <span>Quản Lý Điểm</span>
                    </a>
                </li>

                 <li class="nav-item" role="menuitem">
                    <a href="admin_bctk.jsp" class="nav-link">
                        <span class="material-icons-outlined">assessment</span>
                        <span>Báo cáo Thống kê</span>
                    </a>
                </li>
            </ul>
        </div>
    </nav>

    <main class="main-content">
        <header class="main-header">
            <div class="header-left">
                <button class="btn-icon btn-open-sidebar" aria-label="Mở menu" id="open-sidebar">
                    <span class="material-icons-outlined">menu</span>
                </button>
                <h1 class="page-title">Trang chủ Admin</h1>
            </div>
            
            <div class="header-right">
                <button class="btn-icon" aria-label="Thông báo">
                    <span class="material-icons-outlined">notifications</span>
                </button>

                <div class="user-profile-dropdown">
                    <button class="user-profile-btn" aria-label="Tài khoản">
                        <span>Adminstrator</span> 
                        <span class="material-icons-outlined">expand_more</span>
                    </button>
                    <div class="dropdown-content">
                        <div class="dropdown-user-info">
                            <strong>Adminstrator</strong>
                            <span>Quản trị hệ thống</span>
                        </div>
                        <a href="#"><span class="material-icons-outlined">settings</span>Cài đặt</a>
                        <a href="change_password.jsp"><span class="material-icons-outlined">lock</span>Đổi mật khẩu</a>
                        <hr>
                        <a href="../../dangnhap.jsp" class="dropdown-logout"><span class="material-icons-outlined">logout</span>Đăng xuất</a>
                    </div>
                </div>
            </div>
        </header>

        <div class="page-content-wrapper">
            
            <h2 class="section-title" style="margin-left: 0;">Tổng quan Hệ thống</h2>
            <section class="card-grid-summary">
                <div class="summary-card">
                    <span class="summary-title">Số lượng Sinh viên</span>
                    <span class="summary-value gpa"><%= soSV %></span>
                </div>
                <div class="summary-card">
                    <span class="summary-title">Số lượng Giảng viên</span>
                    <span class="summary-value"><%= soGV %></span>
                </div>
                <div class="summary-card">
                    <span class="summary-title">Số lượng Môn học</span>
                    <span class="summary-value"><%= soMon %></span>
                </div>
                <div class="summary-card">
                    <span class="summary-title">Số lượng Lớp học</span>
                    <span class="summary-value"><%= soLop %></span>
                </div>
            </section>


            <section class="card">
                 <h2 class="section-title" style="margin: 0 0 var(--space-md) 0;">Chào mừng Admin!</h2>
                 <p>Đây là trang quản trị hệ thống MONKEY. Bạn có thể sử dụng menu bên trái để truy cập các chức năng quản lý.</p>
            </section>

        </div>
    </main>

    <div class="sidebar-overlay" id="sidebar-overlay"></div>
    <script src="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/js/main.js"></script>

</body>
</html>