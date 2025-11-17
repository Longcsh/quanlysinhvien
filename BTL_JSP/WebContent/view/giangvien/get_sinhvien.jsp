<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*" %>

<%
String maSV = request.getParameter("masv");
String result = "{}";

try {
    String sql = "SELECT MaSV, HoTen, Lop, Email, DienThoai FROM sinhvien WHERE MaSV=?";
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setString(1, maSV);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        result = String.format("{\"MaSV\":\"%s\",\"HoTen\":\"%s\",\"Lop\":\"%s\",\"Email\":\"%s\",\"DienThoai\":\"%s\"}",
            rs.getString("MaSV"), rs.getString("HoTen"), rs.getString("Lop"), rs.getString("Email"), rs.getString("DienThoai"));
    }
    rs.close(); ps.close();
} catch (Exception e) {
    result = "{\"error\":\"" + e.getMessage() + "\"}";
}
out.print(result);
%>
