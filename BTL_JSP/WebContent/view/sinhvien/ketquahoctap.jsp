<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../../db/connect.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    // ✅ Kiểm tra đăng nhập
    String maSV = (String) session.getAttribute("maSV");
    if (maSV == null || maSV.trim().isEmpty()) {
        maSV = (String) session.getAttribute("maThamChieu");
    }

    if (maSV == null || maSV.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/dangnhap.jsp");
        return;
    }

    // ✅ Lấy học kỳ & năm học từ request (nếu null thì để rỗng)
    String hocKy = request.getParameter("hocky") == null ? "" : request.getParameter("hocky");
    String namHoc = request.getParameter("namhoc") == null ? "" : request.getParameter("namhoc");

    // ✅ Xử lý nếu người dùng bấm “Xuất Excel”
    String action = request.getParameter("action");
    if ("exportExcel".equals(action)) {
        response.setContentType("application/vnd.ms-excel");
        response.setHeader("Content-Disposition", "attachment; filename=KetQuaHocTap_HK" + hocKy + "_" + namHoc + ".xls");

        String sqlExport = "SELECT mh.MaMon, mh.TenMon, mh.SoTinChi, d.DiemCC, d.DiemGK, d.DiemCK, d.DiemTB, d.NamHoc, d.HocKy "
                         + "FROM diem d JOIN monhoc mh ON d.MaMon = mh.MaMon WHERE d.MaSV = ?";
        if (!namHoc.isEmpty()) sqlExport += " AND d.NamHoc = ?";
        if (!hocKy.isEmpty()) sqlExport += " AND d.HocKy = ?";
        sqlExport += " ORDER BY mh.MaMon";

        PreparedStatement psE = conn.prepareStatement(sqlExport);
        int idx = 1;
        psE.setString(idx++, maSV);
        if (!namHoc.isEmpty()) psE.setString(idx++, namHoc);
        if (!hocKy.isEmpty()) psE.setString(idx++, hocKy);

        ResultSet rsE = psE.executeQuery();

        out.println("Mã Môn\tTên Môn\tSố TC\tCC\tGK\tCK\tĐiểm TB\tHọc kỳ\tNăm học");
        while (rsE.next()) {
            out.println(
                rsE.getString("MaMon") + "\t" +
                rsE.getString("TenMon") + "\t" +
                rsE.getInt("SoTinChi") + "\t" +
                rsE.getDouble("DiemCC") + "\t" +
                rsE.getDouble("DiemGK") + "\t" +
                rsE.getDouble("DiemCK") + "\t" +
                rsE.getDouble("DiemTB") + "\t" +
                rsE.getString("HocKy") + "\t" +
                rsE.getString("NamHoc")
            );
        }

        rsE.close();
        psE.close();
        conn.close();
        return; // Dừng JSP tại đây sau khi tải file
    }

    // ===========================================
    // ✅ PHẦN CHÍNH: HIỂN THỊ BẢNG KẾT QUẢ
    // ===========================================
    double tongDiem10 = 0, tongHe4 = 0;
    int tongTC = 0;
    String xepLoai = "-";
    List<Map<String, Object>> listKetQua = new ArrayList<>();

    try {
        String sql = "SELECT mh.MaMon, mh.TenMon, mh.SoTinChi, d.DiemCC, d.DiemGK, d.DiemCK, "
                   + "d.DiemTB AS DiemHe10, "
                   + "CASE "
                   + " WHEN d.DiemTB >= 8.5 THEN 4.0 "
                   + " WHEN d.DiemTB >= 7.8 THEN 3.5 "
                   + " WHEN d.DiemTB >= 7.0 THEN 3.0 "
                   + " WHEN d.DiemTB >= 6.3 THEN 2.5 "
                   + " WHEN d.DiemTB >= 5.5 THEN 2.0 "
                   + " WHEN d.DiemTB >= 4.8 THEN 1.5 "
                   + " WHEN d.DiemTB >= 4.0 THEN 1.0 "
                   + " ELSE 0 END AS DiemHe4, "
                   + "CASE "
                   + " WHEN d.DiemTB >= 8.5 THEN 'A' "
                   + " WHEN d.DiemTB >= 7.8 THEN 'B+' "
                   + " WHEN d.DiemTB >= 7.0 THEN 'B' "
                   + " WHEN d.DiemTB >= 6.3 THEN 'C+' "
                   + " WHEN d.DiemTB >= 5.5 THEN 'C' "
                   + " WHEN d.DiemTB >= 4.8 THEN 'D+' "
                   + " WHEN d.DiemTB >= 4.0 THEN 'D' "
                   + " ELSE 'F' END AS DiemChu "
                   + "FROM diem d JOIN monhoc mh ON d.MaMon = mh.MaMon WHERE d.MaSV = ?";

        if (!namHoc.isEmpty()) sql += " AND d.NamHoc = ?";
        if (!hocKy.isEmpty()) sql += " AND d.HocKy = ?";
        sql += " ORDER BY mh.MaMon";

        PreparedStatement ps = conn.prepareStatement(sql);
        int idx = 1;
        ps.setString(idx++, maSV);
        if (!namHoc.isEmpty()) ps.setString(idx++, namHoc);
        if (!hocKy.isEmpty()) ps.setString(idx++, hocKy);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("maMon", rs.getString("MaMon"));
            row.put("tenMon", rs.getString("TenMon"));
            row.put("soTinChi", rs.getInt("SoTinChi"));
            row.put("diemCC", rs.getDouble("DiemCC"));
            row.put("diemGK", rs.getDouble("DiemGK"));
            row.put("diemCK", rs.getDouble("DiemCK"));
            row.put("diemHe10", rs.getDouble("DiemHe10"));
            row.put("diemHe4", rs.getDouble("DiemHe4"));
            row.put("diemChu", rs.getString("DiemChu"));
            listKetQua.add(row);

            tongDiem10 += rs.getDouble("DiemHe10") * rs.getInt("SoTinChi");
            tongHe4 += rs.getDouble("DiemHe4") * rs.getInt("SoTinChi");
            tongTC += rs.getInt("SoTinChi");
        }

        rs.close();
        ps.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>❌ Lỗi truy vấn dữ liệu: " + e.getMessage() + "</p>");
    }

    double gpa10 = tongTC > 0 ? tongDiem10 / tongTC : 0;
    double gpa4 = tongTC > 0 ? tongHe4 / tongTC : 0;

    if (gpa4 >= 3.6) xepLoai = "Xuất sắc";
    else if (gpa4 >= 3.2) xepLoai = "Giỏi";
    else if (gpa4 >= 2.5) xepLoai = "Khá";
    else if (gpa4 >= 2.0) xepLoai = "Trung bình";
    else if (gpa4 > 0) xepLoai = "Yếu";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Kết quả học tập | MONKEY</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style.css">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
