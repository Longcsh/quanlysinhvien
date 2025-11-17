<%-- File: ../includes/header-admin.jsp --%>
<%@ page pageEncoding="UTF-8" %>

<header class="top-bar">
  <div class="search-bar">
    <input type="text" placeholder="Tìm kiếm sinh viên, giảng viên, môn học...">
  </div>
  
  <div class="top-bar-actions">
    <span class="icon-btn">🔔</span> <%-- Icon Thông báo --%>
    
    <div class="admin-profile">
      <%
        String adminName = (String) session.getAttribute("adminName");
        if (adminName == null) adminName = "Admin";
      %>
      <div class="avatar"><%= adminName.charAt(0) %></div>
      <span>Xin chào, <strong><%= adminName %></strong></span>
    </div>
  </div>
</header>