
<%@ page import="java.sql.*, java.util.*" %>
<%
    String JDBC_URL  = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String JDBC_USER = "root";
    String JDBC_PASS = "";

    String showAdd = request.getParameter("showAdd");
    String editId  = request.getParameter("edit");
    String action  = request.getParameter("action");
    String MaSV    = request.getParameter("MaSV");

    try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {
        // ========================= CRUD =========================
        if (action != null) {
            request.setCharacterEncoding("UTF-8");

            if ("add".equals(action)) {
                String pMaSV   = request.getParameter("MaSV");
                String pHoTen  = request.getParameter("HoTen");
                String pNgay   = request.getParameter("NgaySinh");
                String pGT     = request.getParameter("GioiTinh");
                String pDiaChi = request.getParameter("DiaChi");
                String pSoDT   = request.getParameter("SoDT");
                String pEmail  = request.getParameter("Email");
                String pMaLop  = request.getParameter("MaLop");

                // --- Validate MaLop có tồn tại không (tránh vi phạm FK) ---
                boolean lopOk = true;
                if (pMaLop != null && !pMaLop.isBlank()) {
                    try (PreparedStatement ck = conn.prepareStatement("SELECT 1 FROM lop WHERE MaLop=?")) {
                        ck.setString(1, pMaLop);
                        try (ResultSet r = ck.executeQuery()) { lopOk = r.next(); }
                    }
                }
                if (!lopOk) {
                    response.sendRedirect(request.getRequestURI() + "?err=lop");
                    return;
                }

                try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO sinhvien (MaSV,HoTen,NgaySinh,GioiTinh,DiaChi,SoDT,Email,MaLop) VALUES (?,?,?,?,?,?,?,?)")) {

                    ps.setString(1, pMaSV);
                    ps.setString(2, pHoTen);

                    if (pNgay != null && !pNgay.isBlank())
                        ps.setDate(3, java.sql.Date.valueOf(pNgay)); // yyyy-MM-dd
                    else
                        ps.setNull(3, java.sql.Types.DATE);

                    if (pGT != null && !pGT.isBlank()) ps.setString(4, pGT); else ps.setNull(4, java.sql.Types.VARCHAR);
                    if (pDiaChi != null && !pDiaChi.isBlank()) ps.setString(5, pDiaChi); else ps.setNull(5, java.sql.Types.VARCHAR);
                    if (pSoDT != null && !pSoDT.isBlank()) ps.setString(6, pSoDT); else ps.setNull(6, java.sql.Types.VARCHAR);
                    if (pEmail != null && !pEmail.isBlank()) ps.setString(7, pEmail); else ps.setNull(7, java.sql.Types.VARCHAR);

                    if (pMaLop != null && !pMaLop.isBlank()) ps.setString(8, pMaLop);
                    else ps.setNull(8, java.sql.Types.VARCHAR); // chỉ OK nếu cột cho NULL

                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI());
                return;
            }
            else if ("update".equals(action)) {
                String pNgay = request.getParameter("NgaySinh");

                try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE sinhvien SET HoTen=?,NgaySinh=?,GioiTinh=?,DiaChi=?,SoDT=?,Email=?,MaLop=? WHERE MaSV=?")) {

                    ps.setString(1, request.getParameter("HoTen"));

                    if (pNgay != null && !pNgay.isBlank())
                        ps.setDate(2, java.sql.Date.valueOf(pNgay));
                    else
                        ps.setNull(2, java.sql.Types.DATE);

                    String pGT = request.getParameter("GioiTinh");
                    if (pGT != null && !pGT.isBlank()) ps.setString(3, pGT); else ps.setNull(3, java.sql.Types.VARCHAR);

                    String pDiaChi = request.getParameter("DiaChi");
                    if (pDiaChi != null && !pDiaChi.isBlank()) ps.setString(4, pDiaChi); else ps.setNull(4, java.sql.Types.VARCHAR);

                    String pSoDT = request.getParameter("SoDT");
                    if (pSoDT != null && !pSoDT.isBlank()) ps.setString(5, pSoDT); else ps.setNull(5, java.sql.Types.VARCHAR);

                    String pEmail = request.getParameter("Email");
                    if (pEmail != null && !pEmail.isBlank()) ps.setString(6, pEmail); else ps.setNull(6, java.sql.Types.VARCHAR);

                    String pMaLop = request.getParameter("MaLop");
                    if (pMaLop != null && !pMaLop.isBlank()) {
                        // kiểm tra lớp khi update
                        try (PreparedStatement ck = conn.prepareStatement("SELECT 1 FROM lop WHERE MaLop=?")) {
                            ck.setString(1, pMaLop);
                            try (ResultSet r = ck.executeQuery()) {
                                if (!r.next()) { response.sendRedirect(request.getRequestURI()+"?err=lop"); return; }
                            }
                        }
                        ps.setString(7, pMaLop);
                    } else {
                        ps.setNull(7, java.sql.Types.VARCHAR);
                    }

                    ps.setString(8, request.getParameter("MaSV"));
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI());
                return;
            }
            else if ("delete".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM sinhvien WHERE MaSV=?")) {
                    ps.setString(1, MaSV);
                    ps.executeUpdate(); 
                }
                response.sendRedirect(request.getRequestURI());
                return;
            }
        }

        // ========================= LẤY DANH SÁCH SV =========================
        List<Map<String,Object>> svList = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT sv.MaSV, sv.HoTen, sv.Email, sv.MaLop, IFNULL(l.MaKhoa,'') AS MaKhoa " +
                "FROM sinhvien sv LEFT JOIN lop l ON sv.MaLop = l.MaLop ORDER BY sv.MaSV");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new HashMap<>();
                row.put("MaSV",   rs.getString("MaSV"));
                row.put("HoTen",  rs.getString("HoTen"));
                row.put("Email",  rs.getString("Email"));
                row.put("MaLop",  rs.getString("MaLop"));
                row.put("MaKhoa", rs.getString("MaKhoa"));
                svList.add(row);
            }
        }
        request.setAttribute("svList", svList);

        // ========================= LẤY DANH SÁCH LỚP (cho datalist) =========================
        List<Map<String,String>> lopList = new ArrayList<>();
        try (PreparedStatement ps2 = conn.prepareStatement(
                "SELECT MaLop, IFNULL(MaKhoa,'') AS MaKhoa FROM lop ORDER BY MaLop");
             ResultSet rs2 = ps2.executeQuery()) {
            while (rs2.next()) {
                Map<String,String> r = new HashMap<>();
                r.put("MaLop", rs2.getString("MaLop"));
                r.put("MaKhoa", rs2.getString("MaKhoa"));
                lopList.add(r);
            }
        }
        request.setAttribute("lopList", lopList);

    } catch (Exception e) {
        e.printStackTrace();
        out.print("<pre style='color:red'>Lỗi: " + e.getMessage() + "</pre>");
    }
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Sinh viên | MONKEY Edusoft</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/css/style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <style>
                /* ==========================================================================
   Admin QLSV – Table & Inline Form Styles
   ========================================================================== */

