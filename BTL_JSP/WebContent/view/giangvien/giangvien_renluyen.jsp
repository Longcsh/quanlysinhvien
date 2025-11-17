<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

// ✅ Kiểm tra đăng nhập & vai trò giảng viên
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
    PreparedStatement psInfo = conn.prepareStatement(
        "SELECT gv.HoTen, k.TenKhoa FROM giangvien gv JOIN khoa k ON gv.MaKhoa = k.MaKhoa WHERE gv.MaGV=?");
    psInfo.setString(1, gvID);
    ResultSet rsInfo = psInfo.executeQuery();
    if (rsInfo.next()) {
        hoTenGV = rsInfo.getString("HoTen");
        tenKhoa = rsInfo.getString("TenKhoa");
    }
    rsInfo.close(); psInfo.close();
} catch (Exception e) {
    out.print("<p style='color:red;'>Lỗi lấy thông tin GV: "+e.getMessage()+"</p>");
}

// ================= XỬ LÝ LƯU =================
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String[] maSVs = request.getParameterValues("masv");
    String[] muc1 = request.getParameterValues("muc1");
    String[] muc2 = request.getParameterValues("muc2");
    String[] muc3 = request.getParameterValues("muc3");
    String[] muc4 = request.getParameterValues("muc4");

    if (maSVs != null) {
        for (int i = 0; i < maSVs.length; i++) {
            double d1 = Double.parseDouble(muc1[i]);
            double d2 = Double.parseDouble(muc2[i]);
            double d3 = Double.parseDouble(muc3[i]);
            double d4 = Double.parseDouble(muc4[i]);
            double tong = d1 + d2 + d3 + d4;
            String xepLoai = tong >= 80 ? "Tốt" : tong >= 65 ? "Khá" : tong >= 50 ? "TB" : "Yếu";

            PreparedStatement psUp = conn.prepareStatement(
                "INSERT INTO diemrenluyen (MaSV, HocKy, NamHoc, Diem, XepLoai) " +
                "VALUES (?, 1, '2025-2026', ?, ?) " +
                "ON DUPLICATE KEY UPDATE Diem=VALUES(Diem), XepLoai=VALUES(XepLoai)");
            psUp.setString(1, maSVs[i]);
            psUp.setDouble(2, tong);
            psUp.setString(3, xepLoai);
            psUp.executeUpdate();
            psUp.close();
        }
    }
    response.sendRedirect("giangvien_renluyen.jsp");
    return;
}

// ================= LẤY DỮ LIỆU SINH VIÊN =================
List<Map<String, Object>> list = new ArrayList<>();
try {
    // ✅ Chỉ lấy 1 dòng duy nhất / sinh viên cho học kỳ 1, năm học 2025-2026
    PreparedStatement ps = conn.prepareStatement(
        "SELECT sv.MaSV, sv.HoTen, " +
        "COALESCE(r.Diem, 0) AS Diem, COALESCE(r.XepLoai, 'Chưa có') AS XepLoai " +
        "FROM sinhvien sv " +
        "LEFT JOIN diemrenluyen r " +
        "ON sv.MaSV = r.MaSV AND r.HocKy = 1 AND r.NamHoc = '2025-2026' " +
        "WHERE sv.MaLop = 'DHTI15A1HN' " +
        "GROUP BY sv.MaSV, sv.HoTen, r.Diem, r.XepLoai " +
        "ORDER BY sv.MaSV");
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        Map<String, Object> row = new HashMap<>();
        row.put("MaSV", rs.getString("MaSV"));
        row.put("HoTen", rs.getString("HoTen"));
        row.put("Diem", rs.getDouble("Diem"));
        row.put("XepLoai", rs.getString("XepLoai"));
        list.add(row);
    }
    rs.close(); ps.close();
} catch (Exception e) {
    out.print("<p style='color:red;'>Lỗi tải dữ liệu SV: "+e.getMessage()+"</p>");
}
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Nhập điểm rèn luyện</title>
<link rel="stylesheet" href="../../assets/css/style-giangvien.css">
<script src="https://kit.fontawesome.com/a2e0f6b6f5.js" crossorigin="anonymous"></script>

