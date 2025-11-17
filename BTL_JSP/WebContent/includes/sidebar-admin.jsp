<%-- File: ../includes/sidebar-admin.jsp --%>
<%@ page pageEncoding="UTF-8" %>

<aside class="sidebar">
  <div class="sidebar-header">
    <img src="../images/logo.png" alt="Logo"> <%-- Dùng logo của bạn --%>
    <h2>Admin <span>Panel</span></h2>
  </div>

  <nav class="sidebar-nav">
    <%-- Lấy trang hiện tại để active menu --%>
    <%
      String currentPage = request.getServletPath();
      String activeClass = "class=\"active\"";
    %>
  
    <a href="../admin/home.jsp" <%= (currentPage.contains("home.jsp")) ? activeClass : "" %>>
      <span>🏠</span> Dashboard
    </a>
    
    <a href="../admin/quanly-sinhvien.jsp" <%= (currentPage.contains("sinhvien.jsp")) ? activeClass : "" %>>
      <span>👤</span> Quản lý Sinh viên
    </a>
    
    <a href="../admin/quanly-giangvien.jsp" <%= (currentPage.contains("giangvien.jsp")) ? activeClass : "" %>>
      <span>🧑‍🏫</span> Quản lý Giảng viên
    </a>
    
    <a href="../admin/quanly-monhoc.jsp" <%= (currentPage.contains("monhoc.jsp")) ? activeClass : "" %>>
      <span>📚</span> Quản lý Môn học
    </a>
    
    <a href="../admin/quanly-khoa.jsp" <%= (currentPage.contains("khoa.jsp")) ? activeClass : "" %>>
      <span>🏛️</span> Quản lý Khoa/Lớp
    </a>
    
    <a href="../admin/quanly-drl.jsp" <%= (currentPage.contains("drl.jsp")) ? activeClass : "" %>>
      <span>📊</span> Quản lý Điểm Rèn Luyện
    </a>

    <a href="../admin/xemdiem.jsp" <%= (currentPage.contains("xemdiem.jsp")) ? activeClass : "" %>>
      <span>📈</span> Xem Điểm (Tổng hợp)
    </a>

    duyetdangky.jsp
    
    <a href="../admin/duyetdangky.jsp" <%= (currentPage.contains("duyetdangky.jsp")) ? activeClass : "" %>>
      <span>📚 </span> Đăng kí tín (Tổng hợp)
    </a>
    <a href="../admin/baocao.jsp" <%= (currentPage.contains("baocao.jsp")) ? activeClass : "" %>>
      <span>📄</span> Báo cáo & Thống kê
    </a>
  </nav>

  <div class="sidebar-footer">
    <a href="../logout.jsp">🚪 Đăng xuất</a>
  </div>
</aside>