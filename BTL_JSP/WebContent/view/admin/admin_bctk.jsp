<%@ page import="java.sql.*, java.util.*" %>
<%! 
    // Escape HTML an toàn, không cần thư viện ngoài
    private static String esc(String s){
        if (s == null) return "";
        return s.replace("&","&amp;")
                .replace("<","&lt;")
                .replace(">","&gt;")
                .replace("\"","&quot;")
                .replace("'","&#39;");
    }
%>
<%
    /* ========================= BACKEND ========================= */
    // Cấu hình DB (đổi nếu khác)
    String JDBC_URL  = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String JDBC_USER = "root";
    String JDBC_PASS = "";

    // Nhận tham số từ form
    String type  = request.getParameter("type");   // có thể là value mới hoặc text cũ
    String hkStr = request.getParameter("hocky");  // "","1","2","3"
    Integer hk   = null;
    try { if (hkStr != null && !hkStr.isBlank()) hk = Integer.parseInt(hkStr.trim()); } catch(Exception ig){}
    // Giới hạn hợp lệ 1..3 nếu muốn
    if (hk != null && (hk < 1 || hk > 3)) hk = null;

    // Chuẩn hoá type -> typeKey (hỗ trợ cả value mới và text cũ)
    String typeKey = null;
    if (type != null) {
        switch (type) {
            case "diem_tb_lop":
            case "sv_theo_khoa":
            case "mon_dangky_nhieu":
                typeKey = type; break;
            case "Thống kê điểm trung bình theo lớp":
                typeKey = "diem_tb_lop"; break;
            case "Thống kê số lượng sinh viên theo khoa":
                typeKey = "sv_theo_khoa"; break;
            case "Thống kê môn học được đăng ký nhiều nhất":
                typeKey = "mon_dangky_nhieu"; break;
            default:
                typeKey = null; // chưa chọn hoặc không khớp
        }
    }

    StringBuilder rows = new StringBuilder();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection cn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {

            if ("diem_tb_lop".equals(typeKey)) {
                // BCTK #1: Điểm TB hệ 4 + SV đậu/trượt theo LỚP (lọc theo học kỳ nếu chọn)
                // MariaDB 10.4+ hỗ trợ CTE
                String sql =
                  "WITH sv_avg AS ( " +
                  "  SELECT d.MaSV, sv.MaLop, AVG(d.DiemTB) AS avg10 " +
                  "  FROM diem d JOIN sinhvien sv ON sv.MaSV = d.MaSV " +
                  (hk==null ? "" : " WHERE d.HocKy=? ") +
                  "  GROUP BY d.MaSV, sv.MaLop ) " +
                  "SELECT sa.MaLop, ROUND(AVG(sa.avg10)/10*4,2) AS he4, " +
                  "       SUM(CASE WHEN sa.avg10>=5.0 THEN 1 ELSE 0 END) AS dat, " +
                  "       SUM(CASE WHEN sa.avg10< 5.0 THEN 1 ELSE 0 END) AS truot " +
                  "FROM sv_avg sa GROUP BY sa.MaLop ORDER BY sa.MaLop";
                try (PreparedStatement ps = cn.prepareStatement(sql)) {
                    if (hk!=null) ps.setInt(1, hk);
                    try (ResultSet rs = ps.executeQuery()) {
                        boolean any=false;
                        while (rs.next()){
                            any=true;
                            rows.append("<tr>")
                                .append("<td>").append(esc(rs.getString("MaLop"))).append("</td>")
                                .append("<td>").append(String.format(java.util.Locale.US,"%.2f", rs.getDouble("he4"))).append("</td>")
                                .append("<td>").append(rs.getInt("dat")).append("</td>")
                                .append("<td>").append(rs.getInt("truot")).append("</td>")
                                .append("</tr>");
                        }
                        if(!any) rows.append("<tr><td colspan='4' style='text-align:center'>Không có dữ liệu.</td></tr>");
                    }
                }

            } else if ("sv_theo_khoa".equals(typeKey)) {
                // BCTK #2: Số SV theo KHOA (không phụ thuộc học kỳ)
                String sql =
                  "SELECT k.TenKhoa, COUNT(sv.MaSV) AS so_sv " +
                  "FROM khoa k " +
                  "LEFT JOIN lop l  ON l.MaKhoa = k.MaKhoa " +
                  "LEFT JOIN sinhvien sv ON sv.MaLop = l.MaLop " +
                  "GROUP BY k.TenKhoa ORDER BY k.TenKhoa";
                try (PreparedStatement ps = cn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
                    boolean any=false;
                    while (rs.next()){
                        any=true;
                        rows.append("<tr>")
                            .append("<td>").append(esc(rs.getString("TenKhoa"))).append("</td>")
                            .append("<td>—</td>")
                            .append("<td>").append(rs.getInt("so_sv")).append("</td>")
                            .append("<td>—</td>")
                            .append("</tr>");
                    }
                    if(!any) rows.append("<tr><td colspan='4' style='text-align:center'>Không có dữ liệu.</td></tr>");
                }

            } else if ("mon_dangky_nhieu".equals(typeKey)) {
                // BCTK #3: Môn học đăng ký nhiều nhất (lọc theo học kỳ nếu chọn)
                String sql =
                  "SELECT m.TenMon, COUNT(dkhp.MaDK) AS luot_dk " +
                  "FROM dangkyhocphan dkhp " +
                  "JOIN hocphan hp ON hp.MaHP = dkhp.MaHP " +
                  "JOIN monhoc m  ON m.MaMon = hp.MaMon " +
                  (hk==null ? "" : "WHERE hp.HocKy=? ") +
                  "GROUP BY m.TenMon " +
                  "ORDER BY luot_dk DESC, m.TenMon ASC " +
                  "LIMIT 20";
                try (PreparedStatement ps = cn.prepareStatement(sql)) {
                    if (hk!=null) ps.setInt(1, hk);
                    try (ResultSet rs = ps.executeQuery()) {
                        boolean any=false;
                        while (rs.next()){
                            any=true;
                            rows.append("<tr>")
                                .append("<td>").append(esc(rs.getString("TenMon"))).append("</td>")
                                .append("<td>—</td>")
                                .append("<td>").append(rs.getInt("luot_dk")).append("</td>")
                                .append("<td>—</td>")
                                .append("</tr>");
                        }
                        if(!any) rows.append("<tr><td colspan='4' style='text-align:center'>Không có dữ liệu.</td></tr>");
                    }
                }

            } else {
                // Chưa chọn loại báo cáo
                rows.append("<tr><td colspan='4' style='text-align:center'>Hãy chọn loại báo cáo.</td></tr>");
            }
        }
    } catch (Exception ex) {
        rows.setLength(0);
        rows.append("<tr><td colspan='4' style='color:#c62828'>Lỗi tải dữ liệu: ")
            .append(esc(ex.getMessage()))
            .append("</td></tr>");
    }
    request.setAttribute("BCTK_ROWS", rows.toString());
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo Thống kê | MONKEY Edusoft</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/css/style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <style>
        /* ======================================================
   MONKEY Edusoft – Admin Panel CSS (Full)
   File: /BTL_JSP/WebContent/assets/css/style.css
   ====================================================== */

