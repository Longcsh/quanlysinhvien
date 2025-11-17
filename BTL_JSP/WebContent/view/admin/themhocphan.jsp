<%@ page import="java.sql.*" %>
<%@ include file="../../db/connect.jsp" %>
<%@ include file="header-admin.jsp" %>

<%
request.setCharacterEncoding("UTF-8");
String msg = "";

if (request.getMethod().equalsIgnoreCase("POST")) {
    String maHP = request.getParameter("maHP");
    String maMon = request.getParameter("maMon");
    String nhom = request.getParameter("nhom");
    String phongHoc = request.getParameter("phongHoc");
    String thuHoc = request.getParameter("thuHoc");
    String tietBD = request.getParameter("tietBD");
    String soTiet = request.getParameter("soTiet");
    String ngayBD = request.getParameter("ngayBD");
    String ngayKT = request.getParameter("ngayKT");

    try {
        String sql = "INSERT INTO hocphan (MaHP, MaMon, Nhom, PhongHoc, ThuHoc, TietBatDau, SoTiet, NgayBatDau, NgayKetThuc) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, maHP);
        ps.setString(2, maMon);
        ps.setString(3, nhom);
        ps.setString(4, phongHoc);
        ps.setString(5, thuHoc);
        ps.setInt(6, Integer.parseInt(tietBD));
        ps.setInt(7, Integer.parseInt(soTiet));
        ps.setString(8, ngayBD);
        ps.setString(9, ngayKT);
        ps.executeUpdate();
        ps.close();
        msg = "✅ Thêm học phần mới thành công!";
    } catch (Exception e) {
        msg = "❌ Lỗi: " + e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Thêm học phần | MONKEY Edusoft</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style.css">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
  <style>
    /* Giữ đồng bộ theme admin */
    :root {
      --primary:#0B63E5; --border:#e5e7eb; --card:#fff;
      --radius:14px; --bg:#f5f8fd; --shadow:0 8px 24px rgba(2,6,23,.06);
    }
    body{background:var(--bg);font-family:'Segoe UI',sans-serif;}
    .card{background:var(--card);border-radius:var(--radius);box-shadow:var(--shadow);border:1px solid var(--border);margin:20px;padding:20px;}
    .form-group{margin-bottom:12px;}
    label{font-weight:600;display:block;margin-bottom:5px;}
    input, select{width:100%;padding:8px 10px;border:1px solid var(--border);border-radius:10px;}
    input:focus{border-color:var(--primary);outline:none;box-shadow:0 0 0 3px rgba(11,99,229,.1);}
    .btn-primary{background:var(--primary);color:#fff;border:none;padding:10px 16px;border-radius:10px;cursor:pointer;font-weight:600;}
    .btn-primary:hover{background:#0957cc;}
  </style>
</head>
<body>

<nav class="sidebar" id="sidebar">
  <div class="sidebar-header">
    <a href="admin_dashboard.jsp" class="sidebar-logo">
      <img src="<%= request.getContextPath() %>/WebContent/assets/images/logo.png" alt="Logo">
      <span>MONKEY (Admin)</span>
    </a>
  </div>

  <div class="sidebar-content">
    <ul class="nav-list" role="menu">
      <li class="nav-item"><a href="admin_dashboard.jsp" class="nav-link"><span class="material-icons-outlined">admin_panel_settings</span>Trang chủ Admin</a></li>
      <li class="nav-section-title">Quản lý</li>
      <li class="nav-item"><a href="admin_qlsv.jsp" class="nav-link"><span class="material-icons-outlined">school</span>Quản lý Sinh viên</a></li>
      <li class="nav-item"><a href="admin_qlgv.jsp" class="nav-link"><span class="material-icons-outlined">account_box</span>Quản lý Giảng viên</a></li>
      <li class="nav-item"><a href="admin_qlmh.jsp" class="nav-link"><span class="material-icons-outlined">book</span>Quản lý Môn học</a></li>
      <li class="nav-item"><a href="admin_qllop.jsp" class="nav-link"><span class="material-icons-outlined">corporate_fare</span>Quản lý Khoa/Lớp</a></li>
      <li class="nav-section-title">Nghiệp vụ</li>
      <li class="nav-item"><a href="admin_duyetdangky.jsp" class="nav-link"><span class="material-icons-outlined">how_to_reg</span>Duyệt đăng ký học phần</a></li>
      <li class="nav-item"><a href="admin_themhocphan.jsp" class="nav-link active"><span class="material-icons-outlined">add_box</span>Thêm học phần mới</a></li>
      <li class="nav-item"><a href="admin_bctk.jsp" class="nav-link"><span class="material-icons-outlined">assessment</span>Báo cáo Thống kê</a></li>
    </ul>
  </div>
</nav>

<main class="main-content">
  <header class="main-header">
    <div class="header-left">
      <h1 class="page-title">Thêm học phần mới</h1>
    </div>
  </header>

  <div class="page-content-wrapper">
    <section class="card">
      <form method="post">
        <div class="form-group">
          <label>Mã học phần:</label>
          <input name="maHP" required>
        </div>

        <div class="form-group">
          <label>Mã môn học:</label>
          <input name="maMon" required>
        </div>

        <div class="form-group">
          <label>Nhóm:</label>
          <input name="nhom" required>
        </div>

        <div class="form-group">
          <label>Phòng học:</label>
          <input name="phongHoc" required>
        </div>

        <div class="form-group">
          <label>Thứ học:</label>
          <input name="thuHoc" placeholder="VD: 2, 3, 4..." required>
        </div>

        <div class="form-group">
          <label>Tiết bắt đầu:</label>
          <input name="tietBD" type="number" min="1" required>
        </div>

        <div class="form-group">
          <label>Số tiết:</label>
          <input name="soTiet" type="number" min="1" required>
        </div>

        <div class="form-group">
          <label>Ngày bắt đầu:</label>
          <input type="date" name="ngayBD" required>
        </div>

        <div class="form-group">
          <label>Ngày kết thúc:</label>
          <input type="date" name="ngayKT" required>
        </div>

        <button type="submit" class="btn-primary">
          <span class="material-icons-outlined">add</span> Thêm học phần
        </button>
      </form>
    </section>
  </div>
</main>

<% if (!msg.isEmpty()) { %>
<script>alert("<%= msg.replace("\"", "\\\"") %>");</script>
<% } %>

</body>
</html>
