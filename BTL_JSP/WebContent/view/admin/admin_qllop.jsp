<%
    String JDBC_URL  = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String JDBC_USER = "root";
    String JDBC_PASS = "";

    // ====== NHẬN THAM SỐ (tách 2 khối khoa & lớp) ======
    String actionK  = request.getParameter("actionK");   // add | update | delete (KHOA)
    String mkParam  = request.getParameter("MaKhoa");
    String tenKParam= request.getParameter("TenKhoa");

    String actionL  = request.getParameter("actionL");   // add | update | delete (LOP)
    String mlParam  = request.getParameter("MaLop");
    String tlParam  = request.getParameter("TenLop");
    String mkOfLop  = request.getParameter("MaKhoaOfLop"); // tránh trùng tên với Khoa
    String nienKhoa = request.getParameter("NienKhoa");
    String coVanID  = request.getParameter("CoVanID");

    // Cờ hiển thị form
    String showAddK = request.getParameter("showAddK");
    String editK    = request.getParameter("editK");     // MaKhoa đang sửa
    String showAddL = request.getParameter("showAddL");
    String editL    = request.getParameter("editL");     // MaLop đang sửa

    try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {

        // ---------- CRUD: KHOA ----------
        if (actionK != null) {
            if ("add".equals(actionK)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO khoa(MaKhoa, TenKhoa) VALUES(?,?)")) {
                    ps.setString(1, mkParam);
                    ps.setString(2, tenKParam);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI()); return;

            } else if ("update".equals(actionK)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE khoa SET TenKhoa=? WHERE MaKhoa=?")) {
                    ps.setString(1, tenKParam);
                    ps.setString(2, mkParam);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI()); return;

            } else if ("delete".equals(actionK)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM khoa WHERE MaKhoa=?")) {
                    ps.setString(1, mkParam);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI()); return;
            }
        }

        // ---------- CRUD: LỚP ----------
        if (actionL != null) {
            if ("add".equals(actionL)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO lop(MaLop, TenLop, MaKhoa, CoVanID, NienKhoa) VALUES(?,?,?,?,?)")) {
                    ps.setString(1, mlParam);
                    ps.setString(2, tlParam);
                    ps.setString(3, mkOfLop);
                    ps.setString(4, (coVanID==null||coVanID.isEmpty())? null : coVanID);
                    ps.setString(5, (nienKhoa==null||nienKhoa.isEmpty())? null : nienKhoa);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI()); return;

            } else if ("update".equals(actionL)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE lop SET TenLop=?, MaKhoa=?, CoVanID=?, NienKhoa=? WHERE MaLop=?")) {
                    ps.setString(1, tlParam);
                    ps.setString(2, mkOfLop);
                    ps.setString(3, (coVanID==null||coVanID.isEmpty())? null : coVanID);
                    ps.setString(4, (nienKhoa==null||nienKhoa.isEmpty())? null : nienKhoa);
                    ps.setString(5, mlParam);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI()); return;

            } else if ("delete".equals(actionL)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM lop WHERE MaLop=?")) {
                    ps.setString(1, mlParam);
                    ps.executeUpdate();
                }
                response.sendRedirect(request.getRequestURI()); return;
            }
        }

        // ---------- Danh mục Khoa (đổ select & bảng) ----------
        List<Map<String,String>> dsKhoa = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT MaKhoa, TenKhoa FROM khoa ORDER BY TenKhoa");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> m = new HashMap<>();
                m.put("MaKhoa", rs.getString("MaKhoa"));
                m.put("TenKhoa", rs.getString("TenKhoa"));
                dsKhoa.add(m);
            }
        }
        request.setAttribute("dsKhoa", dsKhoa);

        // ---------- Danh sách Lớp (LEFT JOIN tên khoa) ----------
        List<Map<String,Object>> dsLop = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT l.MaLop, l.TenLop, l.MaKhoa, l.CoVanID, l.NienKhoa, " +
                "       COALESCE(k.TenKhoa, l.MaKhoa) AS TenKhoa " +
                "FROM lop l LEFT JOIN khoa k ON l.MaKhoa=k.MaKhoa ORDER BY l.MaLop");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> r = new HashMap<>();
                r.put("MaLop",   rs.getString("MaLop"));
                r.put("TenLop",  rs.getString("TenLop"));
                r.put("MaKhoa",  rs.getString("MaKhoa"));
                r.put("TenKhoa", rs.getString("TenKhoa"));
                r.put("CoVanID", rs.getString("CoVanID"));
                r.put("NienKhoa",rs.getString("NienKhoa"));
                dsLop.add(r);
            }
        }
        request.setAttribute("dsLop", dsLop);

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
    <title>Quản lý Khoa/Lớp | MONKEY Edusoft</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/css/style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <style>
      /* ======================================================
   MONKEY Edusoft – Admin Panel CSS
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

/* ---------- TABLE (CHUNG) ---------- */
.table-responsive{width:100%;overflow:auto}
.course-table{
  width:100%;border-collapse:separate;border-spacing:0;
  min-width:600px;
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
form[onsubmit] .btn-icon{
  color:var(--danger);border-color:#fca5a5;background:#fee2e2;
}
form[onsubmit] .btn-icon:hover{background:#fecaca}

/* ---------- BẢNG MÔN HỌC ---------- */
.course-table thead th:nth-child(1){width:140px;}
.course-table thead th:nth-child(2){width:auto;}
.course-table thead th:nth-child(3){width:120px;text-align:center;}
.course-table thead th:nth-child(4){width:140px;text-align:center;}
.course-table td:nth-child(3),
.course-table td:nth-child(4){text-align:center;}
.course-table input[name="MaMon"]{max-width:120px;}
.course-table input[name="TenMon"]{min-width:240px;}
.course-table input[name="SoTinChi"]{max-width:90px;text-align:center;}

/* ---------- KHOA / LỚP ---------- */
.page-content-wrapper{padding:6px 10px 24px}
.main-announcement-grid{
  display:grid;gap:16px;grid-template-columns:1fr;
}
@media (min-width: 980px){
  .main-announcement-grid{grid-template-columns:1fr 1fr}
}

/* Bảng Khoa */
.course-table.khoa-table{min-width:520px;}
.course-table.khoa-table thead th:nth-child(1){width:140px;}
.course-table.khoa-table thead th:nth-child(2){width:auto;}
.course-table.khoa-table thead th:nth-child(3){width:140px;text-align:center;}
.course-table.khoa-table tbody td:nth-child(3){text-align:center;}
.course-table.khoa-table input[name="MaKhoa"]{max-width:140px;text-transform:uppercase;}
.course-table.khoa-table input[name="TenKhoa"]{min-width:240px;}

/* Bảng Lớp */
.course-table.lop-table{min-width:880px;}
.course-table.lop-table thead th:nth-child(1){width:140px;}
.course-table.lop-table thead th:nth-child(2){width:auto;}
.course-table.lop-table thead th:nth-child(3){width:220px;}
.course-table.lop-table thead th:nth-child(4){width:130px;text-align:center;}
.course-table.lop-table thead th:nth-child(5){width:120px;text-align:center;}
.course-table.lop-table thead th:nth-child(6){width:150px;text-align:center;}
.course-table.lop-table tbody td:nth-child(4),
.course-table.lop-table tbody td:nth-child(5),
.course-table.lop-table tbody td:nth-child(6){text-align:center;}
.course-table.lop-table input[name="MaLop"]{max-width:140px;text-transform:uppercase;}
.course-table.lop-table input[name="TenLop"]{min-width:240px;}
.course-table.lop-table select[name="MaKhoaOfLop"]{min-width:220px;}
.course-table.lop-table input[name="NienKhoa"]{max-width:130px;text-align:center;}
.course-table.lop-table input[name="CoVanID"]{max-width:120px;text-align:center;}
.course-table.khoa-table td form,
.course-table.lop-table td form{display:inline-block;margin:0 4px;}
.course-table.khoa-table tbody tr:hover,
.course-table.lop-table tbody tr:hover{background:#f6f9ff;}

/* ---------- UTILS ---------- */
.text-success{color:var(--success)!important}
.text-danger{color:var(--danger)!important}
.text-warning{color:var(--warning)!important}
a{color:var(--primary);text-decoration:none}
a:hover{text-decoration:underline}
.material-icons-outlined{vertical-align:middle;line-height:1}

/* ---------- SIDEBAR OVERLAY + RESPONSIVE ---------- */
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

/* ---------- SCROLLBAR ---------- */
::-webkit-scrollbar{width:8px;height:8px}
::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:10px}
::-webkit-scrollbar-thumb:hover{background:#94a3b8}

/* ---------- HOVER CHO HÀNG BẢNG ---------- */
.course-table tbody tr:hover td{background:#f8fbff}

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
                <li class="nav-item" role="menuitem"><a href="admin_qlmh.jsp" class="nav-link"><span class="material-icons-outlined">book</span><span>Quản lý Môn học</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qllop.jsp" class="nav-link active"><span class="material-icons-outlined">corporate_fare</span><span>Quản lý Khoa/Lớp</span></a></li>
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
                <h1 class="page-title">Quản lý Khoa/Lớp</h1>
            </div>
            <div class="header-right">
                </div>
        </header>

        <div class="page-content-wrapper">
            <div class="main-announcement-grid"> 
<section class="card">
  <div class="card-header">
    <h2 class="section-title">Danh sách Khoa</h2>
    <div class="form-actions">
      <form method="get" style="display:inline">
        <input type="hidden" name="showAddK" value="1">
        <button class="btn-primary" type="submit">
          <span class="material-icons-outlined">add</span>Thêm mới Khoa
        </button>
      </form>
    </div>
  </div>

  <div class="table-responsive">
    <table class="course-table">
      <thead>
        <tr>
          <th>Mã Khoa</th><th>Tên Khoa</th><th>Hành động</th>
        </tr>
      </thead>
      <tbody>
        <% if ("1".equals(request.getParameter("showAddK"))) { %>
        <tr>
          <form method="post">
            <input type="hidden" name="actionK" value="add">
            <td><input name="MaKhoa" required maxlength="5"></td>
            <td><input name="TenKhoa" required></td>
            <td>
              <button class="btn-icon" aria-label="Lưu"><span class="material-icons-outlined">check</span></button>
              <a class="btn-icon" href="<%=request.getRequestURI()%>" aria-label="Hủy"><span class="material-icons-outlined">close</span></a>
            </td>
          </form>
        </tr>
        <% } %>

        <%
          List<Map<String,String>> _k = (List<Map<String,String>>) request.getAttribute("dsKhoa");
          if (_k!=null) for (Map<String,String> r : _k) {
            String mk = r.get("MaKhoa"), tk = r.get("TenKhoa");
            boolean editing = mk.equals(request.getParameter("editK"));
        %>
        <tr>
          <% if (!editing) { %>
            <td><%= mk %></td><td><%= tk %></td>
            <td>
              <form method="get" style="display:inline">
                <input type="hidden" name="editK" value="<%= mk %>">
                <button class="btn-icon" aria-label="Sửa"><span class="material-icons-outlined">edit</span></button>
              </form>
              <form method="post" style="display:inline" onsubmit="return confirm('Xóa khoa <%=mk%>?');">
                <input type="hidden" name="actionK" value="delete">
                <input type="hidden" name="MaKhoa" value="<%= mk %>">
                <button class="btn-icon" aria-label="Xóa"><span class="material-icons-outlined">delete</span></button>
              </form>
            </td>
          <% } else { %>
            <form method="post">
              <input type="hidden" name="actionK" value="update">
              <td><input name="MaKhoa" value="<%= mk %>" readonly></td>
              <td><input name="TenKhoa" value="<%= tk %>" required></td>
              <td>
                <button class="btn-icon" aria-label="Lưu"><span class="material-icons-outlined">check</span></button>
                <a class="btn-icon" href="<%=request.getRequestURI()%>" aria-label="Hủy"><span class="material-icons-outlined">close</span></a>
              </td>
            </form>
          <% } %>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</section>

<section class="card">
  <div class="card-header">
    <h2 class="section-title">Danh sách Lớp</h2>
    <div class="form-actions">
      <form method="get" style="display:inline">
        <input type="hidden" name="showAddL" value="1">
        <button class="btn-primary" type="submit">
          <span class="material-icons-outlined">add</span>Thêm mới Lớp
        </button>
      </form>
    </div>
  </div>

  <div class="table-responsive">
    <table class="course-table">
      <thead>
        <tr>
          <th>Mã Lớp</th><th>Tên Lớp</th><th>Khoa</th><th>Niên khóa</th><th>Cố vấn</th><th>Hành động</th>
        </tr>
      </thead>
      <tbody>
        <% if ("1".equals(request.getParameter("showAddL"))) { %>
        <tr>
          <form method="post">
            <input type="hidden" name="actionL" value="add">
            <td><input name="MaLop" required maxlength="10"></td>
            <td><input name="TenLop" required></td>
            <td>
              <select name="MaKhoaOfLop" required>
                <%
                  List<Map<String,String>> _dsKhoa = (List<Map<String,String>>) request.getAttribute("dsKhoa");
                  if (_dsKhoa!=null) for (Map<String,String> k : _dsKhoa) {
                %>
                  <option value="<%=k.get("MaKhoa")%>"><%=k.get("TenKhoa")%> (<%=k.get("MaKhoa")%>)</option>
                <% } %>
              </select>
            </td>
            <td><input name="NienKhoa" placeholder="VD: 2023-2027"></td>
            <td><input name="CoVanID" placeholder="MaGV (tùy chọn)"></td>
            <td>
              <button class="btn-icon" aria-label="Lưu"><span class="material-icons-outlined">check</span></button>
              <a class="btn-icon" href="<%=request.getRequestURI()%>" aria-label="Hủy"><span class="material-icons-outlined">close</span></a>
            </td>
          </form>
        </tr>
        <% } %>

        <%
          List<Map<String,Object>> _lop = (List<Map<String,Object>>) request.getAttribute("dsLop");
          if (_lop!=null) for (Map<String,Object> r : _lop) {
            String ml = (String) r.get("MaLop");
            String tl = (String) r.get("TenLop");
            String mk = (String) r.get("MaKhoa");
            String tk = (String) r.get("TenKhoa");
            String nk = (String) r.get("NienKhoa");
            String cv = (String) r.get("CoVanID");
            boolean editing = ml.equals(request.getParameter("editL"));
        %>
        <tr>
          <% if (!editing) { %>
            <td><%= ml %></td><td><%= tl %></td><td><%= tk %></td><td><%= nk==null?"":nk %></td><td><%= cv==null?"":cv %></td>
            <td>
              <form method="get" style="display:inline">
                <input type="hidden" name="editL" value="<%= ml %>">
                <button class="btn-icon" aria-label="Sửa"><span class="material-icons-outlined">edit</span></button>
              </form>
              <form method="post" style="display:inline" onsubmit="return confirm('Xóa lớp <%=ml%>?');">
                <input type="hidden" name="actionL" value="delete">
                <input type="hidden" name="MaLop" value="<%= ml %>">
                <button class="btn-icon" aria-label="Xóa"><span class="material-icons-outlined">delete</span></button>
              </form>
            </td>
          <% } else { %>
            <form method="post">
              <input type="hidden" name="actionL" value="update">
              <td><input name="MaLop" value="<%= ml %>" readonly></td>
              <td><input name="TenLop" value="<%= tl %>" required></td>
              <td>
                <select name="MaKhoaOfLop" required>
                  <%
                    List<Map<String,String>> k2 = (List<Map<String,String>>) request.getAttribute("dsKhoa");
                    if (k2!=null) for (Map<String,String> k : k2) {
                      String sel = k.get("MaKhoa").equals(mk) ? "selected" : "";
                  %>
                    <option value="<%=k.get("MaKhoa")%>" <%=sel%>>
                      <%=k.get("TenKhoa")%> (<%=k.get("MaKhoa")%>)
                    </option>
                  <% } %>
                </select>
              </td>
              <td><input name="NienKhoa" value="<%= nk==null?"":nk %>"></td>
              <td><input name="CoVanID" value="<%= cv==null?"":cv %>"></td>
              <td>
                <button class="btn-icon" aria-label="Lưu"><span class="material-icons-outlined">check</span></button>
                <a class="btn-icon" href="<%=request.getRequestURI()%>" aria-label="Hủy"><span class="material-icons-outlined">close</span></a>
              </td>
            </form>
          <% } %>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
</section>

            </div>
        </div>
    </main>

    <div class="sidebar-overlay" id="sidebar-overlay"></div>
    <script src="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/js/main.js"></script>
</body>
</html>