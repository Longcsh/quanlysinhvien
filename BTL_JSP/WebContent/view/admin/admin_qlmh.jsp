<%
    String JDBC_URL  = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String JDBC_USER = "root";
    String JDBC_PASS = "";

    String showAdd = request.getParameter("showAdd"); // "1" => hiện form thêm
    String editId  = request.getParameter("edit");    // MaMon đang sửa
    String action  = request.getParameter("action");  // add | update | delete
    String MaMon   = request.getParameter("MaMon");

    try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {

        // ===== CRUD: monhoc =====
        if (action != null) {
            if ("add".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO monhoc (MaMon, TenMon, SoTinChi) VALUES (?,?,?)")) {
                    ps.setString(1, request.getParameter("MaMon"));
                    ps.setString(2, request.getParameter("TenMon"));
                    ps.setInt(3, Integer.parseInt(request.getParameter("SoTinChi")));
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI());
                return;

            } else if ("update".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE monhoc SET TenMon=?, SoTinChi=? WHERE MaMon=?")) {
                    ps.setString(1, request.getParameter("TenMon"));
                    ps.setInt(2, Integer.parseInt(request.getParameter("SoTinChi")));
                    ps.setString(3, request.getParameter("MaMon"));
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI());
                return;

            } else if ("delete".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM monhoc WHERE MaMon=?")) {
                    ps.setString(1, MaMon);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI());
                return;
            }
        }

        // ===== Danh sách môn học =====
        List<Map<String,Object>> mhList = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT MaMon, TenMon, SoTinChi FROM monhoc ORDER BY MaMon");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> row = new HashMap<>();
                row.put("MaMon",    rs.getString("MaMon"));
                row.put("TenMon",   rs.getString("TenMon"));
                row.put("SoTinChi", rs.getInt("SoTinChi"));
                mhList.add(row);
            }
        }
        request.setAttribute("mhList", mhList);

    } catch (Exception e) {
        e.printStackTrace();
        out.print("<pre>Lỗi: " + e.getMessage() + "</pre>");
    }
%>

<%@ page import="java.sql.*, java.util.*" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Môn học | MONKEY Edusoft</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/css/style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <style>
        /* ======================================================
   MONKEY Edusoft – Admin Panel UI
   File: /BTL_JSP/WebContent/assets/css/style.css
   ====================================================== */

/* ---------- VARIABLES ---------- */
:root {
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
  --radius:14px;
  --shadow:0 8px 24px rgba(2,6,23,.06);
}

/* ---------- RESET ---------- */
*{box-sizing:border-box;margin:0;padding:0}
html,body{height:100%}
body{
  font-family:'Segoe UI',Roboto,Arial,sans-serif;
  background:var(--bg);
  color:var(--text);
  display:flex;
}