/* ---------- VARIABLES ---------- */
:root{
  --primary:#0B63E5;
  --primary-600:#0957cc;
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

/* ---------- PAGE WRAPPER ---------- */
.page-content-wrapper{padding:10px 20px 40px}

/* ---------- CARDS ---------- */
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
  padding:8px 14px;border-radius:10px;font-weight:600;transition:.15s;
}
.btn-primary-outline:hover{background:var(--primary);color:#fff}

/* ---------- FORM / FILTER ---------- */
.search-form{
  display:flex;flex-wrap:wrap;gap:12px;
  padding:var(--space-lg);
}
.form-input{
  padding:8px 12px;border:1px solid var(--border);
  border-radius:10px;background:#fff;
  font:inherit;outline:none;transition:.15s;
}
.form-input:focus{
  border-color:var(--primary);
  box-shadow:0 0 0 3px rgba(11,99,229,.15);
}

/* ---------- TABLE (CHUNG) ---------- */
.table-responsive{width:100%;overflow:auto}
.course-table{
  width:100%;border-collapse:separate;border-spacing:0;
  min-width:640px;
}
.course-table thead th{
  background:#f8fafc;padding:12px 14px;text-align:left;
  font-size:14px;border-bottom:1px solid var(--border);
}
.course-table tbody td{
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

/* ---------- TABLE – XEM ĐIỂM (8 cột) ---------- */
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

/* ---------- TABLE – BÁO CÁO THỐNG KÊ (4 cột) ---------- */
.report-table{min-width:520px;}
.report-table thead th:nth-child(1){width:200px;}   /* Lớp/TênKhoa/TênMôn */
.report-table thead th:nth-child(2){width:160px;text-align:center;}
.report-table thead th:nth-child(3){width:140px;text-align:center;}
.report-table thead th:nth-child(4){width:140px;text-align:center;}
.report-table tbody td:nth-child(2),
.report-table tbody td:nth-child(3),
.report-table tbody td:nth-child(4){text-align:center;}

/* ---------- BADGES (điểm/hạn mức) ---------- */
.badge{
  display:inline-block;min-width:36px;padding:4px 8px;
  border-radius:999px;font-weight:600;font-size:13px;color:#fff;
}
.badge-green{background:#16a34a}
.badge-blue{background:#0B63E5}
.badge-amber{background:#f59e0b}
.badge-orange{background:#ea580c}
.badge-red{background:#dc2626}

/* Dùng cho trang Xem điểm (nếu muốn) */
.grade-badge{display:inline-block;min-width:36px;padding:4px 8px;border-radius:999px;font-weight:600;font-size:13px;color:#fff}
.grade-a{background:#16a34a}
.grade-b{background:#0B63E5}
.grade-c{background:#f59e0b}
.grade-d{background:#ea580c}
.grade-f{background:#dc2626}

/* ---------- UTILS ---------- */
.text-muted{color:var(--muted)}
.text-success{color:var(--success)!important}
.text-danger{color:var(--danger)!important}
a{color:var(--primary);text-decoration:none}
a:hover{text-decoration:underline}
.material-icons-outlined{vertical-align:middle;line-height:1}

/* ---------- OVERLAY + RESPONSIVE ---------- */
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

/* ---------- ROW HOVER EMPHASIS ---------- */
.course-table tbody tr:hover td{background:#f8fbff}

    </style>
</head>
<body>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
             <a href="admin_dashboard.jsp" class="sidebar-logo">
                <img src="${pageContext.request.contextPath}/BTL_JSP/WebContent/assets/images/logo.png" alt=" Logo">
                <span>MONKEY (Admin)</span>
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
                <li class="nav-item" role="menuitem"><a href="admin_xemdiem.jsp" class="nav-link"><span class="material-icons-outlined">grade</span><span>Quản Lý Điểm</span></a></li>
                <li class="nav-item" role="menuitem"><a href="admin_bctk.jsp" class="nav-link active"><span class="material-icons-outlined">assessment</span><span>Báo cáo Thống kê</span></a></li>
            </ul>
        </div>
    </nav>

    <main class="main-content">
        <header class="main-header">
            <div class="header-left">
                <button class="btn-icon btn-open-sidebar" aria-label="Mở menu" id="open-sidebar"><span class="material-icons-outlined">menu</span></button>
                <h1 class="page-title">Báo cáo Thống kê</h1>
            </div>
            <div class="header-right">
            </div>
        </header>

        <div class="page-content-wrapper">
             <section class="card">
                 <div class="card-header">
                    <h2 class="section-title">Tạo báo cáo</h2>
                 </div>
                 <!-- GIỮ NGUYÊN FORM, CHỈ THÊM method/name ĐỂ BACKEND NHẬN GIÁ TRỊ -->
            <form class="search-form" style="padding: 0 var(--space-lg) var(--space-lg);" method="get">
                <!-- Chọn loại báo cáo -->
                <select class="form-input" name="type" required>
                    <option value="">-- Chọn loại báo cáo --</option>
                    <option value="diem_tb_lop">Thống kê điểm trung bình theo lớp</option>
                    <option value="sv_theo_khoa">Thống kê số lượng sinh viên theo khoa</option>
                    <option value="mon_dangky_nhieu">Thống kê môn học được đăng ký nhiều nhất</option>
                </select>

                <!-- Chọn học kỳ -->
                <select class="form-input" name="hocky">
                    <option value="">-- Chọn học kỳ (Tùy chọn) --</option>
                    <option value="1">Học kỳ 1</option>
                    <option value="2">Học kỳ 2</option>
                    <option value="3">Học kỳ Hè</option>
                </select>

                <button type="submit" class="btn-primary">
                    <span class="material-icons-outlined">summarize</span>Xuất báo cáo
                </button>
            </form>

            </section>

             <section class="card">
                <div class="card-header">
                    <h2 class="section-title">Kết quả báo cáo (Ví dụ)</h2>
                </div>
                <div class="table-responsive">
                <table class="course-table report-table">
                    <thead>
                      <tr><th>Lớp</th><th>Điểm TB (Hệ 4)</th><th>Số SV Đạt</th><th>Số SV Trượt</th></tr>
                    </thead>
                    <tbody>
                      <% String _rows = (String) request.getAttribute("BCTK_ROWS"); %>
                      <%= (_rows == null || _rows.isEmpty())
                              ? "<tr><td colspan='4' style='text-align:center'>Hãy chọn loại báo cáo và bấm Xuất báo cáo.</td></tr>"
                              : _rows %>
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
