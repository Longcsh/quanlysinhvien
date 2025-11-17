
<%@ page import="java.sql.*" %>
<%@ page import="dao.DBConnection" %>
<%
    try {
        Connection conn = DBConnection.getConnection();
        if (conn != null) {
            out.println("<h2 style='color:green;'>✅ Kết nối CSDL thành công!</h2>");
        } else {
            out.println("<h2 style='color:red;'>❌ Kết nối thất bại!</h2>");
        }
    } catch (Exception e) {
        out.println("<h3 style='color:red;'>Lỗi: " + e.getMessage() + "</h3>");
    }
%>
