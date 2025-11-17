<%@ page import="java.sql.*" %>
<%
String dbURL = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&useSSL=false&serverTimezone=UTC";
String dbUser = "root";
String dbPass = "";
Connection conn = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
} catch (Exception e) {
    out.println("<p style='color:red;'>❌ Lỗi kết nối CSDL: " + e.getMessage() + "</p>");
}
%>
