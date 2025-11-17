<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

// ✅ Kiểm tra đăng nhập
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
    String sqlInfo = "SELECT gv.HoTen, k.TenKhoa FROM giangvien gv JOIN khoa k ON gv.MaKhoa = k.MaKhoa WHERE gv.MaGV = ?";
    PreparedStatement psInfo = conn.prepareStatement(sqlInfo);
    psInfo.setString(1, gvID);
    ResultSet rsInfo = psInfo.executeQuery();
    if (rsInfo.next()) {
        hoTenGV = rsInfo.getString("HoTen");
        tenKhoa = rsInfo.getString("TenKhoa");
    }
    rsInfo.close();
    psInfo.close();
} catch (Exception e) {
    out.println("<p style='color:red;'>Lỗi lấy thông tin giảng viên: " + e.getMessage() + "</p>");
}

// ✅ Lấy danh sách học phần
PreparedStatement ps = null;
ResultSet rs = null;
try {
    String sql = "SELECT hp.MaHP, mh.TenMon, mh.SoTinChi, hp.HocKy, hp.NamHoc, "
               + "hp.ThuHoc, hp.PhongHoc, hp.TietBatDau, hp.SoTiet, "
               + "hp.NgayBatDau, hp.NgayKetThuc "
               + "FROM hocphan hp JOIN monhoc mh ON hp.MaMon = mh.MaMon "
               + "WHERE hp.MaGV = ? ORDER BY hp.NamHoc DESC, hp.HocKy ASC";
    ps = conn.prepareStatement(sql);
    ps.setString(1, gvID);
    rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Học phần giảng dạy</title>
<link rel="stylesheet" href="../../assets/css/style-giangvien.css">
<script src="https://kit.fontawesome.com/a2e0f6b6f5.js" crossorigin="anonymous"></script>

<style>
body {
  font-family: "Segoe UI", sans-serif;
  background: #f4f6fb;
  margin: 0;
  display: flex;
  min-height: 100vh;
}

/* ====== MAIN CONTENT ====== */
.main-content {
  margin-left: 230px;
  padding: 40px 60px;
  width: calc(100% - 230px);
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  box-sizing: border-box;
}

/* ====== HEADER INFO ====== */
.header-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  border-bottom: 2px solid #e0e6f1;
  padding-bottom: 10px;
}

.header-info h2 {
  color: #003366;
  font-size: 24px;
  margin: 0;
}

.header-info p {
  color: #666;
  font-size: 15px;
  margin: 5px 0 0 0;
}

.btn-print {
  background: #17a2b8;
  color: #fff;
  border: none;
  padding: 10px 18px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: 0.25s;
}
.btn-print:hover { background: #138496; }

/* ====== TABLE ====== */
.table-container {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
  overflow: hidden;
  flex: 1;
}

table {
  width: 100%;
  border-collapse: collapse;
  border-spacing: 0;
}

thead {
  background: #002b5b;
  color: white;
}
th, td {
  padding: 14px 16px;
  text-align: left;
  font-size: 15px;
  vertical-align: middle;
}
tbody tr:nth-child(even) { background: #f3f6fc; }
tbody tr:hover { background: #e6efff; transition: 0.2s; }

/* ====== BUTTONS ====== */
td:last-child {
  text-align: center;
  white-space: nowrap;
  min-width: 180px;
}

.btn {
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 13.5px;
  text-decoration: none;
  color: white;
  margin: 0 5px;
  display: inline-block;
  transition: 0.25s;
}
.btn-view { background: #007bff; }
.btn-grade { background: #ffc107; color: #222; }
.btn-view:hover { background: #0056b3; }
.btn-grade:hover { background: #e0a800; }

/* ====== XÓA FOOTER ====== */
footer { display: none; }
</style>
</head>

<body>
<%@ include file="../../includes/sidebar-giangvien.jsp" %>

<div class="main-content">
  <div class="header-info">
    <div>
      <h2>📘 Học phần giảng dạy — Giảng viên: <%= hoTenGV %> (<%= gvID %>)</h2>
      <p><b>Khoa:</b> <%= tenKhoa %></p>
    </div>
    <button class="btn-print" onclick="location.href='hocphan_in.jsp'">
      <i class="fa-solid fa-print"></i> In danh sách
    </button>
  </div>

  <div class="table-container">
    <table>
      <thead>
        <tr>
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
          <th>Hành động</th>
        </tr>
      </thead>
      <tbody>
      <%
        boolean coDuLieu = false;
        while (rs.next()) {
          coDuLieu = true;
      %>
        <tr>
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
          <td>
            <a href="giangvien_dssv.jsp?mahp=<%= rs.getString("MaHP") %>" class="btn btn-view">
              <i class="fa-solid fa-users"></i> Sinh viên
            </a>
            <a href="giangvien_chonmon.jsp?mahp=<%= rs.getString("MaHP") %>" class="btn btn-grade">
              <i class="fa-solid fa-pen-to-square"></i> Nhập điểm
            </a>
          </td>
        </tr>
      <%
        }
        if (!coDuLieu) {
      %>
        <tr><td colspan="12" style="text-align:center; color:#888;">Không có học phần nào được giao.</td></tr>
      <%
        }
      %>
      </tbody>
    </table>
  </div>
</div>
</body>
</html>

<%
} catch (Exception e) {
    out.println("<p style='color:red;'>Lỗi khi tải học phần: " + e.getMessage() + "</p>");
} finally {
    if (rs != null) rs.close();
    if (ps != null) ps.close();
}
%>
