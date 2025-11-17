<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%
    String idParam = request.getParameter("id");
    if (idParam == null) return;
    int id = Integer.parseInt(idParam);

    PreparedStatement ps = conn.prepareStatement("SELECT * FROM thongbao WHERE id=?");
    ps.setInt(1, id);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
%>
    <h3><%= rs.getString("tieu_de") %></h3>
    <div class="meta">
        <b><%= rs.getString("loai") %></b> | <%= rs.getDate("ngay_dang") %>
    </div>
    <hr>
    <div><%= rs.getString("noi_dung").replaceAll("\n", "<br>") %></div>
<%
    } else {
        out.print("<p style='text-align:center;color:gray;'>Không tìm thấy nội dung.</p>");
    }
    rs.close();
    ps.close();
    conn.close();
%>
