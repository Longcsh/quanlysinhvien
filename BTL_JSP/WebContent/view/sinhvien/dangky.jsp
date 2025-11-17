<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../../db/connect.jsp" %>
<%@ include file="header-sv.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    // ✅ Kiểm tra đăng nhập
    String maSV = (String) session.getAttribute("maSV");
    if (maSV == null || maSV.trim().isEmpty()) {
        maSV = (String) session.getAttribute("maThamChieu");
    }

    if (maSV == null || maSV.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/WebContent/dangnhap.jsp");
        return;
    }

    // ✅ Biến lưu thông báo
    String message = "";

    // ✅ Xử lý hành động Đăng ký / Hủy
    String action = request.getParameter("action");
    String maHP = request.getParameter("maHP");

    if (action != null && maHP != null && !maHP.trim().isEmpty()) {
        try {
            if (action.equals("dangky")) {
                // 🧩 1️⃣ Kiểm tra học phần đã đăng ký chưa
                String sqlCheck = "SELECT COUNT(*) FROM dangkyhocphan WHERE MaSV = ? AND MaHP = ? AND (TrangThai IS NULL OR TrangThai NOT IN ('huy'))";
                PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
                psCheck.setString(1, maSV);
                psCheck.setString(2, maHP);
                ResultSet rsCheck = psCheck.executeQuery();
                rsCheck.next();
                int count = rsCheck.getInt(1);
                rsCheck.close();
                psCheck.close();

                if (count > 0) {
                    message = "⚠️ Bạn đã đăng ký học phần này trước đó!";
                } else {
                    // 🧩 2️⃣ Kiểm tra tổng số tín chỉ hiện tại
                    String sqlTongTC = "SELECT SUM(mh.SoTinChi) FROM dangkyhocphan dk "
                                     + "JOIN hocphan hp ON dk.MaHP = hp.MaHP "
                                     + "JOIN monhoc mh ON hp.MaMon = mh.MaMon "
                                     + "WHERE dk.MaSV = ? AND (dk.TrangThai IS NULL OR dk.TrangThai NOT IN ('huy'))";
                    PreparedStatement psTC = conn.prepareStatement(sqlTongTC);
                    psTC.setString(1, maSV);
                    ResultSet rsTC = psTC.executeQuery();
                    int tongTC = 0;
                    if (rsTC.next()) tongTC = rsTC.getInt(1);
                    rsTC.close(); psTC.close();

                    // Lấy tín chỉ của học phần muốn đăng ký
                    String sqlTCMon = "SELECT mh.SoTinChi FROM hocphan hp JOIN monhoc mh ON hp.MaMon = mh.MaMon WHERE hp.MaHP = ?";
                    PreparedStatement psTC2 = conn.prepareStatement(sqlTCMon);
                    psTC2.setString(1, maHP);
                    ResultSet rsTC2 = psTC2.executeQuery();
                    int soTCMoi = 0;
                    if (rsTC2.next()) soTCMoi = rsTC2.getInt(1);
                    rsTC2.close(); psTC2.close();

                    if (tongTC + soTCMoi > 25) {
                        message = "⚠️ Bạn đã đạt giới hạn tối đa 25 tín chỉ trong học kỳ này!";
                    } else {
                        // 🧩 3️⃣ Kiểm tra trùng thời khóa biểu
                        String sqlTrung = 
                            "SELECT COUNT(*) FROM dangkyhocphan dk "
                          + "JOIN hocphan hp1 ON dk.MaHP = hp1.MaHP "
                          + "JOIN hocphan hp2 ON hp2.MaHP = ? "
                          + "WHERE dk.MaSV = ? "
                          + "AND (dk.TrangThai IS NULL OR dk.TrangThai NOT IN ('huy')) "
                          + "AND hp1.ThuHoc = hp2.ThuHoc "
                          + "AND ((hp2.TietBatDau BETWEEN hp1.TietBatDau AND (hp1.TietBatDau + hp1.SoTiet - 1)) "
                          + "   OR (hp1.TietBatDau BETWEEN hp2.TietBatDau AND (hp2.TietBatDau + hp2.SoTiet - 1)))";
                        PreparedStatement psTrung = conn.prepareStatement(sqlTrung);
                        psTrung.setString(1, maHP);
                        psTrung.setString(2, maSV);
                        ResultSet rsTrung = psTrung.executeQuery();
                        rsTrung.next();
                        int trung = rsTrung.getInt(1);
                        rsTrung.close(); psTrung.close();

                        if (trung > 0) {
                            message = "⚠️ Học phần này trùng thời khóa biểu với môn khác bạn đã đăng ký!";
                        } else {
                            // 🧩 4️⃣ Cho phép đăng ký
                            String sqlInsert = "INSERT INTO dangkyhocphan (MaSV, MaHP, TrangThai, NgayDangKy) VALUES (?, ?, 'choxacnhan', CURDATE())";
                            PreparedStatement psInsert = conn.prepareStatement(sqlInsert);
                            psInsert.setString(1, maSV);
                            psInsert.setString(2, maHP);
                            psInsert.executeUpdate();
                            psInsert.close();
                            message = "✅ Đăng ký thành công học phần " + maHP;
                        }
                    }
                }
            } else if (action.equals("huy")) {
    try {
        // 🧩 Kiểm tra trạng thái học phần trước khi hủy
        String sqlCheck = "SELECT TrangThai FROM dangkyhocphan WHERE MaSV = ? AND MaHP = ?";
        PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
        psCheck.setString(1, maSV);
        psCheck.setString(2, maHP);
        ResultSet rsCheck = psCheck.executeQuery();

        if (rsCheck.next()) {
            String tt = rsCheck.getString("TrangThai");
            if ("daduyet".equalsIgnoreCase(tt)) {
                message = "⚠️ Học phần này đã được duyệt, không thể hủy!";
            } else {
                String sqlDelete = "DELETE FROM dangkyhocphan WHERE MaSV = ? AND MaHP = ?";
                PreparedStatement psDelete = conn.prepareStatement(sqlDelete);
                psDelete.setString(1, maSV);
                psDelete.setString(2, maHP);
                int rows = psDelete.executeUpdate();
                psDelete.close();

                if (rows > 0)
                    message = "🗑️ Hủy đăng ký học phần " + maHP + " thành công!";
                else
                    message = "⚠️ Không tìm thấy học phần cần hủy!";
            }
        } else {
            message = "⚠️ Không tìm thấy học phần cần hủy!";
        }

        rsCheck.close();
        psCheck.close();
    } catch (Exception e) {
        message = "❌ Lỗi khi hủy học phần: " + e.getMessage();
    }
}

        } catch (Exception e) {
            message = "❌ Lỗi cập nhật dữ liệu: " + e.getMessage();
        }

        session.setAttribute("msg", message);
        response.sendRedirect("dangky.jsp");
        return;
    }

    // ✅ Hiển thị thông báo nếu có
    String alertMsg = (String) session.getAttribute("msg");
    if (alertMsg != null) {
        session.removeAttribute("msg");
        String jsSafe = alertMsg.replace("\\", "\\\\")
                                .replace("\"", "\\\"")
                                .replace("\n", "\\n")
                                .replace("\r", "");
%>
<script>
    (function(){
        var msg = "<%= jsSafe %>";
        alert(msg);
    })();
</script>
<%
    }

    // ✅ Lấy danh sách học phần
    List<Map<String, String>> listDaDK = new ArrayList<>();
    List<Map<String, String>> listChuaDK = new ArrayList<>();

    try {
        // 🔹 Học phần đã đăng ký
        String sqlDaDK =
            "SELECT dk.MaHP, mh.TenMon, mh.SoTinChi, hp.Nhom, hp.PhongHoc, hp.ThuHoc, hp.TietBatDau, hp.SoTiet, hp.NgayBatDau, hp.NgayKetThuc, dk.TrangThai " +
            "FROM dangkyhocphan dk " +
            "JOIN hocphan hp ON dk.MaHP = hp.MaHP " +
            "JOIN monhoc mh ON hp.MaMon = mh.MaMon " +
            "WHERE dk.MaSV = ? AND (dk.TrangThai IS NULL OR dk.TrangThai NOT IN ('huy')) " +
            "ORDER BY dk.NgayDangKy DESC";

        PreparedStatement ps1 = conn.prepareStatement(sqlDaDK);
        ps1.setString(1, maSV);
        ResultSet rs1 = ps1.executeQuery();
        while (rs1.next()) {
            Map<String, String> row = new HashMap<>();
            row.put("maHP", rs1.getString("MaHP"));
            row.put("tenMon", rs1.getString("TenMon"));
            row.put("soTinChi", rs1.getString("SoTinChi"));
            row.put("nhom", rs1.getString("Nhom"));
            row.put("phongHoc", rs1.getString("PhongHoc"));
            row.put("thuHoc", rs1.getString("ThuHoc"));
            row.put("tietBatDau", rs1.getString("TietBatDau"));
            row.put("soTiet", rs1.getString("SoTiet"));
            row.put("ngayBatDau", rs1.getString("NgayBatDau"));
            row.put("ngayKetThuc", rs1.getString("NgayKetThuc"));
            row.put("trangThai", rs1.getString("TrangThai"));
            listDaDK.add(row);
        }
        rs1.close(); ps1.close();

        // 🔹 Học phần chưa đăng ký
        String sqlChuaDK =
            "SELECT hp.MaHP, mh.TenMon, mh.SoTinChi, hp.Nhom, hp.PhongHoc, hp.ThuHoc, hp.TietBatDau, hp.SoTiet, hp.NgayBatDau, hp.NgayKetThuc " +
            "FROM hocphan hp " +
            "JOIN monhoc mh ON hp.MaMon = mh.MaMon " +
            "WHERE hp.MaHP NOT IN (" +
            "  SELECT MaHP FROM dangkyhocphan WHERE MaSV = ? AND (TrangThai IS NULL OR TrangThai NOT IN ('huy'))" +
            ")";
        PreparedStatement ps2 = conn.prepareStatement(sqlChuaDK);
        ps2.setString(1, maSV);
        ResultSet rs2 = ps2.executeQuery();
        while (rs2.next()) {
            Map<String, String> row = new HashMap<>();
            row.put("maHP", rs2.getString("MaHP"));
            row.put("tenMon", rs2.getString("TenMon"));
            row.put("soTinChi", rs2.getString("SoTinChi"));
            row.put("nhom", rs2.getString("Nhom"));
            row.put("phongHoc", rs2.getString("PhongHoc"));
            row.put("thuHoc", rs2.getString("ThuHoc"));
            row.put("tietBatDau", rs2.getString("TietBatDau"));
            row.put("soTiet", rs2.getString("SoTiet"));
            row.put("ngayBatDau", rs2.getString("NgayBatDau"));
            row.put("ngayKetThuc", rs2.getString("NgayKetThuc"));
            listChuaDK.add(row);
        }
        rs2.close(); ps2.close();

    } catch (Exception e) {
        out.println("<p style='color:red;'>Lỗi truy vấn: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Đăng ký tín chỉ | MONKEY</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style.css">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
  <script>
    function confirmAction(url, msg) {
        if (confirm(msg)) window.location.href = url;
    }
  </script>
  <style>
    .status-badge {
      padding: 4px 8px;
      border-radius: 6px;
      font-weight: 600;
      text-transform: capitalize;
    }
    .status-badge.wait { background:#fef3c7; color:#92400e; }
    .status-badge.done { background:#dcfce7; color:#166534; }
    .status-badge.reject { background:#fee2e2; color:#b91c1c; }
  </style>
</head>
<body>

<main class="main-content">
  <header class="main-header">
    <h1 class="page-title">Đăng ký tín chỉ</h1>
  </header>

  <div class="page-content-wrapper">
    <!-- ==== HỌC PHẦN ĐÃ ĐĂNG KÝ ==== -->
    <section class="card">
      <div class="card-header">
        <h2 class="section-title">Học phần đã đăng ký</h2>
        <span class="total-credits">Tổng số: <%= listDaDK.size() %></span>
      </div>
      <div class="table-responsive">
        <table class="course-table">
          <thead>
            <tr>
              <th>Mã HP</th><th>Tên học phần</th><th>Số TC</th>
              <th>Nhóm</th><th>Phòng</th><th>Thứ</th><th>Tiết bắt đầu</th><th>Số tiết</th><th>Bắt đầu</th><th>Kết thúc</th>
              <th>Trạng thái</th><th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <% for (Map<String,String> hp : listDaDK) { 
                 String maHP2 = hp.get("maHP").replace("'", "\\'");
            %>
              <tr>
                <td><%= hp.get("maHP") %></td>
                <td><%= hp.get("tenMon") %></td>
                <td><%= hp.get("soTinChi") %></td>
                <td><%= hp.get("nhom") %></td>
                <td><%= hp.get("phongHoc") %></td>
                <td><%= hp.get("thuHoc") %></td>
                <td><%= hp.get("tietBatDau") %></td>
                <td><%= hp.get("soTiet") %></td>
                <td><%= hp.get("ngayBatDau") %></td>
                <td><%= hp.get("ngayKetThuc") %></td>
                <td>
                  <% String tt = hp.get("trangThai");
                     if (tt == null || "choxacnhan".equals(tt)) { %>
                        <span class="status-badge wait">Chờ duyệt</span>
                  <% } else if ("daduyet".equals(tt)) { %>
                        <span class="status-badge done">Đã duyệt</span>
                  <% } else if ("tuchoi".equals(tt)) { %>
                        <span class="status-badge reject">Từ chối</span>
                  <% } else { %>
                        <span class="status-badge"><%= tt %></span>
                  <% } %>
                </td>
                <td>
                  <a href="javascript:void(0)" class="btn-danger-outline"
                     onclick="confirmAction('dangky.jsp?action=huy&maHP=<%= maHP2 %>', 'Bạn có chắc chắn muốn hủy học phần <%= maHP2 %>?')">
                    Hủy
                  </a>
                </td>
              </tr>
            <% } %>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ==== HỌC PHẦN MỞ ==== -->
    <section class="card">
      <h2 class="section-title">Học phần mở</h2>
      <div class="table-responsive">
        <table class="course-table">
          <thead>
            <tr>
              <th>Mã HP</th><th>Tên học phần</th><th>Số TC</th>
              <th>Nhóm</th><th>Phòng</th><th>Thứ</th><th>Tiết bắt đầu</th><th>Số tiết</th><th>Bắt đầu</th><th>Kết thúc</th><th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            <% for (Map<String,String> hp : listChuaDK) { 
                 String maHP3 = hp.get("maHP").replace("'", "\\'");
            %>
              <tr>
                <td><%= hp.get("maHP") %></td>
                <td><%= hp.get("tenMon") %></td>
                <td><%= hp.get("soTinChi") %></td>
                <td><%= hp.get("nhom") %></td>
                <td><%= hp.get("phongHoc") %></td>
                <td><%= hp.get("thuHoc") %></td>
                <td><%= hp.get("tietBatDau") %></td>
                <td><%= hp.get("soTiet") %></td>
                <td><%= hp.get("ngayBatDau") %></td>
                <td><%= hp.get("ngayKetThuc") %></td>
                <td>
                  <a href="javascript:void(0)" class="btn-primary-outline"
                     onclick="confirmAction('dangky.jsp?action=dangky&maHP=<%= maHP3 %>', 'Bạn có muốn đăng ký học phần <%= maHP3 %>?')">
                    Đăng ký
                  </a>
                </td>
              </tr>
            <% } %>
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
