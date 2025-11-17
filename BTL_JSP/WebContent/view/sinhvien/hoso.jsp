<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../../db/connect.jsp" %>

<%
    // ===== KIỂM TRA ĐĂNG NHẬP =====
    String maSV = (String) session.getAttribute("maSV");
    if (maSV == null || maSV.trim().isEmpty()) {
        maSV = (String) session.getAttribute("maThamChieu");
    }

    if (maSV == null || maSV.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/WebContent/dangnhap.jsp");
        return;
    }

    // ===== KHAI BÁO BIẾN =====
    String hoTen = "", ngaySinh = "", gioiTinh = "", diaChi = "", soDT = "", email = "", maLop = "";
    String message = "";

    // ===== LẤY THÔNG TIN SINH VIÊN =====
    try {
        String sql = "SELECT * FROM sinhvien WHERE maSV=?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, maSV);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            hoTen = rs.getString("hoTen");
            ngaySinh = rs.getString("ngaySinh");
            gioiTinh = rs.getString("gioiTinh");
            diaChi = rs.getString("diaChi");
            soDT = rs.getString("soDT");
            email = rs.getString("email");
            maLop = rs.getString("maLop");
        }
        rs.close();
        stmt.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Lỗi truy vấn: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Hồ sơ sinh viên | MONKEY</title>

<!-- GỌI CSS NGOÀI -->
<link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style.css">
<link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style-hoso.css">
<link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
</head>

<body>

<!-- SIDEBAR -->
<nav class="sidebar" id="sidebar">
  <div class="sidebar-header">
    <a href="<%= request.getContextPath() %>/view/sinhvien/dashboard.jsp" class="sidebar-logo">
      <img src="<%= request.getContextPath() %>/assets/images/logo.png" alt="Logo">
      <span>MONKEY</span>
    </a>
    <button class="btn-icon btn-close-sidebar" aria-label="Đóng menu" id="close-sidebar">
      <span class="material-icons-outlined">close</span>
    </button>
  </div>

  <div class="sidebar-content">
    <ul class="nav-list" role="menu">
      <li class="nav-item">
        <a href="<%= request.getContextPath() %>/WebContent/view/sinhvien/dashboard.jsp" class="nav-link">
          <span class="material-icons-outlined">space_dashboard</span><span>Trang chủ</span>
        </a>
      </li>
      <li class="nav-item">
        <a href="<%= request.getContextPath() %>/WebContent/view/sinhvien/dangky.jsp" class="nav-link">
          <span class="material-icons-outlined">app_registration</span><span>Đăng ký tín chỉ</span>
        </a>
      </li>
      <li class="nav-item has-submenu is-open">
        <a href="#" class="nav-link-toggle">
          <span class="material-icons-outlined">person</span><span>Thông tin</span>
          <span class="material-icons-outlined expand-icon">expand_more</span>
        </a>
        <ul class="submenu">
          <li><a href="<%= request.getContextPath() %>/WebContent/view/sinhvien/hoso.jsp" class="active">Hồ sơ sinh viên</a></li>
        </ul>
      </li>
      <li>
        <a href="<%= request.getContextPath() %>/WebContent/logout.jsp" class="nav-link logout">
          <span class="material-icons-outlined">logout</span><span>Đăng xuất</span>
        </a>
      </li>
    </ul>
  </div>
</nav>

<!-- MAIN CONTENT -->
<main class="main-content">
  <header class="main-header">
    <div class="header-left">
      <button class="btn-icon btn-open-sidebar" id="open-sidebar">
        <span class="material-icons-outlined">menu</span>
      </button>
      <h1 class="page-title">Hồ sơ sinh viên</h1>
    </div>
  </header>

  <div class="page-content-wrapper">
    <section class="card">
      <div class="card-header">Thông tin cá nhân</div>
      <div class="card-body">

        <% if (!message.isEmpty()) {
             String color = "red";
             if (message.startsWith("✅")) {
                 color = "green";
             }
        %>
            <p class="message" style="color:<%= color %>;"><%= message %></p>
        <% } %>

        <form method="post">
          <div class="info-row"><strong>Mã sinh viên:</strong> <span><input type="text" name="maSV" value="<%= maSV %>" readonly></span></div>
          <div class="info-row"><strong>Họ tên:</strong> <span><input type="text" name="hoTen" value="<%= hoTen %>"></span></div>
          <div class="info-row"><strong>Ngày sinh:</strong> <span><input type="date" name="ngaySinh" value="<%= ngaySinh %>"></span></div>
          <div class="info-row"><strong>Giới tính:</strong> <span><input type="text" name="gioiTinh" value="<%= gioiTinh %>"></span></div>
          <div class="info-row"><strong>Địa chỉ:</strong> <span><input type="text" name="diaChi" value="<%= diaChi %>"></span></div>
          <div class="info-row"><strong>Số điện thoại:</strong> <span><input type="text" name="soDT" value="<%= soDT %>"></span></div>
          <div class="info-row"><strong>Email:</strong> <span><input type="email" name="email" value="<%= email %>"></span></div>
          <div class="info-row"><strong>Mã lớp:</strong> <span><input type="text" name="maLop" value="<%= maLop %>" readonly></span></div>

          <div class="card-footer">
            <button type="submit" class="btn-primary" onclick="return confirm('Xác nhận lưu thay đổi?')">
              <span class="material-icons-outlined" style="font-size:18px;">save</span> Lưu thay đổi
            </button>
          </div>
        </form>
      </div>
    </section>
  </div>
</main>

<div class="sidebar-overlay" id="sidebar-overlay"></div>
<script src="<%= request.getContextPath() %>/WebContent/assets/js/main.js"></script>
</body>
</html>
