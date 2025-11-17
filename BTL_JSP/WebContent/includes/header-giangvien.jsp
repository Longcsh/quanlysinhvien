<%@ page pageEncoding="UTF-8" %>
<header class="header">
  <div class="logo">
    <img src="../images/logo.png" alt="Logo Trường">
    <div class="logo-text">
      <h2>TRƯỜNG ĐẠI HỌC 5 CHU KÌ</h2>
      <p>MONKEY UNIVERSITY (GIẢNG VIÊN)</p>
    </div>
  </div>

  <nav class="menu">
    <a href="../giangvien/giangvien_dashboard.jsp">Trang chủ</a>
    <a href="../giangvien/giangvien_hocphan.jsp">Giảng dạy</a>
    <a href="../giangvien/giangvien_chonmon.jsp">Nhập điểm</a>
    <a href="../giangvien/giangvien_renluyen.jsp">Rèn luyện</a>
  </nav>

  <div class="user-area">
    <%
      String tenGV = (String) session.getAttribute("tenGiangVien");
      String maGV = (String) session.getAttribute("maGiangVien");
      if (tenGV != null) {
    %>
      <div class="dropdown">
        <button class="dropdown-btn">
          <%= tenGV %> (<%= maGV %>)
        </button>
        <div class="dropdown-content">
          <a href="../giangvien/hoso.jsp">👤 Hồ sơ</a>
          <a href="../giangvien/doimatkhau.jsp">🔑 Đổi mật khẩu</a>
          <a href="../logout.jsp">🚪 Đăng xuất</a>
        </div>
      </div>
    <% } %>
  </div>
</header>