</head>
<body>

<%@ include file="header-sv.jsp" %>

<main class="main-content">
  <header class="main-header">
    <h1 class="page-title">Kết quả học tập</h1>
  </header>

  <div class="page-content-wrapper">
    <!-- Bộ lọc -->
    <form method="get" class="filter-form" id="filterForm">
      <label>Năm học:</label>
      <select name="namhoc" onchange="document.getElementById('filterForm').submit()">
        <option value="">Tất cả</option>
        <option value="2024-2025" <%= "2024-2025".equals(namHoc) ? "selected" : "" %>>2024-2025</option>
        <option value="2025-2026" <%= "2025-2026".equals(namHoc) ? "selected" : "" %>>2025-2026</option>
      </select>

      <label>Học kỳ:</label>
      <select name="hocky" onchange="document.getElementById('filterForm').submit()">
        <option value="">Tất cả</option>
        <option value="1" <%= "1".equals(hocKy) ? "selected" : "" %>>Học kỳ 1</option>
        <option value="2" <%= "2".equals(hocKy) ? "selected" : "" %>>Học kỳ 2</option>
      </select>
    </form>

    <!-- Tổng hợp -->
    <section class="card-grid-summary">
      <div class="summary-card"><span class="summary-title">GPA (Hệ 4)</span><span class="summary-value"><%= String.format("%.2f", gpa4) %></span></div>
      <div class="summary-card"><span class="summary-title">GPA (Hệ 10)</span><span class="summary-value"><%= String.format("%.2f", gpa10) %></span></div>
      <div class="summary-card"><span class="summary-title">Tín chỉ tích lũy</span><span class="summary-value"><%= tongTC %></span></div>
      <div class="summary-card"><span class="summary-title">Xếp loại</span><span class="summary-value"><%= xepLoai %></span></div>
    </section>

    <!-- Bảng điểm -->
    <section class="card">
      <div class="card-header" style="display:flex; justify-content:space-between; align-items:center;">
        <h2 class="section-title">Bảng điểm chi tiết</h2>
        <form method="post" style="display:inline;">
          <input type="hidden" name="action" value="exportExcel">
          <input type="hidden" name="hocky" value="<%= hocKy %>">
          <input type="hidden" name="namhoc" value="<%= namHoc %>">
          <button type="submit" class="btn-primary-outline">📊 Xuất Excel</button>
        </form>
      </div>

      <div class="table-responsive">
        <table class="course-table">
          <thead>
            <tr>
              <th>Mã Môn</th><th>Tên Môn</th><th>Số TC</th>
              <th>CC</th><th>GK</th><th>CK</th>
              <th>Điểm (10)</th><th>Điểm (4)</th><th>Điểm chữ</th>
            </tr>
          </thead>
          <tbody>
            <%
              if (listKetQua.isEmpty()) {
                  out.println("<tr><td colspan='9' style=\"text-align:center;color:gray;\">Không có dữ liệu học tập</td></tr>");
              } else {
                  for (Map<String, Object> row : listKetQua) {
            %>
            <tr>
              <td><%= row.get("maMon") %></td>
              <td><%= row.get("tenMon") %></td>
              <td><%= row.get("soTinChi") %></td>
              <td><%= row.get("diemCC") %></td>
              <td><%= row.get("diemGK") %></td>
              <td><%= row.get("diemCK") %></td>
              <td><%= row.get("diemHe10") %></td>
              <td><%= row.get("diemHe4") %></td>
              <td><%= row.get("diemChu") %></td>
            </tr>
            <% } } %>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</main>

<div class="sidebar-overlay" id="sidebar-overlay"></div>
<script src="<%= request.getContextPath() %>/WebContent/assets/js/main.js"></script>

</body>
</html>