/* Card header với tiêu đề + nút "Thêm mới" nằm 2 bên */
.card .card-header{
  display:flex; align-items:center; justify-content:space-between;
  gap: var(--space-md); margin-bottom: var(--space-md);
}
.card .card-header .form-actions{ display:flex; gap:.5rem; }

/* Nút chính (Thêm mới) đồng bộ màu chủ đạo */
.btn-primary{
  display:inline-flex; align-items:center; gap:.5rem;
  padding:.6rem .9rem; border-radius:12px; border:1px solid transparent;
  background: var(--primary); color:#fff; font-weight:600;
  box-shadow: 0 6px 16px rgba(11,99,229,.20);
  cursor:pointer; transition: transform .06s ease, background .2s ease, box-shadow .2s ease;
}
.btn-primary .material-icons-outlined{ font-size:20px; }
.btn-primary:hover{ background: var(--primary-600); box-shadow: 0 10px 22px rgba(11,99,229,.25); }
.btn-primary:active{ transform: translateY(1px); }

/* Bảng dữ liệu sinh viên */
.table-responsive{
  width:100%; overflow:auto;
  border:1px solid var(--border);
  border-radius: var(--radius-lg);
  background:#fff; box-shadow: var(--shadow-sm);
}
.course-table{
  width:100%; border-collapse:separate; border-spacing:0; min-width:880px;
}
.course-table thead th{
  position:sticky; top:0; z-index:1;
  text-align:left; font-weight:700; color:#334155;
  background:#f8fafc; border-bottom:1px solid var(--border);
  padding:.85rem .9rem; white-space:nowrap;
}
.course-table tbody td{
  padding:.75rem .9rem; border-bottom:1px solid var(--border);
  vertical-align:middle; color:#334155;
}
.course-table tbody tr:hover{ background:#f9fbff; }

/* Ô input inline trong bảng (thêm/sửa) */
.course-table input[type="text"],
.course-table input[type="email"],
.course-table input[type="date"],
.course-table input:not([type]),
.course-table select{
  width:100%; max-width: 260px;
  padding:.5rem .6rem; border:1px solid var(--border);
  border-radius:10px; background:#fff; color:#111827;
  outline:none; transition:border-color .15s ease, box-shadow .15s ease;
}
.course-table input:focus,
.course-table select:focus{
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(11,99,229,.12);
}

/* Nút icon Sửa / Xóa / Lưu / Hủy trong bảng – kế thừa .btn-icon chung */
.course-table .btn-icon{
  width:36px; height:36px; border-radius:10px; margin-right:.25rem;
}
.course-table .btn-icon .material-icons-outlined{ font-size:20px; }
.course-table form{ display:inline; }

/* Badge trạng thái */
.status-badge{
  display:inline-block; padding:.25rem .6rem; font-size:.78rem; font-weight:600;
  border-radius:999px; background:#eef2ff; color:var(--primary);
  border:1px solid #e0e7ff;
}
.status-badge.registered{
  background:#ecfdf5; color:#15803d; border-color:#bbf7d0; /* xanh lá nhạt */
}

/* Hàng đang ở chế độ chỉnh sửa – làm nổi khối */
.course-table tr:has(form[action][method="post"]) td{
  background:#fff; box-shadow: inset 0 0 0 9999px rgba(11,99,229,.02);
}

/* Tooltip gợi ý (nếu cần) */
[aria-label]{ position:relative; }
[aria-label]:hover::after{
  content: attr(aria-label);
  position:absolute; bottom:calc(100% + 8px); left:50%; transform:translateX(-50%);
  background:#0f172a; color:#fff; font-size:.75rem; white-space:nowrap;
  padding:.25rem .45rem; border-radius:6px; pointer-events:none; opacity:.9;
}

/* Khoảng cách icon & text trong bảng header */
.course-table th .material-icons-outlined{ vertical-align:middle; margin-right:.25rem; }

/* Responsive */
@media (max-width: 768px){
  .card .card-header{ flex-direction:column; align-items:flex-start; }
  .card .card-header .form-actions{ width:100%; }
  .btn-primary{ width:100%; justify-content:center; }
  .course-table{ min-width:720px; } /* vẫn scroll ngang mượt */
}

/* Sửa nhẹ khoảng cách các form inline ở ô Hành động */
.course-table td form + form{ margin-left:.2rem; }

/* ==========================================================================
   CRUD Button Colors – auto by aria-label
   ========================================================================== */

/* Nút Sửa (edit) */
.btn-icon[aria-label="Sửa"] .material-icons-outlined {
  color: #f59e0b; /* vàng */
}
.btn-icon[aria-label="Sửa"]:hover {
  background: #fff7ed;
  border-color: #fbbf24;
}

/* Nút Xóa (delete) */
.btn-icon[aria-label="Xóa"] .material-icons-outlined {
  color: #ef4444; /* đỏ */
}
.btn-icon[aria-label="Xóa"]:hover {
  background: #fef2f2;
  border-color: #f87171;
}

/* Nút Lưu (check) */
.btn-icon[aria-label="Lưu"] .material-icons-outlined {
  color: #22c55e; /* xanh lá */
}
.btn-icon[aria-label="Lưu"]:hover {
  background: #ecfdf5;
  border-color: #86efac;
}

/* Nút Hủy (close) */
.btn-icon[aria-label="Hủy"],
.btn-icon[aria-label="Hủy thêm"] {
  border-color: #e5e7eb;
}
.btn-icon[aria-label="Hủy"] .material-icons-outlined,
.btn-icon[aria-label="Hủy thêm"] .material-icons-outlined {
  color: #6b7280; /* xám */
}
.btn-icon[aria-label="Hủy"]:hover,
.btn-icon[aria-label="Hủy thêm"]:hover {
  background: #f9fafb;
}

/* Nút Thêm mới (trong form trên) – đã có .btn-primary, chỉ thêm hiệu ứng nhẹ */
.btn-primary:hover .material-icons-outlined {
  transform: scale(1.1);
  transition: transform .15s ease;
}
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
  --text: #1f2937;
  --muted: #6b7280;
  --border: #e5e7eb;

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

/* Scrollbar */
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
  background: linear-gradient(180deg, var(--primary), var(--primary-600));
  color:#fff;
  border-right:none;
  box-shadow: 0 8px 24px rgba(9,86,199,.25);
  z-index: 1000;
  display: flex; flex-direction: column;
  transform: translateX(0);
  transition: transform .25s ease;
}
.sidebar-header{
  display:flex; align-items:center; gap: var(--space-sm);
  padding: var(--space-md) var(--space-md);
  min-height: 64px;
  border-bottom: 1px solid rgba(255,255,255,.15);
  color:#fff;
}
.sidebar-logo{
  display:flex; align-items:center; gap:.625rem; font-weight:600; color:#fff;
}
.sidebar-logo img{ width:36px; height:36px; object-fit:contain; filter: brightness(0) invert(1); }
.btn-close-sidebar{ margin-left:auto; border-color: rgba(255,255,255,.25); background:transparent; color:#fff; }
.btn-close-sidebar:hover{ background: rgba(255,255,255,.12); }

.sidebar-content{ padding: var(--space-md); overflow:auto; color:#e5ecff; }

.nav-section-title{
  margin: var(--space-md) var(--space-sm) var(--space-sm);
  color:#e0e7ff; opacity:.9;
  font-size:.8rem; text-transform: uppercase; letter-spacing:.04em;
}

.nav-list{ list-style:none; padding:0; margin:0; }
.nav-item{ margin-bottom:.25rem; }
.nav-link{
  display:flex; align-items:center; gap:.75rem;
  padding:.625rem .75rem;
  border-radius: var(--radius-sm);
  color:#fff;
  background:transparent;
  transition: background .15s ease, color .15s ease, transform .06s ease;
}
.nav-link .material-icons-outlined{ font-size:20px; color:#e8eeff; }
.nav-link:hover{ background: rgba(255,255,255,.12); color:#fff; }
.nav-link.active{
  background:#fff;
  color: var(--primary);
  box-shadow: 0 6px 14px rgba(255,255,255,.18);
}
.nav-link.active .material-icons-outlined{ color: var(--primary); }

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

.btn-open-sidebar{ display:none; }

/* ----- User Profile Dropdown ----- */
.user-profile-dropdown{ position:relative; }
.user-profile-btn{
  display:flex; align-items:center; gap:.5rem;
  padding:.25rem .5rem; border-radius: 999px;
  border:1px solid var(--border); background:#fff; cursor:pointer;
}
.avatar{ width:28px; height:28px; border-radius:50%; object-fit:cover; }
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

    </style>

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
                <li class="nav-item" role="menuitem"><a href="admin_dashboard.jsp" class="nav-link"><span class="material-icons-outlined">admin_panel_settings</span><span>Trang chủ Admin</span></a></li>
                <li class="nav-section-title">Quản lý</li>
                <li class="nav-item" role="menuitem"><a href="admin_qlsv.jsp" class="nav-link active"><span class="material-icons-outlined">school</span><span>Quản lý Sinh viên</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qlgv.jsp" class="nav-link"><span class="material-icons-outlined">account_box</span><span>Quản lý Giảng viên</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qlmh.jsp" class="nav-link"><span class="material-icons-outlined">book</span><span>Quản lý Môn học</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qllop.jsp" class="nav-link"><span class="material-icons-outlined">corporate_fare</span><span>Quản lý Khoa/Lớp</span></a></li>
                <li class="nav-section-title">Nghiệp vụ</li>
                <li class="nav-item" role="menuitem"><a href="admin_xemdiem.jsp" class="nav-link"><span class="material-icons-outlined">grade</span><span>Quản Lý Điểm</span></a></li>
                
                                            <li class="nav-item"><a href="duyetdangky.jsp" class="nav-link active"><span class="material-icons-outlined">how_to_reg</span>Duyệt đăng ký tín </a></li><li class="nav-item" role="menuitem"><a href="admin_bctk.jsp" class="nav-link"><span class="material-icons-outlined">assessment</span><span>Báo cáo Thống kê</span></a></li>
            </ul>
        </div>
    </nav>

    <main class="main-content">
        <header class="main-header">
            <div class="header-left">
                <button class="btn-icon btn-open-sidebar" aria-label="Mở menu" id="open-sidebar"><span class="material-icons-outlined">menu</span></button>
                <h1 class="page-title">Quản lý Sinh viên</h1>
            </div>
            <div class="header-right"></div>
        </header>

        <div class="page-content-wrapper">
<section class="card">
    <div class="card-header">
        <h2 class="section-title">Danh sách Sinh viên</h2>
        <div class="form-actions">
            <form method="get" style="display:inline">
                <input type="hidden" name="showAdd" value="1">
                <button class="btn-primary" type="submit">
                    <span class="material-icons-outlined">add</span>Thêm mới Sinh viên
                </button>
            </form>
        </div>
    </div>

    <div class="table-responsive">
        <table class="course-table">
            <thead>
                <tr>
                    <th>Mã SV</th> <th>Họ tên</th> <th>Lớp</th> <th>Khoa</th> <th>Email</th> <th>Trạng thái</th> <th>Hành động</th>
                </tr>
            </thead>
<tbody>
<% if ("1".equals(request.getParameter("showAdd"))) { %>

<!-- Tạo form độc lập, action trỏ về URI KHÔNG có query để tránh giữ ?showAdd=1 -->
<form id="formAdd" method="post" action="<%= request.getRequestURI() %>">
  <input type="hidden" name="action" value="add">
  <!-- Nếu bạn chưa có đủ các cột, cho thêm input ẩn để không lỗi khi insert -->
  <input type="hidden" name="NgaySinh" value="">
  <input type="hidden" name="GioiTinh" value="">
  <input type="hidden" name="DiaChi"   value="">
  <input type="hidden" name="SoDT"     value="">
</form>

<tr class="row-add">
  <td><input name="MaSV" form="formAdd" required></td>
  <td><input name="HoTen" form="formAdd" required></td>
  <td><input name="MaLop" form="formAdd" placeholder="VD: DHTI15A1HN"></td>
  <td><em>(auto từ lớp)</em></td>
  <td><input name="Email" form="formAdd" type="email"></td>
  <td><span class="status-badge registered">Đang học</span></td>
  <td>
    <button class="btn-icon" type="submit" form="formAdd" aria-label="Lưu">
      <span class="material-icons-outlined">check</span>
    </button>
    <!-- Hủy: quay về URI không query để ẩn hàng thêm -->
    <a class="btn-icon" href="<%= request.getRequestURI() %>" aria-label="Hủy thêm">
      <span class="material-icons-outlined">close</span>
    </a>
  </td>
</tr>

<% } %>


    <%
        List<Map<String,Object>> svList = (List<Map<String,Object>>) request.getAttribute("svList");
        if (svList != null) {
            for (Map<String,Object> row : svList) {
                String id    = (String) row.get("MaSV");
                String hoTen = (String) row.get("HoTen");
                String maLop = (String) row.get("MaLop");
                String maKhoa= (String) row.get("MaKhoa");
                String email = (String) row.get("Email");
                boolean isEditing = id != null && id.equals(request.getParameter("edit"));
    %>

    <tr>
        <% if (!isEditing) { %>
            <td><%= id %></td>
            <td><%= hoTen %></td>
            <td><%= maLop %></td>
            <td><%= maKhoa %></td>
            <td><%= email %></td>
            <td><span class="status-badge registered">Đang học</span></td>
            <td>
                <form method="get" style="display:inline">
                    <input type="hidden" name="edit" value="<%= id %>">
                    <button class="btn-icon" aria-label="Sửa" type="submit"><span class="material-icons-outlined">edit</span></button>
                </form>
                <form method="post" style="display:inline" onsubmit="return confirm('Xóa sinh viên <%=id%>?');">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="MaSV" value="<%= id %>">
                    <button class="btn-icon" aria-label="Xóa" type="submit"><span class="material-icons-outlined">delete</span></button>
                </form>
            </td>
        <% } else { %>
            <form method="post">
                <input type="hidden" name="action" value="update">
                <td><input name="MaSV" value="<%= id %>" readonly></td>
                <td><input name="HoTen" value="<%= hoTen %>"></td>
                <td><input name="MaLop" value="<%= maLop %>"></td>
                <td><%= maKhoa %></td>
                <td><input name="Email" type="email" value="<%= email %>"></td>
                <td><span class="status-badge registered">Đang học</span></td>
                <td>
                    <button class="btn-icon" aria-label="Lưu" type="submit"><span class="material-icons-outlined">check</span></button>
                    <a class="btn-icon" href="<%= request.getRequestURI() %>" aria-label="Hủy"><span class="material-icons-outlined">close</span></a>
                </td>
            </form>
        <% } %>
    </tr>

    <% } } %>
</tbody>
        </table>
    </div>
</section>
        </div>
    </main>

    <div class="sidebar-overlay" id="sidebar-overlay"></div>
    <script src="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/js/main.js"></script>
</body>
</html>
    