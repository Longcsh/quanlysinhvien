<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date" %>

<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

Object gvUser = session.getAttribute("user");
Object vaiTro = session.getAttribute("vaiTro");
Object maThamChieu = session.getAttribute("maThamChieu");

if (gvUser == null || vaiTro == null || maThamChieu == null || !vaiTro.toString().equals("2")) {
    response.sendRedirect(request.getContextPath() + "/dangnhap.jsp");
    return;
}

String gvID = maThamChieu.toString();
String hoTenGV = "", tenKhoa = "";

// ✅ Lấy thông tin giảng viên
try {
    String sqlInfo = "SELECT gv.HoTen, k.TenKhoa FROM giangvien gv JOIN khoa k ON gv.MaKhoa = k.MaKhoa WHERE gv.MaGV=?";
    PreparedStatement psInfo = conn.prepareStatement(sqlInfo);
    psInfo.setString(1, gvID);
    ResultSet rsInfo = psInfo.executeQuery();
    if (rsInfo.next()) {
        hoTenGV = rsInfo.getString("HoTen");
        tenKhoa = rsInfo.getString("TenKhoa");
    }
    rsInfo.close();
    psInfo.close();
} catch (Exception e) { out.println("<p style='color:red;'>Lỗi lấy thông tin GV: " + e.getMessage() + "</p>"); }

// ✅ Lấy danh sách học phần
PreparedStatement ps = null;
ResultSet rs = null;
try {
    String sql = "SELECT hp.MaHP, mh.TenMon, mh.SoTinChi, hp.HocKy, hp.NamHoc, hp.ThuHoc, hp.PhongHoc, "
               + "hp.TietBatDau, hp.SoTiet, hp.NgayBatDau, hp.NgayKetThuc "
               + "FROM hocphan hp JOIN monhoc mh ON hp.MaMon = mh.MaMon "
               + "WHERE hp.MaGV = ? ORDER BY hp.NamHoc DESC, hp.HocKy ASC";
    ps = conn.prepareStatement(sql);
    ps.setString(1, gvID);
    rs = ps.executeQuery();

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    String ngayIn = sdf.format(new Date());
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>In danh sách học phần</title>
<style>
@page {
  size: A4;
  margin: 25mm 20mm 25mm 20mm;
}

body {
  font-family: "Times New Roman", serif;
  background: #fff;
  color: #000;
  margin: 0;
}

.header {
  text-align: center;
  border-bottom: 2px solid #000;
  padding-bottom: 10px;
  margin-bottom: 15px;
}

.header img {
  width: 60px;
  vertical-align: middle;
  margin-right: 10px;
}

.header h2 {
  display: inline-block;
  font-size: 22px;
  font-weight: bold;
  margin: 0;
  vertical-align: middle;
}

.info {
  margin-bottom: 15px;
  font-size: 15px;
  line-height: 1.6;
}

.info b {
  color: #000;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
  font-size: 14px;
}

thead {
  background: #003366;
  color: #fff;
}
th, td {
  border: 1px solid #000;
  padding: 8px 10px;
  text-align: left;
}
tbody tr:nth-child(even) {
  background: #f4f6fa;
}

.footer {
  text-align: right;
  font-size: 14px;
  margin-top: 40px;
}

.print-btn {
  display: block;
  margin: 25px auto;
  padding: 10px 20px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  cursor: pointer;
  transition: 0.25s;
}
.print-btn:hover { background: #0056b3; }

@media print {
  .print-btn { display: none; }
  body { margin: 0; background: white; }
}
</style>
</head>

<body>
  <div class="header">
<img src="../../img/Logo_Trường_Đại_học_Thủ_đô_Hà_Nội.jpg" 
     alt="" 
     class="logo">


    <h2>TRƯỜNG ĐẠI HỌC MONKEY</h2>
  </div>

  <div class="info">
    <p><b>Giảng viên:</b> <%= hoTenGV %> (<%= gvID %>)</p>
    <p><b>Khoa:</b> <%= tenKhoa %></p>
    <p><b>Ngày in:</b> <%= ngayIn %></p>
  </div>

  <table>
    <thead>
      <tr>
        <th>STT</th>
        <th>Mã HP</th>
        <th>Tên môn</th>
        <th>Số TC</th>
        <th>Học kỳ</th>
        <th>Năm học</th>
        <th>Thứ</th>
        <th>Phòng</th>
        <th>Tiết bắt đầu</th>
        <th>Số tiết</th>
        <th>Ngày bắt đầu</th>
        <th>Ngày kết thúc</th>
      </tr>
    </thead>
    <tbody>
    <%
      int stt = 1;
      boolean coDuLieu = false;
      while (rs.next()) {
        coDuLieu = true;
    %>
      <tr>
        <td><%= stt++ %></td>
        <td><%= rs.getString("MaHP") %></td>
        <td><%= rs.getString("TenMon") %></td>
        <td><%= rs.getInt("SoTinChi") %></td>
        <td><%= rs.getInt("HocKy") %></td>
        <td><%= rs.getString("NamHoc") %></td>
        <td><%= rs.getString("ThuHoc") %></td>
        <td><%= rs.getString("PhongHoc") %></td>
        <td><%= rs.getInt("TietBatDau") %></td>
        <td><%= rs.getInt("SoTiet") %></td>
        <td><%= rs.getString("NgayBatDau") %></td>
        <td><%= rs.getString("NgayKetThuc") %></td>
      </tr>
    <%
      }
      if (!coDuLieu) {
    %>
      <tr><td colspan="12" style="text-align:center;">Không có học phần nào được giao.</td></tr>
    <%
      }
    %>
    </tbody>
  </table>

  <div class="footer">
    <p><i>Người in: <%= hoTenGV %></i></p>
  </div>

  <button class="print-btn" onclick="window.print()">
    🖨️ In danh sách
  </button>
</body>
</html>

<%
} catch (Exception e) {
    out.println("<p style='color:red;'>Lỗi khi in danh sách: " + e.getMessage() + "</p>");
} finally {
    if (rs != null) rs.close();
    if (ps != null) ps.close();
}
%>
