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
String hoTenGV = "", gioiTinh = "", chuyenMon = "", tenKhoa = "";

// ✅ Lấy thông tin giảng viên
try {
    PreparedStatement psInfo = conn.prepareStatement(
        "SELECT gv.HoTen, gv.GioiTinh, gv.ChuyenMon, k.TenKhoa " +
        "FROM giangvien gv JOIN khoa k ON gv.MaKhoa = k.MaKhoa WHERE gv.MaGV=?");
    psInfo.setString(1, gvID);
    ResultSet rsInfo = psInfo.executeQuery();
    if (rsInfo.next()) {
        hoTenGV = rsInfo.getString("HoTen");
        gioiTinh = rsInfo.getString("GioiTinh");
        chuyenMon = rsInfo.getString("ChuyenMon");
        tenKhoa = rsInfo.getString("TenKhoa");
    }
    rsInfo.close(); psInfo.close();
} catch (Exception e) { out.println("<p style='color:red;'>Lỗi: " + e.getMessage() + "</p>"); }

// === THỐNG KÊ DỮ LIỆU ===
int soHocPhan = 0, soSV = 0;
double tyLeNhap = 0, diemRL_TB = 0;
String labels = "", values = "";

try {
    // ✅ 1. Học phần
    PreparedStatement ps1 = conn.prepareStatement("SELECT COUNT(*) FROM hocphan WHERE MaGV=?");
    ps1.setString(1, gvID);
    ResultSet rs1 = ps1.executeQuery();
    if (rs1.next()) soHocPhan = rs1.getInt(1);
    rs1.close(); ps1.close();

    // ✅ 2. Sinh viên phụ trách
    PreparedStatement ps2 = conn.prepareStatement(
        "SELECT COUNT(DISTINCT dk.MaSV) FROM dangkyhocphan dk " +
        "JOIN hocphan hp ON dk.MaHP = hp.MaHP WHERE hp.MaGV=?");
    ps2.setString(1, gvID);
    ResultSet rs2 = ps2.executeQuery();
    if (rs2.next()) soSV = rs2.getInt(1);
    rs2.close(); ps2.close();

    // ✅ 3. Tỷ lệ điểm đã nhập
     PreparedStatement ps3 = conn.prepareStatement(
    "SELECT IFNULL(COUNT(CASE WHEN d.DiemTB IS NOT NULL THEN 1 END)*100.0/COUNT(*),0) " +
    "FROM diem d JOIN hocphan hp ON d.MaMon = hp.MaMon " +
    "WHERE hp.MaGV=?");
     ps3.setString(1, gvID);
      ResultSet rs3 = ps3.executeQuery();
      if (rs3.next()) tyLeNhap = rs3.getDouble(1);
      rs3.close(); ps3.close();

    // ✅ 4. Điểm rèn luyện TB
    PreparedStatement ps4 = conn.prepareStatement(
        "SELECT ROUND(AVG(r.Diem),2) FROM diemrenluyen r JOIN sinhvien sv ON r.MaSV = sv.MaSV");
    ResultSet rs4 = ps4.executeQuery();
    if (rs4.next()) diemRL_TB = rs4.getDouble(1);
    rs4.close(); ps4.close();

    // ✅ 5. Dữ liệu biểu đồ: TB điểm theo lớp
    PreparedStatement ps5 = conn.prepareStatement(
        "SELECT sv.MaLop, ROUND(AVG(d.DiemTB),2) AS TB " +
        "FROM diem d JOIN sinhvien sv ON d.MaSV=sv.MaSV GROUP BY sv.MaLop ORDER BY sv.MaLop");
    ResultSet rs5 = ps5.executeQuery();
    StringBuilder lb = new StringBuilder(), val = new StringBuilder();
    while (rs5.next()) {
        lb.append("'").append(rs5.getString("MaLop")).append("',");
        val.append(rs5.getDouble("TB")).append(",");
    }
    if (lb.length()>0) labels = lb.substring(0, lb.length()-1);
    if (val.length()>0) values = val.substring(0, val.length()-1);
    rs5.close(); ps5.close();
} catch (Exception e) { out.println("<p style='color:red;'>Lỗi thống kê: "+e.getMessage()+"</p>"); }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Dashboard Giảng Viên</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
body {
  font-family:"Segoe UI",sans-serif;
  background:#eef2f9;
  margin:0;
  display:flex;
  min-height:100vh;
}
.main-content{
  margin-left:230px;
  padding:50px 70px;
  width:calc(100% - 230px);
  box-sizing:border-box;
}
.header-info{
  margin-bottom:35px;
  border-bottom:2px solid #e0e6f1;
  padding-bottom:10px;
}
.header-info h2{
  font-size:28px;
  color:#002b5b;
  margin:0;
}
.header-info p{
  font-size:16px;
  color:#555;
  margin-top:8px;
}
.dashboard-wrapper{
  display:flex;
  flex-direction:column;
  gap:40px;
}
.cards{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(270px,1fr));
  gap:25px;
}
.card{
  background:white;
  border-radius:16px;
  box-shadow:0 6px 15px rgba(0,0,0,0.08);
  padding:25px 30px;
  display:flex;
  align-items:center;
  justify-content:space-between;
  transition:0.3s;
}
.card:hover{transform:translateY(-6px);box-shadow:0 10px 18px rgba(0,0,0,0.15);}
.card .icon{
  font-size:42px;
  padding:18px;
  border-radius:50%;
  color:white;
}
.card h3{margin:0;color:#002b5b;font-size:28px;}
.card p{margin-top:6px;color:#777;font-size:15px;font-weight:500;}
.card.blue .icon{background:#007bff;}
.card.green .icon{background:#28a745;}
.card.orange .icon{background:#fd7e14;}
.card.purple .icon{background:#6f42c1;}

.chart-container{
  background:white;
  border-radius:16px;
  box-shadow:0 6px 15px rgba(0,0,0,0.08);
  padding:30px 40px;
}
.chart-container h3{
  text-align:center;
  color:#002b5b;
  font-size:20px;
  margin-bottom:25px;
}
canvas{width:100%!important;max-height:400px!important;}
@media(max-width:900px){
  .main-content{padding:30px;}
  .cards{grid-template-columns:1fr 1fr;}
}
@media(max-width:600px){.cards{grid-template-columns:1fr;}}
</style>
</head>

<body>
<%@ include file="../../includes/sidebar-giangvien.jsp" %>

<div class="main-content">
  <div class="header-info">
    <h2><i class="fa-solid fa-chalkboard-user"></i> Xin chào, <%= hoTenGV %> (<%= gvID %>)</h2>
    <p><i class="fa-solid fa-circle-info"></i>
      <b>Giới tính:</b> <%= gioiTinh %> |
      <b>Chuyên môn:</b> <%= chuyenMon %> |
      <b>Khoa:</b> <%= tenKhoa %>
    </p>
  </div>

  <div class="dashboard-wrapper">
    <div class="cards">
      <div class="card blue" onclick="location.href='giangvien_hocphan.jsp'">
        <div class="icon"><i class="fa-solid fa-book-open"></i></div>
        <div><h3><%= soHocPhan %></h3><p>Học phần giảng dạy</p></div>
      </div>

      <div class="card green" onclick="location.href='giangvien_dssv.jsp'">
        <div class="icon"><i class="fa-solid fa-user-graduate"></i></div>
        <div><h3><%= soSV %></h3><p>Sinh viên phụ trách</p></div>
      </div>

      <div class="card orange" onclick="location.href='giangvien_chonmon.jsp'">
        <div class="icon"><i class="fa-solid fa-pen-to-square"></i></div>
        <div><h3><%= String.format("%.1f", tyLeNhap) %>%</h3><p>Tỷ lệ điểm đã nhập</p></div>
      </div>

      <div class="card purple" onclick="location.href='giangvien_renluyen.jsp'">
        <div class="icon"><i class="fa-solid fa-medal"></i></div>
        <div><h3><%= diemRL_TB %></h3><p>Điểm rèn luyện TB</p></div>
      </div>
    </div>

    <div class="chart-container">
      <h3><i class="fa-solid fa-chart-column"></i> Thống kê điểm trung bình các lớp</h3>
      <canvas id="chartDiem"></canvas>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
const ctx=document.getElementById('chartDiem').getContext('2d');
new Chart(ctx,{
  type:'bar',
  data:{
    labels:[<%= labels %>],
    datasets:[{
      label:'Điểm trung bình lớp',
      data:[<%= values %>],
      backgroundColor:['#007bffcc','#28a745cc','#fd7e14cc','#6f42c1cc','#17a2b8cc','#ffc107cc'],
      borderRadius:6
    }]
  },
  options:{
    responsive:true,
    scales:{y:{beginAtZero:true,max:10,grid:{color:'#eaeaea'}}},
    plugins:{legend:{display:false}}
  }
});
</script>
</body>
</html>
