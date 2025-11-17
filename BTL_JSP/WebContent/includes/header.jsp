<%@ page pageEncoding="UTF-8" %><header class="header">
  </div>

  <nav class="menu">
    <a href="../sinhvien/home.jsp">Trang chủ</a>

    <div class="menu-dropdown">
      <a href="../sinhvien/hoso.jsp" class="menu-parent">Hồ sơ cá nhân ▾</a>
      <div class="menu-sub">
        <a href="../sinhvien/hoso.jsp">Xem hồ sơ</a>
        <a href="../sinhvien/doimatkhau.jsp"> Đổi mật khẩu</a>
      </div>
    </div>

    <a href="../sinhvien/dangky.jsp">Đăng ký tín chỉ</a>

    <div class="menu-dropdown">
      <a href="../sinhvien/ketqua.jsp" class="menu-parent">Kết quả ▾</a>
      <div class="menu-sub">
        <a href="../sinhvien/ketquahoctap.jsp"> Kết quả học tập</a>
        <a href="../sinhvien/ketquarenluyen.jsp"> Kết quả rèn luyện</a>
      </div>
    </div>

    <div class="menu-dropdown">
      <a href="../sinhvien/thongtin.jsp" class="menu-parent">Thông tin ▾</a>
      <div class="menu-sub">
        <a href="../sinhvien/lichhoc.jsp">Thông tin lịch học</a>
        <a href="../sinhvien/lichthi.jsp"> Thông tin lịch thi</a>
      </div>
    </div>
  </nav>

  <div class="user-area">
    <%
      String ten = (String) session.getAttribute("tenSinhVien");
      String lop = (String) session.getAttribute("lopSinhVien");
      if (ten == null) {
          ten = "Nguyễn Văn A";
          lop = "CNTT-K46";
      }
    %>
    <div class="dropdown">
      <button class="dropdown-btn"><%= ten %> <span>(<%= lop %>)</span> ▾</button>
      <div class="dropdown-content">
        <a href="../logout.jsp"> Đăng xuất</a>
      </div>
    </div>
  </div>
</header>
