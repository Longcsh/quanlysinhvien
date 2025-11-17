<%@ page import="java.sql.*, java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String JDBC_URL  = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String JDBC_USER = "root";
    String JDBC_PASS = "";

    List<Map<String,Object>> diemList = new ArrayList<>();

    // Lấy từ view v_diemsinhvien + join monhoc để có SoTinChi
    String sqlView =
        "SELECT v.MaSV, v.TenSinhVien, v.MaMon, v.TenMon, mh.SoTinChi, " +
        "       v.DiemTB, " +
        "       CASE v.DiemChu WHEN 'A' THEN 4.0 WHEN 'B' THEN 3.0 WHEN 'C' THEN 2.0 WHEN 'D' THEN 1.0 ELSE 0.0 END AS Diem4, " +
        "       v.DiemChu " +
        "FROM v_diemsinhvien v " +
        "JOIN monhoc mh ON mh.MaMon = v.MaMon " +
        "ORDER BY v.MaSV, v.MaMon";

    // Fallback: join trực tiếp, tự tính DiemChu/XepLoai/Diem4 từ DiemTB
    String sqlJoin =
        "SELECT d.MaSV, sv.HoTen AS TenSinhVien, d.MaMon, mh.TenMon, mh.SoTinChi, " +
        "       d.DiemTB, " +
        "       CASE WHEN d.DiemTB >= 8.5 THEN 4.0 " +
        "            WHEN d.DiemTB >= 7.0 THEN 3.0 " +
        "            WHEN d.DiemTB >= 5.5 THEN 2.0 " +
        "            WHEN d.DiemTB >= 4.0 THEN 1.0 ELSE 0.0 END AS Diem4, " +
        "       CASE WHEN d.DiemTB >= 8.5 THEN 'A' " +
        "            WHEN d.DiemTB >= 7.0 THEN 'B' " +
        "            WHEN d.DiemTB >= 5.5 THEN 'C' " +
        "            WHEN d.DiemTB >= 4.0 THEN 'D' ELSE 'F' END AS DiemChu " +
        "FROM diem d " +
        "JOIN sinhvien sv ON sv.MaSV = d.MaSV " +
        "JOIN monhoc mh   ON mh.MaMon = d.MaMon " +
        "ORDER BY d.MaSV, d.MaMon";

    try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {
        boolean usedView = false;
        // Thử dùng view trước
        try (PreparedStatement ps = conn.prepareStatement(sqlView);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> r = new HashMap<>();
                r.put("MaSV",        rs.getString("MaSV"));
                r.put("TenSinhVien", rs.getString("TenSinhVien"));
                r.put("MaMon",       rs.getString("MaMon"));
                r.put("TenMon",      rs.getString("TenMon"));
                r.put("SoTinChi",    rs.getObject("SoTinChi"));
                r.put("Diem10",      rs.getObject("DiemTB")); // dùng DiemTB hiển thị cột "Điểm 10"
                r.put("Diem4",       rs.getObject("Diem4"));
                r.put("DiemChu",     rs.getString("DiemChu"));
                diemList.add(r);
            }
            usedView = true;
        } catch (Exception ignore) { /* nếu view chưa tạo, dùng join bên dưới */ }

        if (!usedView) {
            try (PreparedStatement ps = conn.prepareStatement(sqlJoin);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> r = new HashMap<>();
                    r.put("MaSV",        rs.getString("MaSV"));
                    r.put("TenSinhVien", rs.getString("TenSinhVien"));
                    r.put("MaMon",       rs.getString("MaMon"));
                    r.put("TenMon",      rs.getString("TenMon"));
                    r.put("SoTinChi",    rs.getObject("SoTinChi"));
                    r.put("Diem10",      rs.getObject("DiemTB")); // dùng DiemTB hiển thị cột "Điểm 10"
                    r.put("Diem4",       rs.getObject("Diem4"));
                    r.put("DiemChu",     rs.getString("DiemChu"));
                    diemList.add(r);
                }
            }
        }
    } catch (Exception e) {
        out.print("<pre>Lỗi tải điểm: " + e.getMessage() + "</pre>");
    }

    request.setAttribute("diemList", diemList);
    String hkSel = request.getParameter("hocky"); // giữ selected cho dropdown tĩnh
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xem Điểm | MONKEY Edusoft</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/css/style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <style>
        /* ======================================================
   MONKEY Edusoft – Admin Panel CSS (Full)
   Áp dụng cho toàn bộ admin_xemdiem.jsp và các trang khác
   ====================================================== */

/* ---------- BIẾN MÀU ---------- */
:root {
  --primary:#0B63E5;
  --primary-600:#0957cc;
  --primary-700:#084cb5;
  --bg:#f5f8fd;
  --card:#ffffff;
  --text:#111827;
  --muted:#6b7280;
  --border:#e5e7eb;
  --success:#16a34a;
  --danger:#dc2626;
  --radius:14px;
  --shadow:0 8px 24px rgba(2,6,23,.06);
  --space-lg:20px;
}