/* ---------- SIDEBAR ---------- */
.sidebar{
  position:fixed;top:0;left:0;height:100vh;width:260px;
  background:var(--primary);color:#fff;
  display:flex;flex-direction:column;z-index:1000;
  box-shadow:0 0 20px rgba(11,99,229,.25);
}
.sidebar-header{
  display:flex;justify-content:space-between;align-items:center;
  padding:14px 18px;border-bottom:1px solid rgba(255,255,255,.2);
}
.sidebar-logo{
  display:flex;align-items:center;gap:10px;
  text-decoration:none;color:#fff;font-weight:600;
}
.sidebar-logo img{height:36px;width:auto}
.btn-icon{
  background:none;border:none;cursor:pointer;
  height:36px;width:36px;border-radius:10px;
  display:inline-grid;place-items:center;color:inherit;
}
.btn-icon:hover{background:rgba(255,255,255,.15)}
.btn-close-sidebar{display:none}
.sidebar-content{padding:10px;overflow-y:auto}
.nav-list{list-style:none}
.nav-section-title{
  font-size:12px;text-transform:uppercase;opacity:.8;
  padding:14px 14px 8px;
}
.nav-item{margin:2px 6px}
.nav-link{
  display:flex;align-items:center;gap:12px;
  text-decoration:none;color:#eaf1ff;padding:10px 12px;
  border-radius:10px;transition:.15s;
}
.nav-link .material-icons-outlined{font-size:20px}
.nav-link:hover{background:rgba(255,255,255,.15)}
.nav-link.active{background:#fff;color:var(--primary);font-weight:600}

/* ---------- MAIN ---------- */
.main-content{
  margin-left:260px;width:calc(100% - 260px);
  display:flex;flex-direction:column;min-height:100vh;
}
.main-header{
  display:flex;justify-content:space-between;align-items:center;
  padding:12px 18px;background:var(--card);
  border-bottom:1px solid var(--border);
  box-shadow:0 2px 8px rgba(0,0,0,.05);
  position:sticky;top:0;z-index:900;
}
.header-left{display:flex;align-items:center;gap:12px}
.page-title{font-size:20px;font-weight:600}
.btn-open-sidebar{display:none}

/* ---------- CARD ---------- */
.card{
  background:var(--card);border:1px solid var(--border);
  border-radius:var(--radius);box-shadow:var(--shadow);
  margin:18px;padding:0;
}
.card-header{
  display:flex;justify-content:space-between;align-items:center;
  padding:16px 18px;border-bottom:1px solid var(--border);
}
.section-title{font-size:18px}
.form-actions{display:flex;gap:10px}

/* ---------- BUTTONS ---------- */
.btn-primary{
  display:inline-flex;align-items:center;gap:8px;
  background:var(--primary);color:#fff;
  border:none;cursor:pointer;padding:10px 14px;
  border-radius:10px;font-weight:600;transition:.15s;
}
.btn-primary .material-icons-outlined{font-size:19px}
.btn-primary:hover{background:var(--primary-600)}
.btn-primary:active{transform:translateY(1px)}

/* ---------- INPUTS ---------- */
input,select{
  font:inherit;padding:8px 10px;border:1px solid var(--border);
  border-radius:10px;outline:none;background:#fff;
  transition:.15s;border-collapse:separate;
}
input:focus,select:focus{
  border-color:var(--primary);
  box-shadow:0 0 0 3px rgba(11,99,229,.15);
}

/* ---------- TABLE ---------- */
.table-responsive{width:100%;overflow:auto}
.course-table{
  width:100%;border-collapse:separate;border-spacing:0;
  min-width:620px;
}
.course-table th{
  background:#f8fafc;padding:12px 14px;text-align:left;
  font-size:14px;border-bottom:1px solid var(--border);
}
.course-table td{
  padding:10px 14px;border-bottom:1px solid var(--border);
}
.course-table tbody tr:hover{background:#f9fbff}
.course-table td form{display:inline-block;margin:0 3px}
.course-table .btn-icon{
  border:1px solid var(--border);background:#fff;color:#222;
}
.course-table .btn-icon:hover{background:#f1f5f9}
form[onsubmit] .btn-icon{color:var(--danger);border-color:#fca5a5;background:#fee2e2;}
form[onsubmit] .btn-icon:hover{background:#fecaca}

/* ---------- TABLE: MONHOC ---------- */
.course-table thead th:nth-child(1){width:140px;}
.course-table thead th:nth-child(2){width:auto;}
.course-table thead th:nth-child(3){width:120px;text-align:center;}
.course-table thead th:nth-child(4){width:140px;text-align:center;}
.course-table td:nth-child(3),
.course-table td:nth-child(4){text-align:center;}
.course-table input[name="MaMon"]{max-width:120px;}
.course-table input[name="TenMon"]{min-width:240px;}
.course-table input[name="SoTinChi"]{max-width:90px;text-align:center;}

/* ---------- OVERLAY & RESPONSIVE ---------- */
.sidebar-overlay{
  position:fixed;inset:0;background:rgba(0,0,0,.4);
  opacity:0;visibility:hidden;transition:.2s;z-index:800;
}
.sidebar.is-open + .main-content ~ .sidebar-overlay,
.sidebar-overlay.is-open{opacity:1;visibility:visible}

@media(max-width:860px){
  .sidebar{transform:translateX(-100%);transition:.2s;}
  .sidebar.is-open{transform:none}
  .btn-open-sidebar,.btn-close-sidebar{display:inline-grid}
  .main-content{margin-left:0;width:100%}
}

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
                <li class="nav-item" role="menuitem"><a href="admin_qlgv.jsp" class="nav-link"><span class="material-icons-outlined">account_box</span><span>Quản lý Giảng viên</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qlmh.jsp" class="nav-link active"><span class="material-icons-outlined">book</span><span>Quản lý Môn học</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qllop.jsp" class="nav-link"><span class="material-icons-outlined">corporate_fare</span><span>Quản lý Khoa/Lớp</span></a></li>
                <li class="nav-section-title">Nghiệp vụ</li>
                <li class="nav-item" role="menuitem"><a href="admin_xemdiem.jsp" class="nav-link"><span class="material-icons-outlined">grade</span><span>Quản Lý Điểm</span></a></li>
                                            <li class="nav-item"><a href="duyetdangky.jsp" class="nav-link active"><span class="material-icons-outlined">how_to_reg</span>Duyệt đăng ký tín </a></li>
                <li class="nav-item" role="menuitem"><a href="admin_bctk.jsp" class="nav-link"><span class="material-icons-outlined">assessment</span><span>Báo cáo Thống kê</span></a></li>
            </ul>
        </div>
    </nav>

    <main class="main-content">
        <header class="main-header">
            <div class="header-left">
                <button class="btn-icon btn-open-sidebar" aria-label="Mở menu" id="open-sidebar"><span class="material-icons-outlined">menu</span></button>
                <h1 class="page-title">Quản lý Môn học</h1>
            </div>
            <div class="header-right">
                </div>
        </header>
<section class="card">
    <div class="card-header">
        <h2 class="section-title">Danh sách Môn học</h2>
        <div class="form-actions">
            <form method="get" style="display:inline">
                <input type="hidden" name="showAdd" value="1">
                <button class="btn-primary" type="submit">
                    <span class="material-icons-outlined">add</span>Thêm mới Môn học
                </button>
            </form>
        </div>
    </div>

    <div class="table-responsive">
        <table class="course-table">
            <thead>
                <tr>
                    <th>Mã MH</th> <th>Tên môn</th> <th>Số tín chỉ</th> <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <%-- Form THÊM --%>
                <% if ("1".equals(request.getParameter("showAdd"))) { %>
                <tr>
                    <form method="post">
                        <input type="hidden" name="action" value="add">
                        <td><input name="MaMon" required maxlength="10"></td>
                        <td><input name="TenMon" required></td>
                        <td><input name="SoTinChi" type="number" min="1" required></td>
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
                    List<Map<String,Object>> mhList = (List<Map<String,Object>>) request.getAttribute("mhList");
                    if (mhList != null) {
                        for (Map<String,Object> row : mhList) {
                            String id      = (String) row.get("MaMon");
                            String tenMon  = (String) row.get("TenMon");
                            Integer stcInt = (Integer) row.get("SoTinChi");
                            String stc     = (stcInt == null ? "" : String.valueOf(stcInt));
                            boolean isEditing = id != null && id.equals(request.getParameter("edit"));
                %>

                <tr>
                    <% if (!isEditing) { %>
                        <td><%= id %></td>
                        <td><%= tenMon %></td>
                        <td><%= stc %></td>
                        <td>
                            <form method="get" style="display:inline">
                                <input type="hidden" name="edit" value="<%= id %>">
                                <button class="btn-icon" aria-label="Sửa" type="submit">
                                    <span class="material-icons-outlined">edit</span>
                                </button>
                            </form>
                            <form method="post" style="display:inline" onsubmit="return confirm('Xóa môn <%=id%>?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="MaMon" value="<%= id %>">
                                <button class="btn-icon" aria-label="Xóa" type="submit">
                                    <span class="material-icons-outlined">delete</span>
                                </button>
                            </form>
                        </td>
                    <% } else { %>
                        <form method="post">
                            <input type="hidden" name="action" value="update">
                            <td><input name="MaMon" value="<%= id %>" readonly></td>
                            <td><input name="TenMon" value="<%= tenMon %>" required></td>
                            <td><input name="SoTinChi" type="number" min="1" value="<%= stc %>" required></td>
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