<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

// ✅ Kiểm tra đăng nhập giảng viên
Object gvUser = session.getAttribute("user");
Object vaiTro = session.getAttribute("vaiTro");
Object maThamChieu = session.getAttribute("maThamChieu");

if (gvUser == null || vaiTro == null || maThamChieu == null || !vaiTro.toString().equals("2")) {
    response.sendRedirect(request.getContextPath() + "/dangnhap.jsp");
    return;
}

String maGV = maThamChieu.toString();
String maHP = request.getParameter("mahp");

// ✅ Lưu danh sách học phần giảng viên đang dạy
List<Map<String, String>> listHP = new ArrayList<>();
String tenMon = "", nhomHP = "", hoTenGV = "";
int tongSV = 0;

try {
    PreparedStatement ps = conn.prepareStatement(
        "SELECT hp.MaHP, mh.TenMon, hp.Nhom FROM hocphan hp JOIN monhoc mh ON hp.MaMon = mh.MaMon WHERE hp.MaGV=?");
    ps.setString(1, maGV);
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        Map<String, String> row = new HashMap<>();
        row.put("MaHP", rs.getString("MaHP"));
        row.put("TenMon", rs.getString("TenMon"));
        row.put("Nhom", rs.getString("Nhom"));
        listHP.add(row);
    }
    rs.close(); ps.close();

    PreparedStatement psGV = conn.prepareStatement("SELECT HoTen FROM giangvien WHERE MaGV=?");
    psGV.setString(1, maGV);
    ResultSet rsGV = psGV.executeQuery();
    if (rsGV.next()) hoTenGV = rsGV.getString("HoTen");
    rsGV.close(); psGV.close();

} catch (Exception e) {
    out.println("<p style='color:red;'>Lỗi: " + e.getMessage() + "</p>");
}

