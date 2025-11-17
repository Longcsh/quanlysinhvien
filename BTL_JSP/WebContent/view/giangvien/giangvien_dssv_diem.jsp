<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");

// ================== XỬ LÝ LƯU DỮ LIỆU ==================
if ("POST".equalsIgnoreCase(request.getMethod())) {
    response.setContentType("application/json;charset=UTF-8");
    try {
        String[] ids = request.getParameterValues("id");
        String[] ccs = request.getParameterValues("cc");
        String[] gks = request.getParameterValues("gk");
        String[] cks = request.getParameterValues("ck");

        if (ids == null || ids.length == 0) {
            out.print("{\"status\":\"error\",\"msg\":\"Không có dữ liệu để lưu!\"}");
            return;
        }

        int count = 0;
        for (int i = 0; i < ids.length; i++) {
            int id = Integer.parseInt(ids[i]);
            double cc = (ccs[i] == null || ccs[i].isEmpty()) ? 0 : Double.parseDouble(ccs[i]);
            double gk = (gks[i] == null || gks[i].isEmpty()) ? 0 : Double.parseDouble(gks[i]);
            double ck = (cks[i] == null || cks[i].isEmpty()) ? 0 : Double.parseDouble(cks[i]);
            double tb = Math.round(((cc * 0.1) + (gk * 0.3) + (ck * 0.6)) * 100.0) / 100.0;

            String chu;
            if (tb >= 8.5) chu = "A";
            else if (tb >= 8.0) chu = "B+";
            else if (tb >= 7.0) chu = "B";
            else if (tb >= 6.5) chu = "C+";
            else if (tb >= 5.5) chu = "C";
            else if (tb >= 5.0) chu = "D+";
            else if (tb >= 4.0) chu = "D";
            else chu = "F";

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE diem SET DiemCC=?, DiemGK=?, DiemCK=?, DiemTB=?, DiemChu=? WHERE Id=?");
            ps.setDouble(1, cc);
            ps.setDouble(2, gk);
            ps.setDouble(3, ck);
            ps.setDouble(4, tb);
            ps.setString(5, chu);
            ps.setInt(6, id);
            count += ps.executeUpdate();
            ps.close();
        }

        out.print("{\"status\":\"success\",\"msg\":\"Đã lưu thành công " + count + " dòng dữ liệu!\"}");
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"status\":\"error\",\"msg\":\"Lỗi: " + e.getMessage().replace("\"","'") + "\"}");
    }
    return;
}

// ================== LẤY DỮ LIỆU HIỂN THỊ ==================
String maMon = request.getParameter("mamon");
if (maMon == null || maMon.equals("null")) { response.sendRedirect("giangvien_chonmon.jsp"); return; }

String tenMon = "";
PreparedStatement psMon = conn.prepareStatement("SELECT TenMon FROM monhoc WHERE MaMon=?");
psMon.setString(1, maMon);
ResultSet rsMon = psMon.executeQuery();
if (rsMon.next()) tenMon = rsMon.getString("TenMon");
rsMon.close(); psMon.close();

List<Map<String,String>> list = new ArrayList<>();
PreparedStatement ps = conn.prepareStatement(
 "SELECT d.Id, d.MaSV, sv.HoTen, d.DiemCC, d.DiemGK, d.DiemCK, d.DiemTB, d.DiemChu " +
 "FROM diem d JOIN sinhvien sv ON d.MaSV=sv.MaSV WHERE d.MaMon=?");
