<%
    String JDBC_URL  = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String JDBC_USER = "root";
    String JDBC_PASS = "";

    // Tham số kiểu trang admin_qlsv.jsp
    String showAdd = request.getParameter("showAdd"); // "1" => hiện form thêm
    String editId  = request.getParameter("edit");    // MaGV đang sửa
    String action  = request.getParameter("action");  // add | update | delete
    String MaGV    = request.getParameter("MaGV");

    try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {

        // ===== CRUD: giangvien =====
        if (action != null) {
            if ("add".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO giangvien (MaGV,HoTen,MaKhoa) VALUES (?,?,?)")) {
                    ps.setString(1, request.getParameter("MaGV"));
                    ps.setString(2, request.getParameter("HoTen"));
                    ps.setString(3, request.getParameter("MaKhoa"));
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI());
                return;

            } else if ("update".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE giangvien SET HoTen=?, MaKhoa=? WHERE MaGV=?")) {
                    ps.setString(1, request.getParameter("HoTen"));
                    ps.setString(2, request.getParameter("MaKhoa"));
                    ps.setString(3, request.getParameter("MaGV"));
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI());
                return;

            } else if ("delete".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM giangvien WHERE MaGV=?")) {
                    ps.setString(1, MaGV);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI());
                return;
            }
        }

        // ===== Danh sách giảng viên (LEFT JOIN khoa để hiện TenKhoa) =====
        List<Map<String,Object>> gvList = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT gv.MaGV, gv.HoTen, COALESCE(k.TenKhoa, gv.MaKhoa) AS TenKhoa " +
                "FROM giangvien gv LEFT JOIN khoa k ON gv.MaKhoa = k.MaKhoa " +
                "ORDER BY gv.MaGV");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new HashMap<>();
                row.put("MaGV",   rs.getString("MaGV"));
                row.put("HoTen",  rs.getString("HoTen"));
                row.put("TenKhoa",rs.getString("TenKhoa"));
                // Email/SoDT không có trong schema -> giữ trống khi render để không phá layout
                gvList.add(row);
            }
        }
        request.setAttribute("gvList", gvList);

        // ===== Danh mục khoa để đổ vào <select> =====
        List<Map<String,String>> dsKhoa = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT MaKhoa, TenKhoa FROM khoa ORDER BY TenKhoa");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> k = new HashMap<>();
                k.put("MaKhoa", rs.getString("MaKhoa"));
                k.put("TenKhoa", rs.getString("TenKhoa"));
                dsKhoa.add(k);
            }
        }
        request.setAttribute("dsKhoa", dsKhoa);

    } catch (Exception e) {
        e.printStackTrace();
        out.print("<pre>Lỗi: " + e.getMessage() + "</pre>");
    }
%>

<%@ page import="java.sql.*, java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>


<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Giảng viên</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/css/style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <style>
        /* =========================
   MONKEY Edusoft – Admin CSS
   File: /BTL_JSP/WebContent/assets/css/style.css
   Không thay đổi cấu trúc HTML
   ========================= */

/* ---------- CSS Variables ---------- */
:root{
  --primary:#0B63E5;
  --primary-600:#0957cc;
  --primary-700:#084cb5;
  --bg:#f5f8fd;
  --card:#ffffff;
  --text:#111827;
  --muted:#6b7280;
  --border:#e5e7eb;
  --success:#16a34a;
  --danger:#dc2626;
  --warning:#f59e0b;
  --radius:14px;
  --shadow:0 8px 24px rgba(2,6,23,.06);
}

/* ---------- CSS Reset (nhẹ) ---------- */
*{box-sizing:border-box}
html,body{height:100%}
body{
  margin:0;
  font-family: 'Segoe UI', Roboto, Arial, sans-serif;
  color:var(--text);
  background:var(--bg);
  display:flex;
}

/* ---------- Utilities ---------- */
.hide{display:none!important}
.text-muted{color:var(--muted)}
.badge{
  display:inline-flex;align-items:center;gap:6px;
  font-size:12px;padding:2px 8px;border-radius:999px;
  background:#eef2ff;color:#3730a3
}

