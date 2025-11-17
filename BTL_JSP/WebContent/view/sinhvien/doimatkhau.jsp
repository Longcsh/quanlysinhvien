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
    String message = "";
    String matKhauCu = request.getParameter("matkhau_cu");
    String matKhauMoi = request.getParameter("matkhau_moi");
    String matKhauLai = request.getParameter("matkhau_lai");

    // ===== XỬ LÝ KHI GỬI FORM =====
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            // 1️⃣ Lấy mật khẩu hiện tại từ DB
            String sqlCheck = "SELECT MatKhau FROM nguoidung WHERE MaThamChieu=?";
            PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
            psCheck.setString(1, maSV);
            ResultSet rs = psCheck.executeQuery();

            if (rs.next()) {
                String matKhauHienTai = rs.getString("MatKhau");

                if (!matKhauCu.equals(matKhauHienTai)) {
                    message = "❌ Mật khẩu cũ không chính xác!";
                } else if (!matKhauMoi.equals(matKhauLai)) {
                    message = "⚠️ Mật khẩu mới và nhập lại không khớp!";
                } else {
                    // 2️⃣ Cập nhật mật khẩu mới
                    String sqlUpdate = "UPDATE nguoidung SET MatKhau=? WHERE MaThamChieu=?";
                    PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate);
                    psUpdate.setString(1, matKhauMoi);
                    psUpdate.setString(2, maSV);
                    int updated = psUpdate.executeUpdate();

                    if (updated > 0) {
                        message = "✅ Đổi mật khẩu thành công!";
                    } else {
                        message = "⚠️ Không thể cập nhật mật khẩu!";
                    }
                    psUpdate.close();
                }
            } else {
                message = "❌ Không tìm thấy tài khoản!";
            }

            rs.close();
            psCheck.close();
        } catch (Exception e) {
            message = "❌ Lỗi: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Đổi mật khẩu | MONKEY</title>
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
      <li class="nav-item has-submenu is-open">
        <a href="#" class="nav-link-toggle">
          <span class="material-icons-outlined">person</span><span>Tài khoản</span>
          <span class="material-icons-outlined expand-icon">expand_more</span>
        </a>
        <ul class="submenu">
          <li><a href="hoso.jsp">Hồ sơ sinh viên</a></li>
          <li><a href="doimatkhau.jsp" class="active">Đổi mật khẩu</a></li>
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
      <h1 class="page-title">Đổi mật khẩu</h1>
    </div>
  </header>

  <div class="page-content-wrapper">
    <section class="card">
      <div class="card-header">Thay đổi mật khẩu</div>
      <div class="card-body">
        <% if (!message.isEmpty()) { 
             String color = message.startsWith("✅") ? "green" : "red"; %>
          <p style="text-align:center; font-weight:600; color:<%= color %>;"><%= message %></p>
        <% } %>

        <form method="post">
          <div class="info-row"><strong>Mật khẩu hiện tại:</strong> 
            <span><input type="password" name="matkhau_cu" required></span>
          </div>

          <div class="info-row"><strong>Mật khẩu mới:</strong> 
            <span><input type="password" name="matkhau_moi" required></span>
          </div>

          <div class="info-row"><strong>Nhập lại mật khẩu mới:</strong> 
            <span><input type="password" name="matkhau_lai" required></span>
          </div>

          <div class="card-footer">
            <button type="submit" class="btn-primary" onclick="return confirm('Xác nhận đổi mật khẩu?')">
              <span class="material-icons-outlined" style="font-size:18px;">lock_reset</span> Lưu thay đổi
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