ps.setString(1, maMon);
ResultSet rs = ps.executeQuery();
while (rs.next()) {
    Map<String,String> r = new HashMap<>();
    r.put("Id", rs.getString("Id"));
    r.put("MaSV", rs.getString("MaSV"));
    r.put("HoTen", rs.getString("HoTen"));
    r.put("DiemCC", rs.getString("DiemCC"));
    r.put("DiemGK", rs.getString("DiemGK"));
    r.put("DiemCK", rs.getString("DiemCK"));
    r.put("DiemTB", rs.getString("DiemTB"));
    r.put("DiemChu", rs.getString("DiemChu"));
    list.add(r);
}
rs.close(); ps.close();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Quản lý điểm – <%=tenMon%></title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
body{font-family:"Segoe UI";background:#f4f6fb;display:flex;margin:0;}
.main{margin-left:230px;padding:40px;width:calc(100% - 230px);}
h2{color:#003366;margin-bottom:10px;display:flex;align-items:center;gap:10px;}
.btn{border:none;border-radius:6px;padding:7px 12px;cursor:pointer;color:white;font-size:14px;transition:.2s;}
.btn:hover{opacity:0.9;transform:translateY(-1px);}
.btn-back{background:#6c757d;}
.btn-excel{background:#28a745;}
.btn-print{background:#17a2b8;}
.btn-save-all{background:#007bff;}
.btn-save-all.loading{background:#0056b3;opacity:0.8;pointer-events:none;}
.table-container{background:white;border-radius:12px;box-shadow:0 4px 10px rgba(0,0,0,0.1);padding:20px;}
table{width:100%;border-collapse:collapse;margin-top:10px;}
th,td{padding:10px 12px;border-bottom:1px solid #eee;text-align:center;}
th{background:#002b5b;color:white;}
tbody tr:nth-child(even){background:#f5f7fc;}
input[type=number]{width:70px;text-align:center;border:1px solid #ccc;border-radius:5px;padding:4px;}
.notice{display:none;margin-bottom:10px;padding:8px 12px;border-radius:6px;}
.notice.success{background:#d4edda;color:#155724;}
.notice.error{background:#f8d7da;color:#721c24;}
.chu.A{color:#008000;font-weight:600;}
.chu.B,.chu.Bplus{color:#0066cc;font-weight:600;}
.chu.C,.chu.Cplus{color:#ff6600;font-weight:600;}
.chu.D,.chu.Dplus{color:#ffcc00;font-weight:600;}
.chu.F{color:#cc0000;font-weight:600;}
.search-box{margin-bottom:15px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px;}
.search-box input{padding:8px 10px;width:260px;border-radius:6px;border:1px solid #ccc;}
.btn-bar{display:flex;gap:8px;}
</style>
</head>
<body>
<%@ include file="../../includes/sidebar-giangvien.jsp" %>
<div class="main">

<!-- 🔙 Nút quay lại -->
<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;">
  <button class="btn btn-back" onclick="window.location.href='giangvien_chonmon.jsp'">
    <i class="fa-solid fa-arrow-left"></i> Quay lại
  </button>
</div>

<h2><i class="fa-solid fa-list-check"></i> Nhập & Quản lý điểm – <%=tenMon%></h2>
<div class="notice" id="notice"></div>

<div class="search-box">
<input type="text" id="search" placeholder="🔍 Tìm theo tên hoặc mã sinh viên...">
<div class="btn-bar">
<button class="btn btn-save-all" id="saveAll"><i class="fa-solid fa-floppy-disk"></i> Lưu tất cả</button>
<button class="btn btn-excel" onclick="exportExcel()">📊 Xuất Excel</button>
<button class="btn btn-print" onclick="window.print()">🖨️ In danh sách</button>
</div>
</div>

<div class="table-container">
<table id="bangDiem">
<thead>
<tr>
<th>STT</th><th>Mã SV</th><th>Họ tên</th>
<th>CC (10%)</th><th>GK (30%)</th><th>CK (60%)</th>
<th>TB</th><th>Chữ</th>
</tr>
</thead>
<tbody>
<%
if (list.size() == 0) {
%><tr><td colspan="9" style="text-align:center;color:#999;">Chưa có dữ liệu điểm cho môn học này.</td></tr><%
} else {
int i = 1;
for (Map<String,String> sv : list) {
%>
<tr data-id="<%=sv.get("Id")%>">
<td><%=i++%></td>
<td><%=sv.get("MaSV")%></td>
<td style="text-align:left"><%=sv.get("HoTen")%></td>
<td><input type="number" class="cc" step="0.1" min="0" max="10" value="<%=sv.get("DiemCC")==null?"":sv.get("DiemCC")%>"></td>
<td><input type="number" class="gk" step="0.1" min="0" max="10" value="<%=sv.get("DiemGK")==null?"":sv.get("DiemGK")%>"></td>
<td><input type="number" class="ck" step="0.1" min="0" max="10" value="<%=sv.get("DiemCK")==null?"":sv.get("DiemCK")%>"></td>
<td class="tb"><%=sv.get("DiemTB")!=null?sv.get("DiemTB"):"-"%></td>
<td class="chu <%=sv.get("DiemChu")!=null?sv.get("DiemChu"):""%>"><%=sv.get("DiemChu")!=null?sv.get("DiemChu"):"-"%></td>
</tr>
<% } } %>
</tbody>
</table>
</div>
</div>

<script>
function tinhChu(tb){
  if(tb>=8.5) return "A";
  if(tb>=8.0) return "B+";
  if(tb>=7.0) return "B";
  if(tb>=6.5) return "C+";
  if(tb>=5.5) return "C";
  if(tb>=5.0) return "D+";
  if(tb>=4.0) return "D";
  return "F";
}

// 🎯 Tự tính TB và chữ
document.querySelectorAll("#bangDiem tbody tr").forEach(row=>{
  row.querySelectorAll("input").forEach(inp=>{
    inp.addEventListener("input",()=>{
      const cc=parseFloat(row.querySelector(".cc").value||0);
      const gk=parseFloat(row.querySelector(".gk").value||0);
      const ck=parseFloat(row.querySelector(".ck").value||0);
      const tb=Math.round((cc*0.1+gk*0.3+ck*0.6)*100)/100;
      const chu=tinhChu(tb);
      const cellChu=row.querySelector(".chu");
      row.querySelector(".tb").textContent=isNaN(tb)?"-":tb;
      cellChu.textContent=chu;
      cellChu.className="chu "+chu.replace("+","plus");
    });
  });
});

// 💾 Lưu tất cả
document.getElementById("saveAll").addEventListener("click", async ()=>{
  const btn=document.getElementById("saveAll");
  btn.classList.add("loading");
  btn.innerHTML='<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';

  const rows=document.querySelectorAll("#bangDiem tbody tr[data-id]");
  const params=new URLSearchParams();
  rows.forEach(r=>{
    params.append("id",r.dataset.id);
    params.append("cc",r.querySelector(".cc").value||0);
    params.append("gk",r.querySelector(".gk").value||0);
    params.append("ck",r.querySelector(".ck").value||0);
  });

  try{
    const res=await fetch(window.location.href,{
      method:"POST",
      headers:{"Content-Type":"application/x-www-form-urlencoded"},
      body:params.toString()
    });
    const data=await res.json();
    const notice=document.getElementById("notice");
    btn.classList.remove("loading");
    btn.innerHTML='<i class="fa-solid fa-floppy-disk"></i> Lưu tất cả';
    if(data.status==="success"){notice.className="notice success";notice.textContent="✔ "+data.msg;}
    else{notice.className="notice error";notice.textContent="❌ "+data.msg;}
    notice.style.display="block";setTimeout(()=>notice.style.display="none",3000);
  }catch(e){
    alert("❌ Lỗi khi gửi dữ liệu: "+e);
    btn.classList.remove("loading");
    btn.innerHTML='<i class="fa-solid fa-floppy-disk"></i> Lưu tất cả';
  }
});
</script>
</body>
</html>
