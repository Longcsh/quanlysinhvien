<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
String maGV = "GV001"; // tạm, sau này bạn lấy từ session
PreparedStatement ps = conn.prepareStatement(
    "SELECT hp.MaHP, hp.MaMon, mh.TenMon, hp.HocKy, hp.NamHoc " +
    "FROM hocphan hp JOIN monhoc mh ON hp.MaMon = mh.MaMon " +
    "WHERE hp.MaGV=?"
);
ps.setString(1, maGV);
ResultSet rs = ps.executeQuery();

List<Map<String,String>> list = new ArrayList<>();
while(rs.next()){
    Map<String,String> r = new HashMap<>();
    r.put("MaHP", rs.getString("MaHP"));
    r.put("MaMon", rs.getString("MaMon"));
    r.put("TenMon", rs.getString("TenMon"));
    r.put("HocKy", rs.getString("HocKy"));
    r.put("NamHoc", rs.getString("NamHoc"));
    list.add(r);
}
rs.close(); ps.close();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Chọn học phần để nhập điểm</title>
<style>
body{font-family:"Segoe UI";background:#f4f6fb;display:flex;margin:0;}
.main{margin-left:230px;padding:40px;width:calc(100% - 230px);}
h2{color:#003366;margin-bottom:25px;}
.table-container{background:white;border-radius:12px;box-shadow:0 4px 10px rgba(0,0,0,0.1);padding:20px;}
table{width:100%;border-collapse:collapse;}
th,td{padding:10px 12px;border-bottom:1px solid #eee;text-align:left;}
th{background:#002b5b;color:white;}
.btn{background:#28a745;color:white;padding:6px 10px;border:none;border-radius:6px;text-decoration:none;}
tbody tr:nth-child(even){background:#f5f7fc;}
</style>
</head>
<body>
<%@ include file="../../includes/sidebar-giangvien.jsp" %>
<div class="main">
<h2>📘 Chọn học phần để nhập điểm</h2>
<div class="table-container">
<table>
<thead><tr><th>STT</th><th>Mã HP</th><th>Tên học phần</th><th>Học kỳ</th><th>Năm học</th><th>Thao tác</th></tr></thead>
<tbody>
<%
int i=1;
for(Map<String,String> hp : list){
%>
<tr>
<td><%=i++%></td>
<td><%=hp.get("MaHP")%></td>
<td><%=hp.get("TenMon")%></td>
<td><%=hp.get("HocKy")%></td>
<td><%=hp.get("NamHoc")%></td>
<td><a href="giangvien_dssv_diem.jsp?mamon=<%=hp.get("MaMon")%>" class="btn">Chọn</a></td>
</tr>
<%}%>
</tbody>
</table>
</div>
</div>
</body>
</html>