/* ---------- Sidebar ---------- */
.sidebar{
  position:fixed; inset:0 auto 0 0; width:260px; background:var(--primary);
  color:#fff; display:flex; flex-direction:column; z-index:1000;
  box-shadow: 0 10px 30px rgba(11,99,229,.25);
}
.sidebar-header{
  display:flex; align-items:center; justify-content:space-between;
  padding:16px 18px; border-bottom:1px solid rgba(255,255,255,.15)
}
.sidebar-logo{display:flex; align-items:center; gap:10px; text-decoration:none; color:#fff}
.sidebar-logo img{height:36px; width:auto; display:block}
.btn-icon{
  appearance:none; border:none; background:transparent; cursor:pointer;
  height:36px; width:36px; border-radius:10px; display:inline-grid; place-items:center;
  color:inherit;
}
.btn-icon:hover{background:rgba(255,255,255,.12)}
.btn-close-sidebar{display:none} /* hiện trên mobile */

.sidebar-content{padding:10px 8px 20px; overflow:auto}
.nav-section-title{
  font-size:12px; letter-spacing:.08em; text-transform:uppercase;
  opacity:.8; padding:14px 14px 8px
}
.nav-list{list-style:none; margin:0; padding:0}
.nav-item{margin:2px 6px}
.nav-link{
  display:flex; align-items:center; gap:12px;
  text-decoration:none; color:#eaf1ff; padding:10px 12px; border-radius:10px;
  transition:.15s ease;
}
.nav-link .material-icons-outlined{font-size:20px}
.nav-link:hover{background:rgba(255,255,255,.14)}
.nav-link.active{background:#fff; color:var(--primary); font-weight:600}

/* ---------- Main content ---------- */
.main-content{
  margin-left:260px; width:calc(100% - 260px);
  min-height:100vh; display:flex; flex-direction:column;
}
.main-header{
  position:sticky; top:0; z-index:900;
  display:flex; align-items:center; justify-content:space-between;
  gap:16px; background:var(--card); padding:12px 18px; border-bottom:1px solid var(--border);
  box-shadow:0 4px 14px rgba(2,6,23,.04);
}
.header-left{display:flex; align-items:center; gap:12px}
.page-title{font-size:20px; margin:0}
.btn-open-sidebar{display:none} /* hiện trên mobile */

/* ---------- Cards ---------- */
.card{
  background:var(--card); border:1px solid var(--border);
  border-radius:var(--radius); box-shadow:var(--shadow);
  margin:18px; padding:0;
}
.card-header{
  display:flex; align-items:center; justify-content:space-between;
  gap:12px; padding:16px 18px; border-bottom:1px solid var(--border);
}
.section-title{margin:0; font-size:18px}
.form-actions{display:flex; gap:10px; align-items:center}

/* ---------- Buttons & Inputs ---------- */
.btn-primary{
  display:inline-flex; align-items:center; gap:8px;
  background:var(--primary); color:#fff; border:none; cursor:pointer;
  padding:10px 14px; border-radius:10px; font-weight:600; transition:.15s ease;
}
.btn-primary .material-icons-outlined{font-size:19px}
.btn-primary:hover{background:var(--primary-600)}
.btn-primary:active{transform:translateY(1px)}

button, input, select, a.btn, .btn{
  font:inherit;
}

input[type="text"], input:not([type]), input[type="date"], select{
  width:100%; padding:8px 10px; border:1px solid var(--border);
  border-radius:10px; background:#fff; outline:0; transition:.15s ease;
}
input:focus, select:focus{border-color:var(--primary); box-shadow:0 0 0 3px rgba(11,99,229,.12)}

/* ---------- Table ---------- */
.table-responsive{width:100%; overflow:auto}
.course-table{
  width:100%; border-collapse:separate; border-spacing:0; min-width:780px;
}
.course-table thead th{
  position:sticky; top:0; z-index:1; text-align:left; padding:12px 14px;
  background:#f8fafc; color:#0f172a; border-bottom:1px solid var(--border);
  font-weight:700; font-size:14px;
}
.course-table tbody td{
  padding:10px 14px; border-bottom:1px solid var(--border); vertical-align:middle;
}
.course-table tbody tr:hover{background:#f9fbff}

/* Ô đang edit (form inline) */
.course-table input, .course-table select{min-width:160px}
.course-table form{margin:0}

/* Action buttons trong bảng */
.course-table .btn-icon{
  color:#0f172a; border:1px solid var(--border); background:#fff;
}
.course-table .btn-icon:hover{background:#f3f4f6}
.course-table .btn-icon .material-icons-outlined{font-size:18px}

/* Delete button trạng thái nguy hiểm */
form[onsubmit] .btn-icon{
  color:var(--danger); border-color:#f1d2d2; background:#fff0f0;
}
form[onsubmit] .btn-icon:hover{background:#ffe6e6}

/* ---------- Status colors (nếu cần) ---------- */
.text-success{color:var(--success)!important}
.text-danger{color:var(--danger)!important}
.text-warning{color:var(--warning)!important}

/* ---------- Sidebar overlay (mobile) ---------- */
.sidebar-overlay{
  position:fixed; inset:0; background:rgba(2,6,23,.48);
  opacity:0; visibility:hidden; transition:.2s ease; z-index:900;
}
.sidebar.is-open + .main-content ~ .sidebar-overlay,
.sidebar-overlay.is-open{
  opacity:1; visibility:visible;
}

/* ---------- Responsive ---------- */
@media (max-width: 1024px){
  .main-content{margin-left:240px; width:calc(100% - 240px)}
  .sidebar{width:240px}
}

@media (max-width: 860px){
  .btn-open-sidebar{display:inline-grid}
  .btn-close-sidebar{display:inline-grid}
  .sidebar{
    transform:translateX(-100%); transition:transform .2s ease;
  }
  .sidebar.is-open{transform:none}
  .main-content{margin-left:0; width:100%}
}

/* ---------- Hover helpers on links ---------- */
a{color:var(--primary); text-decoration:none}
a:hover{text-decoration:underline}

/* ---------- Material Icons baseline align ---------- */
.material-icons-outlined{vertical-align:middle; line-height:1}

/* ---------- Small helper for image logo inside dark bg ---------- */
.sidebar-header img{filter:drop-shadow(0 2px 6px rgba(0,0,0,.25))}

    </style>
</head>
<body>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <a href="admin_dashboard.jsp" class="sidebar-logo">
            </a>
            <button class="btn-icon btn-close-sidebar" aria-label="Đóng menu" id="close-sidebar"><span class="material-icons-outlined">close</span></button>
        </div>
        <div class="sidebar-content">
            <ul class="nav-list" role="menu">
                <li class="nav-item" role="menuitem"><a href="admin_dashboard.jsp" class="nav-link"><span class="material-icons-outlined">admin_panel_settings</span><span>Trang chủ Admin</span></a></li>
                <li class="nav-section-title">Quản lý</li>
                <li class="nav-item" role="menuitem"><a href="admin_qlsv.jsp" class="nav-link"><span class="material-icons-outlined">school</span><span>Quản lý Sinh viên</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qlgv.jsp" class="nav-link active"><span class="material-icons-outlined">account_box</span><span>Quản lý Giảng viên</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qlmh.jsp" class="nav-link"><span class="material-icons-outlined">book</span><span>Quản lý Môn học</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qllop.jsp" class="nav-link"><span class="material-icons-outlined">corporate_fare</span><span>Quản lý Khoa/Lớp</span></a></li>
                <li class="nav-section-title">Nghiệp vụ</li>
                
                                            <li class="nav-item"><a href="duyetdangky.jsp" class="nav-link active"><span class="material-icons-outlined">how_to_reg</span>Duyệt đăng ký tín </a></li><li class="nav-item" role="menuitem"><a href="admin_xemdiem.jsp" class="nav-link"><span class="material-icons-outlined">grade</span><span>Quản Lý Điểm</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_bctk.jsp" class="nav-link"><span class="material-icons-outlined">assessment</span><span>Báo cáo Thống kê</span></a></li>
            </ul>
        </div>
    </nav>

    <main class="main-content">
        <header class="main-header">
            <div class="header-left">
                <button class="btn-icon btn-open-sidebar" aria-label="Mở menu" id="open-sidebar"><span class="material-icons-outlined">menu</span></button>
                <h1 class="page-title">Quản lý Giảng viên</h1>
            </div>
            <div class="header-right">
                </div>
        </header>

<section class="card">
    <div class="card-header">
        <h2 class="section-title">Danh sách Giảng viên</h2>
        <div class="form-actions">
            <form method="get" style="display:inline">
                <input type="hidden" name="showAdd" value="1">
                <button class="btn-primary" type="submit">
                    <span class="material-icons-outlined">add</span>Thêm mới Giảng viên
                </button>
            </form>
        </div>
    </div>

    <div class="table-responsive">
        <table class="course-table">
            <thead>
                <tr>
                    <th>Mã GV</th> <th>Họ tên</th> <th>Khoa</th> <th>Email</th> <th>Điện thoại</th> <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <%-- Form THÊM --%>
                <% if ("1".equals(request.getParameter("showAdd"))) { %>
                <tr>
                    <form method="post">
                        <input type="hidden" name="action" value="add">
                        <td><input name="MaGV" required maxlength="10"></td>
                        <td><input name="HoTen" required></td>
                        <td>
                            <select name="MaKhoa" required>
                                <%
                                    List<Map<String,String>> dsKhoa = (List<Map<String,String>>) request.getAttribute("dsKhoa");
                                    if (dsKhoa != null) {
                                        for (Map<String,String> k : dsKhoa) {
                                            String mk = k.get("MaKhoa");
                                            String tk = k.get("TenKhoa");
                                %>
                                    <option value="<%= mk %>"><%= tk %> (<%= mk %>)</option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </td>
                        <td><!-- không có cột trong DB --></td>
                        <td><!-- không có cột trong DB --></td>
                        <td>
                            <button class="btn-icon" type="submit" aria-label="Lưu">
                                <span class="material-icons-outlined">check</span>
                            </button>
                            <a class="btn-icon" href="<%= request.getRequestURI() %>" aria-label="Hủy">
                                <span class="material-icons-outlined">close</span>
                            </a>
                        </td>
                    </form>
                </tr>
                <% } %>

                <%-- DANH SÁCH + SỬA INLINE --%>
                <%
                    List<Map<String,Object>> gvList = (List<Map<String,Object>>) request.getAttribute("gvList");
                    if (gvList != null) {
                        for (Map<String,Object> row : gvList) {
                            String id     = (String) row.get("MaGV");
                            String hoTen  = (String) row.get("HoTen");
                            String tenKhoa= (String) row.get("TenKhoa");
                            boolean isEditing = id != null && id.equals(request.getParameter("edit"));
                %>

                <tr>
                    <% if (!isEditing) { %>
                        <td><%= id %></td>
                        <td><%= hoTen %></td>
                        <td><%= tenKhoa %></td>
                        <td></td>  <%-- Email: để trống --%>
                        <td></td>  <%-- Điện thoại: để trống --%>
                        <td>
                            <form method="get" style="display:inline">
                                <input type="hidden" name="edit" value="<%= id %>">
                                <button class="btn-icon" aria-label="Sửa" type="submit">
                                    <span class="material-icons-outlined">edit</span>
                                </button>
                            </form>
                            <form method="post" style="display:inline" onsubmit="return confirm('Xóa giảng viên <%=id%>?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="MaGV" value="<%= id %>">
                                <button class="btn-icon" aria-label="Xóa" type="submit">
                                    <span class="material-icons-outlined">delete</span>
                                </button>
                            </form>
                        </td>
                    <% } else { %>
                        <form method="post">
                            <input type="hidden" name="action" value="update">
                            <td><input name="MaGV" value="<%= id %>" readonly></td>
                            <td><input name="HoTen" value="<%= hoTen %>" required></td>
                            <td>
                                <select name="MaKhoa" required>
                                    <%
                                        List<Map<String,String>> _dsKhoa = (List<Map<String,String>>) request.getAttribute("dsKhoa");
                                        if (_dsKhoa != null) {
                                            for (Map<String,String> k : _dsKhoa) {
                                                String mk = k.get("MaKhoa");
                                                String tk = k.get("TenKhoa");
                                                String sel = (tenKhoa != null && tenKhoa.contains(tk)) ? "selected" : "";
                                    %>
                                        <option value="<%= mk %>" <%= sel %>><%= tk %> (<%= mk %>)</option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                            </td>
                            <td></td>
                            <td></td>
                            <td>
                                <button class="btn-icon" aria-label="Lưu" type="submit">
                                    <span class="material-icons-outlined">check</span>
                                </button>
                                <a class="btn-icon" href="<%= request.getRequestURI() %>" aria-label="Hủy">
                                    <span class="material-icons-outlined">close</span>
                                </a>
                            </td>
                        </form>
                    <% } %>
                </tr>

                <%  } } %>
            </tbody>
        </table>
    </div>
</section>

    </main>

    <div class="sidebar-overlay" id="sidebar-overlay"></div>
    <script src="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/js/main.js"></script>
</body>
</html>