// ✅ Nếu chọn học phần → lấy sinh viên
ResultSet rsSV = null;
if (maHP != null && !maHP.trim().isEmpty()) {
    try {
        PreparedStatement psInfo = conn.prepareStatement(
            "SELECT mh.TenMon, hp.Nhom FROM hocphan hp JOIN monhoc mh ON hp.MaMon=mh.MaMon WHERE hp.MaHP=?");
        psInfo.setString(1, maHP);
        ResultSet rsInfo = psInfo.executeQuery();
        if (rsInfo.next()) {
            tenMon = rsInfo.getString("TenMon");
            nhomHP = rsInfo.getString("Nhom");
        }
        rsInfo.close(); psInfo.close();

        PreparedStatement psSV = conn.prepareStatement(
            "SELECT sv.MaSV, sv.HoTen, sv.Email, sv.SoDT, l.TenLop " +
            "FROM sinhvien sv " +
            "JOIN lop l ON sv.MaLop = l.MaLop " +
            "JOIN dangkyhocphan dk ON sv.MaSV = dk.MaSV " +
            "WHERE dk.MaHP=?");
        psSV.setString(1, maHP);
        rsSV = psSV.executeQuery();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Lỗi lấy danh sách SV: " + e.getMessage() + "</p>");
    }
}
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Danh sách Sinh viên học phần</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
body {
  font-family: "Segoe UI", sans-serif;
  background: #f4f6fb;
  margin: 0;
  display: flex;
}
.main-content {
  margin-left: 230px;
  padding: 40px 60px;
  width: calc(100% - 230px);
  box-sizing: border-box;
}
.header-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid #e0e6f1;
  margin-bottom: 20px;
}
.header-info h2 {
  color: #003366;
  font-size: 22px;
  margin: 0;
}
select {
  padding: 8px 10px;
  border-radius: 6px;
  border: 1px solid #ccc;
  font-size: 15px;
}
.table-container {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
  margin-top: 25px;
  overflow: hidden;
}
table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
}
thead {
  background: #002b5b;
  color: #fff;
}
th, td {
  padding: 12px 14px;
  border-bottom: 1px solid #eaeaea;
}
tbody tr:nth-child(even) { background: #f5f7fc; }
tbody tr:hover { background: #e9f2ff; }

/* ===== Buttons ===== */
.btn-actions {
  display: flex;
  gap: 10px;
  margin: 20px 0;
}
.btn {
  border: none;
  border-radius: 6px;
  padding: 8px 14px;
  cursor: pointer;
  color: #fff;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: 0.3s;
}
.btn:hover { opacity: 0.9; }
.btn-print { background: #17a2b8; }
.btn-excel { background: #28a745; }

/* ===== In chuyên nghiệp ===== */
@media print {
  body {
    margin: 0;
    background: #fff;
    font-family: "Times New Roman", serif;
    -webkit-print-color-adjust: exact;
  }
  .main-content {
    margin: 0;
    padding: 25px 50px;
    width: 100%;
  }
  #sidebar, .btn-actions, .header-info, form, select {
    display: none !important;
  }
  .table-container {
    box-shadow: none;
    width: 100%;
    margin: 0;
  }
  table {
    width: 100%;
    font-size: 15px;
    border: 1px solid #000;
    border-collapse: collapse;
    margin-top: 15px;
  }
  th, td {
    border: 1px solid #000 !important;
    padding: 8px 10px;
    text-align: center;
  }
  th {
    background: #002b5b !important;
    color: white !important;
  }
  .print-header {
    display: block !important;
    text-align: center;
    margin-bottom: 25px;
  }
  .print-header img {
    width: 70px;
    margin-bottom: 10px;
  }
  .print-header h1 {
    font-size: 22px;
    color: #002b5b;
    font-weight: 700;
    margin: 0;
  }
  .print-header h2 {
    font-size: 17px;
    margin: 8px 0;
    font-weight: 600;
  }
  .print-header p {
    font-size: 14px;
    margin: 3px 0;
  }
  .signature {
    display: block !important;
    width: 100%;
    margin-top: 50px;
    text-align: right;
    padding-right: 80px;
    font-size: 15px;
  }
  .signature p { margin: 4px 0; }
  .signature .sign-line {
    margin-top: 60px;
    font-weight: bold;
    text-decoration: underline;
  }
  @page {
    size: A4 portrait;
    margin: 20mm 15mm 25mm 15mm;
  }
}

/* ===== Header in PDF/Print ===== */
.print-header {
  display: none;
  text-align: center;
  margin-bottom: 15px;
}
.print-header img {
  width: 60px;
  vertical-align: middle;
  margin-right: 10px;
}
.print-header h1 {
  font-size: 22px;
  margin: 5px 0;
  color: #002b5b;
}
.print-header p {
  font-size: 14px;
  margin: 2px 0;
}
.signature {
  display: none;
}
</style>
</head>

<body>
<%@ include file="../../includes/sidebar-giangvien.jsp" %>

<div class="main-content">
  <div class="header-info">
    <h2><i class="fa-solid fa-users"></i> Quản lý sinh viên theo học phần</h2>
    <div>
      <form method="get" action="">
        <label><i class="fa-solid fa-book"></i> Chọn học phần:</label>
        <select name="mahp" onchange="this.form.submit()">
          <option value="">-- Chọn học phần --</option>
          <%
            for (Map<String, String> hp : listHP) {
              String id = hp.get("MaHP");
              String selected = (maHP != null && maHP.equals(id)) ? "selected" : "";
          %>
              <option value="<%= id %>" <%= selected %>>
                <%= hp.get("TenMon") %> - Nhóm <%= hp.get("Nhom") %>
              </option>
          <%
            }
          %>
        </select>
      </form>
    </div>
  </div>

  <% if (maHP != null && !maHP.isEmpty()) { %>
  <div class="print-header">
<img src="../../img/Logo_Trường_Đại_học_Thủ_đô_Hà_Nội.jpg" 
     alt="" 
     class="logo">


    <h1>TRƯỜNG ĐẠI HỌC MONKEY</h1>
    <h2>DANH SÁCH SINH VIÊN HỌC PHẦN</h2>
    <p><b>Môn học:</b> <%= tenMon %> — <b>Nhóm:</b> <%= nhomHP %></p>
    <p><b>Giảng viên phụ trách:</b> <%= hoTenGV %></p>
    <p><b>Ngày in:</b> <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></p>
  </div>

  <div class="table-container">
    <div class="btn-actions">
      <button class="btn btn-excel" onclick="exportTableToExcel('tableSV', 'DanhSach_<%= maHP %>')">
        <i class="fa-solid fa-file-excel"></i> Xuất Excel
      </button>
      <button class="btn btn-print" onclick="window.print()">
        <i class="fa-solid fa-print"></i> In danh sách
      </button>
    </div>

    <%
      List<Map<String, String>> listSV = new ArrayList<>();
      if (rsSV != null) {
        while (rsSV.next()) {
          Map<String, String> row = new HashMap<>();
          row.put("MaSV", rsSV.getString("MaSV"));
          row.put("HoTen", rsSV.getString("HoTen"));
          row.put("TenLop", rsSV.getString("TenLop"));
          row.put("Email", rsSV.getString("Email"));
          row.put("SoDT", rsSV.getString("SoDT"));
          listSV.add(row);
        }
        tongSV = listSV.size();
        rsSV.close();
      }
    %>

    <p style="font-size:15px; font-style:italic; margin-left:10px;">
      Tổng số sinh viên: <b><%= tongSV %></b> người
    </p>

    <table id="tableSV">
      <thead>
        <tr>
          <th>STT</th>
          <th>Mã SV</th>
          <th>Họ và tên</th>
          <th>Lớp</th>
          <th>Email</th>
          <th>Điện thoại</th>
        </tr>
      </thead>
      <tbody>
      <%
        if (tongSV > 0) {
          int i = 1;
          for (Map<String,String> sv : listSV) {
      %>
        <tr>
          <td><%= i++ %></td>
          <td><%= sv.get("MaSV") %></td>
          <td><%= sv.get("HoTen") %></td>
          <td><%= sv.get("TenLop") %></td>
          <td><%= sv.get("Email") %></td>
          <td><%= sv.get("SoDT") %></td>
        </tr>
      <%  }
        } else { %>
        <tr><td colspan='6' style="text-align:center;color:#888;">Chưa có sinh viên đăng ký học phần này.</td></tr>
      <% } %>
      </tbody>
    </table>

    <div class="signature">
      <p><b>Giảng viên phụ trách</b></p>
      <p><i>(Ký và ghi rõ họ tên)</i></p>
      <p class="sign-line"><%= hoTenGV %></p>
    </div>
  </div>
  <% } else { %>
    <p style="margin-top:30px;color:#666;">Hãy chọn một học phần để xem danh sách sinh viên.</p>
  <% } %>
</div>

<script>
// ✅ Xuất Excel có hỗ trợ tiếng Việt
function exportTableToExcel(tableID, filename = '') {
  const dataType = 'application/vnd.ms-excel;charset=utf-8';
  const tableSelect = document.getElementById(tableID);
  const tableHTML = encodeURIComponent('<meta charset="UTF-8">' + tableSelect.outerHTML);
  const downloadLink = document.createElement("a");
  filename = filename ? filename + '.xls' : 'excel_data.xls';

  downloadLink.href = 'data:' + dataType + ',' + tableHTML;
  downloadLink.download = filename;
  document.body.appendChild(downloadLink);
  downloadLink.click();
  document.body.removeChild(downloadLink);
}
</script>
</body>
</html>