/* ---------- RESET ---------- */
*{box-sizing:border-box;margin:0;padding:0}
html,body{height:100%}
body{
  font-family:'Segoe UI',Roboto,Arial,sans-serif;
  background:var(--bg);
  color:var(--text);
  display:flex;
}

/* ---------- SIDEBAR ---------- */
.sidebar{
  position:fixed;top:0;left:0;height:100vh;width:260px;
  background:var(--primary);color:#fff;
  display:flex;flex-direction:column;z-index:1000;
  box-shadow:0 0 20px rgba(11,99,229,.25);
}
.sidebar-header{
  display:flex;justify-content:space-between;align-items:center;
  padding:14px 18px;border-bottom:1px solid rgba(255,255,255,.2);
}
.sidebar-logo{
  display:flex;align-items:center;gap:10px;
  text-decoration:none;color:#fff;font-weight:600;
}
.sidebar-logo img{height:36px;width:auto}
.btn-icon{
  background:none;border:none;cursor:pointer;
  height:36px;width:36px;border-radius:10px;
  display:inline-grid;place-items:center;color:inherit;
}
.btn-icon:hover{background:rgba(255,255,255,.15)}
.btn-close-sidebar{display:none}
.sidebar-content{padding:10px;overflow-y:auto}
.nav-list{list-style:none}
.nav-section-title{
  font-size:12px;text-transform:uppercase;opacity:.8;
  padding:14px 14px 8px;
}
.nav-item{margin:2px 6px}
.nav-link{
  display:flex;align-items:center;gap:12px;
  text-decoration:none;color:#eaf1ff;padding:10px 12px;
  border-radius:10px;transition:.15s;
}
.nav-link .material-icons-outlined{font-size:20px}
.nav-link:hover{background:rgba(255,255,255,.15)}
.nav-link.active{background:#fff;color:var(--primary);font-weight:600}

/* ---------- MAIN ---------- */
.main-content{
  margin-left:260px;width:calc(100% - 260px);
  display:flex;flex-direction:column;min-height:100vh;
}
.main-header{
  display:flex;justify-content:space-between;align-items:center;
  padding:12px 18px;background:var(--card);
  border-bottom:1px solid var(--border);
  box-shadow:0 2px 8px rgba(0,0,0,.05);
  position:sticky;top:0;z-index:900;
}
.header-left{display:flex;align-items:center;gap:12px}
.page-title{font-size:20px;font-weight:600}
.btn-open-sidebar{display:none}

/* ---------- CARD ---------- */
.card{
  background:var(--card);border:1px solid var(--border);
  border-radius:var(--radius);box-shadow:var(--shadow);
  margin:18px;padding:0;
}
.card-header{
  display:flex;justify-content:space-between;align-items:center;
  padding:16px 18px;border-bottom:1px solid var(--border);
}
.section-title{font-size:18px}
.form-actions{display:flex;gap:10px}

/* ---------- BUTTONS ---------- */
.btn-primary{
  display:inline-flex;align-items:center;gap:8px;
  background:var(--primary);color:#fff;
  border:none;cursor:pointer;padding:10px 14px;
  border-radius:10px;font-weight:600;transition:.15s;
}
.btn-primary .material-icons-outlined{font-size:19px}
.btn-primary:hover{background:var(--primary-600)}
.btn-primary:active{transform:translateY(1px)}

.btn-primary-outline{
  display:inline-flex;align-items:center;gap:8px;
  background:#fff;color:var(--primary);
  border:1px solid var(--primary);cursor:pointer;
  padding:8px 14px;border-radius:10px;font-weight:600;
  transition:.15s;
}
.btn-primary-outline:hover{background:var(--primary);color:#fff}

/* ---------- INPUT / FORM ---------- */
.form-input{
  padding:8px 12px;border:1px solid var(--border);
  border-radius:10px;background:#fff;
  font:inherit;margin-right:10px;outline:none;
  transition:.15s;width:auto;
}
.form-input:focus{
  border-color:var(--primary);
  box-shadow:0 0 0 3px rgba(11,99,229,.15);
}
.search-form{
  display:flex;flex-wrap:wrap;gap:12px;
  padding:var(--space-lg);
}

/* ---------- TABLE ---------- */
.table-responsive{width:100%;overflow:auto}
.course-table{
  width:100%;border-collapse:separate;border-spacing:0;
  min-width:760px;
}
.course-table th{
  background:#f8fafc;padding:12px 14px;text-align:left;
  font-size:14px;border-bottom:1px solid var(--border);
}
.course-table td{
  padding:10px 14px;border-bottom:1px solid var(--border);
}
.course-table tbody tr:hover{background:#f9fbff}
.course-table td form{display:inline-block;margin:0 3px}
.course-table .btn-icon{
  border:1px solid var(--border);background:#fff;color:#222;
}
.course-table .btn-icon:hover{background:#f1f5f9}
form[onsubmit] .btn-icon{
  color:var(--danger);border-color:#fca5a5;background:#fee2e2;
}
form[onsubmit] .btn-icon:hover{background:#fecaca}

/* ---------- BẢNG ĐIỂM (xem điểm) ---------- */
.course-table th:nth-child(1){width:110px;}
.course-table th:nth-child(2){width:180px;}
.course-table th:nth-child(3){width:90px;text-align:center;}
.course-table th:nth-child(4){width:auto;}
.course-table th:nth-child(5){width:90px;text-align:center;}
.course-table th:nth-child(6),
.course-table th:nth-child(7),
.course-table th:nth-child(8){width:90px;text-align:center;}
.course-table td:nth-child(5),
.course-table td:nth-child(6),
.course-table td:nth-child(7),
.course-table td:nth-child(8){text-align:center;}

/* ---------- HUY HIỆU ĐIỂM (badge) ---------- */
.grade-badge{
  display:inline-block;
  min-width:36px;
  padding:4px 8px;
  border-radius:999px;
  font-weight:600;
  color:#fff;
  font-size:13px;
}
.grade-a{background:#16a34a;}   /* xanh lá */
.grade-b{background:#0B63E5;}   /* xanh dương */
.grade-c{background:#f59e0b;}   /* vàng */
.grade-d{background:#ea580c;}   /* cam */
.grade-f{background:#dc2626;}   /* đỏ */

/* ---------- UTILS ---------- */
.text-success{color:var(--success)!important}
.text-danger{color:var(--danger)!important}
.text-warning{color:var(--warning)!important}
a{color:var(--primary);text-decoration:none}
a:hover{text-decoration:underline}
.material-icons-outlined{vertical-align:middle;line-height:1}

/* ---------- SIDEBAR OVERLAY + RESPONSIVE ---------- */
.sidebar-overlay{
  position:fixed;inset:0;background:rgba(0,0,0,.4);
  opacity:0;visibility:hidden;transition:.2s;z-index:800;
}
.sidebar.is-open + .main-content ~ .sidebar-overlay,
.sidebar-overlay.is-open{opacity:1;visibility:visible}
@media(max-width:860px){
  .sidebar{transform:translateX(-100%);transition:.2s;}
  .sidebar.is-open{transform:none}
  .btn-open-sidebar,.btn-close-sidebar{display:inline-grid}
  .main-content{margin-left:0;width:100%}
}

/* ---------- SCROLLBAR ---------- */
::-webkit-scrollbar{width:8px;height:8px}
::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:10px}
::-webkit-scrollbar-thumb:hover{background:#94a3b8}

/* ---------- HOVER CHO HÀNG BẢNG ---------- */
.course-table tbody tr:hover td{background:#f8fbff}

/* ---------- PAGE WRAPPER ---------- */
.page-content-wrapper{padding:10px 20px 40px}

/* ---------- EXPORT BUTTON (nút Xuất Excel) ---------- */
.btn-primary-outline .material-icons-outlined{font-size:18px}

    </style>
</head>
<body>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
             <a href="admin_dashboard.jsp" class="sidebar-logo">
               
            </a>
            <button class="btn-icon btn-close-sidebar" aria-label="Đóng menu" id="close-sidebar"><span class="material-icons-outlined">close</span></button>
        </div>
        <div class="sidebar-content">
             <ul class="nav-list" role="menu">
                <li class="nav-item" role="menuitem"><a href="admin_dashboard.jsp" class="nav-link"><span class="material-icons-outlined">admin_panel_settings</span><span>Trang chủ Admin</span></a></li>
                <li class="nav-section-title">Quản lý</li>
                <li class="nav-item" role="menuitem"><a href="admin_qlsv.jsp" class="nav-link"><span class="material-icons-outlined">school</span><span>Quản lý Sinh viên</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qlgv.jsp" class="nav-link"><span class="material-icons-outlined">account_box</span><span>Quản lý Giảng viên</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qlmh.jsp" class="nav-link"><span class="material-icons-outlined">book</span><span>Quản lý Môn học</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_qllop.jsp" class="nav-link"><span class="material-icons-outlined">corporate_fare</span><span>Quản lý Khoa/Lớp</span></a></li>
                <li class="nav-section-title">Nghiệp vụ</li>
                <li class="nav-item" role="menuitem"><a href="admin_xemdiem.jsp" class="nav-link active"><span class="material-icons-outlined">grade</span><span>Quản Lý Điểm</span></a></li>
                            <li class="nav-item"><a href="duyetdangky.jsp" class="nav-link active"><span class="material-icons-outlined">how_to_reg</span>Duyệt đăng ký tín </a></li>
                <li class="nav-item" role="menuitem"><a href="admin_bctk.jsp" class="nav-link"><span class="material-icons-outlined">assessment</span><span>Báo cáo Thống kê</span></a></li>
            </ul>
        </div>
    </nav>

    <main class="main-content">
        <header class="main-header">
            <div class="header-left">
                <button class="btn-icon btn-open-sidebar" aria-label="Mở menu" id="open-sidebar"><span class="material-icons-outlined">menu</span></button>
                <h1 class="page-title">Quản Lý Điểm Sinh viên</h1>
            </div>
            <div class="header-right">
                </div>
        </header>

        <div class="page-content-wrapper">
            <section class="card">
                 <div class="card-header">
                    <h2 class="section-title">Bộ lọc</h2>
                 </div>

                 <!-- Giữ nguyên layout; dropdown HK tĩnh, chỉ set selected theo tham số GET nếu có -->
                 <form class="search-form" style="padding: 0 var(--space-lg) var(--space-lg);" method="get">
                    <input type="text"
                           name="qsv"
                           value="<%= request.getParameter("qsv")!=null?request.getParameter("qsv"):"" %>"
                           placeholder="Mã SV hoặc Tên SV..."
                           class="form-input">

                    <input type="text"
                           name="qmon"
                           value="<%= request.getParameter("qmon")!=null?request.getParameter("qmon"):"" %>"
                           placeholder="Mã Môn học..."
                           class="form-input">

                    <select class="form-input" name="hocky">
                        <option value="">-- Chọn học kỳ (Tùy chọn) --</option>
                        <option value="1" <%= "1".equals(hkSel) ? "selected" : "" %>>Học kỳ 1</option>
                        <option value="2" <%= "2".equals(hkSel) ? "selected" : "" %>>Học kỳ 2</option>
                        <option value="3" <%= "3".equals(hkSel) ? "selected" : "" %>>Học kỳ Hè</option>
                    </select>

                    <button type="submit" class="btn-primary">
                        <span class="material-icons-outlined">filter_alt</span>Lọc
                    </button>
                 </form>
            </section>

             <section class="card">
                <div class="card-header">
                    <h2 class="section-title">Kết quả điểm</h2>
                    <button class="btn-primary-outline"><span class="material-icons-outlined">download</span>Xuất Excel</button>
                </div>
                <div class="table-responsive">
                    <table class="course-table">
                         <thead>
                            <tr>
                                <th>Mã SV</th> <th>Họ tên</th> <th>Mã HP</th> <th>Tên HP</th> <th>Số TC</th> <th>Điểm 10</th> <th>Điểm 4</th> <th>Điểm Chữ</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            List<Map<String,Object>> list = (List<Map<String,Object>>) request.getAttribute("diemList");
                            if (list == null || list.isEmpty()) {
                        %>
                            <tr><td colspan="8">Không có dữ liệu.</td></tr>
                        <%
                            } else {
                                for (Map<String,Object> r : list) {
                                    String  maSV   = String.valueOf(r.get("MaSV"));
                                    String  tenSV  = String.valueOf(r.get("TenSinhVien"));
                                    String  maMon  = String.valueOf(r.get("MaMon"));
                                    String  tenMon = String.valueOf(r.get("TenMon"));
                                    Object  stc    = r.get("SoTinChi");
                                    Object  d10    = r.get("Diem10");   // chính là DiemTB
                                    Object  d4     = r.get("Diem4");
                                    String  chu    = String.valueOf(r.get("DiemChu"));

                                    String badge = "grade-b";
                                    if ("A".equalsIgnoreCase(chu)) badge = "grade-a";
                                    else if ("B".equalsIgnoreCase(chu)) badge = "grade-b";
                                    else if ("C".equalsIgnoreCase(chu)) badge = "grade-c";
                                    else if ("D".equalsIgnoreCase(chu)) badge = "grade-d";
                                    else if (chu == null || chu.isEmpty()) badge = "grade-b";
                                    else badge = "grade-f";
                        %>
                            <tr>
                                <td><%= maSV %></td>
                                <td><%= tenSV %></td>
                                <td><%= maMon %></td>
                                <td><%= tenMon %></td>
                                <td><%= stc==null?"":stc %></td>
                                <td><span class="grade-badge <%=badge%>"><%= d10==null?"":d10 %></span></td>
                                <td><span class="grade-badge <%=badge%>"><%= d4==null?"":d4 %></span></td>
                                <td><%= chu==null?"":chu %></td>
                            </tr>
                        <%
                                }
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>

    <div class="sidebar-overlay" id="sidebar-overlay"></div>
    <script src="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/js/main.js"></script>
</body>
</html>