<style>
body {
  font-family:"Segoe UI",sans-serif;
  background:#f4f6fb;
  margin:0;
  display:flex;
  min-height:100vh;
}
.main-content {
  margin-left:230px;
  padding:40px 60px;
  width:calc(100% - 230px);
  display:flex;
  flex-direction:column;
  min-height:100vh;
  box-sizing:border-box;
}
.header-info {
  display:flex;
  justify-content:space-between;
  align-items:center;
  margin-bottom:25px;
  border-bottom:2px solid #e0e6f1;
  padding-bottom:10px;
}
.header-info h2 {
  color:#003366;
  font-size:24px;
  margin:0;
}
.header-info p {
  color:#666;
  font-size:15px;
  margin:5px 0 0 0;
}
.btn {
  border:none;
  padding:10px 18px;
  border-radius:6px;
  cursor:pointer;
  font-weight:500;
  transition:0.25s;
}
.btn-save {background:#007bff;color:#fff;}
.btn-excel {background:#28a745;color:#fff;}
.btn-print {background:#17a2b8;color:#fff;}
.btn:hover {opacity:0.9;transform:translateY(-1px);}
.table-container {
  background:#fff;
  border-radius:12px;
  box-shadow:0 4px 10px rgba(0,0,0,0.1);
  overflow:hidden;
  margin-top:10px;
}
table {
  width:100%;
  border-collapse:collapse;
  border-spacing:0;
}
thead {
  background:#002b5b;
  color:white;
}
th,td {
  padding:12px 14px;
  text-align:center;
  font-size:15px;
  vertical-align:middle;
}
tbody tr:nth-child(even){background:#f3f6fc;}
tbody tr:hover{background:#e6efff;transition:0.2s;}
input[type=number] {
  width:70px;
  text-align:center;
  border:1px solid #ccc;
  border-radius:5px;
  padding:4px;
}
.status.good{color:green;font-weight:600;}
.status.avg{color:#ff6600;font-weight:600;}
@media print{
  .header-info button{display:none!important;}
  .sidebar{display:none!important;}
  .main-content{margin:0;padding:20px;}
}
</style>
</head>

<body>
<%@ include file="../../includes/sidebar-giangvien.jsp" %>

<div class="main-content">
  <div class="header-info">
    <div>
      <h2><i class="fa-solid fa-star"></i> Nhập điểm rèn luyện — Giảng viên: <%= hoTenGV %></h2>
      <p><b>Khoa:</b> <%= tenKhoa %></p>
    </div>
    <div>
      <button type="submit" form="frmRL" class="btn btn-save"><i class="fa-solid fa-floppy-disk"></i> Lưu tất cả</button>
      <button type="button" class="btn btn-excel" onclick="exportExcel()"><i class="fa-solid fa-file-excel"></i> Xuất Excel</button>
      <button type="button" class="btn btn-print" onclick="window.print()"><i class="fa-solid fa-print"></i> In danh sách</button>
    </div>
  </div>

  <form id="frmRL" method="post">
    <div class="table-container">
      <table id="bangRL">
        <thead>
          <tr>
            <th>STT</th><th>Mã SV</th><th>Họ tên</th>
            <th>Ý thức</th><th>Đoàn - Hội</th><th>Kỷ luật</th><th>Tự học</th>
            <th>Tổng</th><th>Xếp loại</th>
          </tr>
        </thead>
        <tbody>
        <%
        int stt=1;
        for(Map<String,Object> sv:list){
        %>
          <tr>
            <td><%=stt++%></td>
            <td><input type="hidden" name="masv" value="<%=sv.get("MaSV")%>"><%=sv.get("MaSV")%></td>
            <td style="text-align:left;"><%=sv.get("HoTen")%></td>
            <td><input type="number" name="muc1" min="0" max="25" step="0.5" value="0"></td>
            <td><input type="number" name="muc2" min="0" max="25" step="0.5" value="0"></td>
            <td><input type="number" name="muc3" min="0" max="25" step="0.5" value="0"></td>
            <td><input type="number" name="muc4" min="0" max="25" step="0.5" value="0"></td>
            <td class="tong"><%=sv.get("Diem")%></td>
            <td class="xeploai"><%=sv.get("XepLoai")%></td>
          </tr>
        <%
        }
        if(list.isEmpty()){
        %>
          <tr><td colspan="9" style="text-align:center;color:#999;">Chưa có sinh viên trong lớp này.</td></tr>
        <%
        }
        %>
        </tbody>
      </table>
    </div>
  </form>
</div>

<script>
// ✅ Tính tổng và xếp loại
document.querySelectorAll("#bangRL tbody tr").forEach(row=>{
  const inputs=row.querySelectorAll("input[type=number]");
  inputs.forEach(inp=>{
    inp.addEventListener("input",()=>{
      let tong=0;
      inputs.forEach(i=>tong+=parseFloat(i.value||0));
      row.querySelector(".tong").textContent=tong;
      const xl=row.querySelector(".xeploai");
      let loai="-";
      if(tong>=80) loai="Tốt";
      else if(tong>=65) loai="Khá";
      else if(tong>=50) loai="TB";
      else loai="Yếu";
      xl.textContent=loai;
      xl.className="xeploai "+(tong>=80?"status good":tong>=50?"status avg":"");
    });
  });
});

// 📊 Xuất Excel
function exportExcel(){
  const table=document.getElementById('bangRL').outerHTML;
  const link=document.createElement('a');
  link.href='data:application/vnd.ms-excel;charset=utf-8,'+
    encodeURIComponent('<meta charset="UTF-8">'+table);
  link.download='RenLuyen_<%=hoTenGV.replaceAll(" ","_")%>.xls';
  link.click();
}
</script>
</body>
</html>
