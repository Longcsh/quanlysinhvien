<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*, java.text.DecimalFormat" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    // ✅ Kiểm tra đăng nhập
    Object svUser = session.getAttribute("user");
    Object vaiTro = session.getAttribute("vaiTro");
    Object maThamChieu = session.getAttribute("maThamChieu");

    if (svUser == null || vaiTro == null || maThamChieu == null) {
        response.sendRedirect(request.getContextPath() + "/dangnhap.jsp");
        return;
    }

    // ✅ Chỉ cho phép vai trò sinh viên (3)
    if (!vaiTro.toString().equals("3")) {
        response.sendRedirect(request.getContextPath() + "/dangnhap.jsp");
        return;
    }

    // ✅ Lấy mã sinh viên từ session
    String maSV = maThamChieu.toString();

    // ✅ Lấy học kỳ & năm học
    String hocKy = request.getParameter("hocKy") != null ? request.getParameter("hocKy") : "HK1";
    String namHoc = request.getParameter("namHoc") != null ? request.getParameter("namHoc") : "2025-2026";

    int tongDiem = 0;
    String xepLoai = "Chưa có";

    // ✅ Lấy điểm tổng & xếp loại (chỉ tính hoạt động đã duyệt)
    PreparedStatement ps = conn.prepareStatement(
        "SELECT SUM(hd.Diem) AS TongDiem " +
        "FROM sinhvien_hoatdong shd " +
        "JOIN hoatdong hd ON shd.MaHD = hd.MaHD " +
        "WHERE shd.MaSV = ? AND shd.HocKy = ? AND shd.NamHoc = ? AND shd.TrangThai = 'Đã duyệt'"
    );
    ps.setString(1, maSV);
    ps.setString(2, hocKy);
    ps.setString(3, namHoc);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
        tongDiem = rs.getInt("TongDiem");
        if (tongDiem >= 90) xepLoai = "Xuất sắc";
        else if (tongDiem >= 80) xepLoai = "Tốt";
        else if (tongDiem >= 65) xepLoai = "Khá";
        else if (tongDiem >= 50) xepLoai = "Trung bình";
        else if (tongDiem > 0) xepLoai = "Yếu";
    }

    // ✅ Lấy chi tiết hoạt động
    PreparedStatement psCT = conn.prepareStatement(
        "SELECT hd.TenHD AS HoatDong, mr.TenMuc AS Muc, hd.Diem, shd.TrangThai " +
        "FROM sinhvien_hoatdong shd " +
        "JOIN hoatdong hd ON shd.MaHD = hd.MaHD " +
        "JOIN muc_renluyen mr ON hd.MaMuc = mr.MaMuc " +
        "WHERE shd.MaSV = ? AND shd.HocKy = ? AND shd.NamHoc = ?"
    );
    psCT.setString(1, maSV);
    psCT.setString(2, hocKy);
    psCT.setString(3, namHoc);
    ResultSet rsCT = psCT.executeQuery();

    // ✅ Kiểm tra xem có hoạt động nào chưa duyệt không
    boolean coChuaDuyet = false;
    PreparedStatement psCheck = conn.prepareStatement(
        "SELECT COUNT(*) AS ChuaDuyet FROM sinhvien_hoatdong WHERE MaSV=? AND HocKy=? AND NamHoc=? AND (TrangThai IS NULL OR TrangThai='' OR TrangThai='Chờ duyệt')"
    );
    psCheck.setString(1, maSV);
    psCheck.setString(2, hocKy);
    psCheck.setString(3, namHoc);
    ResultSet rsCheck = psCheck.executeQuery();
    if (rsCheck.next() && rsCheck.getInt("ChuaDuyet") > 0) {
        coChuaDuyet = true;
    }
    rsCheck.close();
    psCheck.close();

    // ✅ Lấy lịch sử rèn luyện (tổng điểm & trạng thái qua các kỳ)
    PreparedStatement psHis = conn.prepareStatement(
        "SELECT HocKy, NamHoc, SUM(hd.Diem) AS TongDiem, MAX(shd.TrangThai) AS TrangThai " +
        "FROM sinhvien_hoatdong shd JOIN hoatdong hd ON shd.MaHD=hd.MaHD " +
        "WHERE shd.MaSV=? GROUP BY HocKy, NamHoc ORDER BY NamHoc DESC, HocKy ASC"
    );
    psHis.setString(1, maSV);
    ResultSet rsHis = psHis.executeQuery();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả rèn luyện | MONKEY</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <style>
        .filter-form {
            margin: 20px 0;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .filter-form select,
        .filter-form button {
            padding: 5px 10px;
            font-size: 14px;
        }
        .progress-bar {
            background: #e5e5e5;
            border-radius: 20px;
            overflow: hidden;
            height: 20px;
            margin-top: 10px;
        }
        .progress {
            background: #2ecc71;
            height: 100%;
            transition: width 0.4s ease;
        }
        .btn-download {
            padding: 8px 14px;
            background: #1f5b92;
            color: #fff;
            border: none;
            cursor: pointer;
            border-radius: 4px;
        }
        .btn-download:hover {
            background: #144069;
        }
        .btn-request {
            padding: 8px 14px;
            background: #c27b00;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn-request:hover {
            background: #a76900;
        }
        table.course-table th, table.course-table td {
            text-align: center;
        }
    </style>
</head>

<body>
<%@ include file="header-sv.jsp" %>

<main class="main-content">
    <header class="main-header">
        <div class="header-left">
            <h1 class="page-title">Kết quả rèn luyện</h1>
        </div>
    </header>

    <div class="page-content-wrapper">

        <!-- Bộ lọc -->
       <form method="get" class="filter-form" id="filterForm">
    <label>Học kỳ:</label>
    <select name="hocKy" id="hocKySelect">
        <option value="HK1" <%= hocKy.equals("HK1") ? "selected" : "" %>>HK1</option>
        <option value="HK2" <%= hocKy.equals("HK2") ? "selected" : "" %>>HK2</option>
    </select>

    <label>Năm học:</label>
    <select name="namHoc" id="namHocSelect">
        <option value="2024-2025" <%= namHoc.equals("2024-2025") ? "selected" : "" %>>2024-2025</option>
        <option value="2025-2026" <%= namHoc.equals("2025-2026") ? "selected" : "" %>>2025-2026</option>
    </select>
</form>

<script>
    // Khi người dùng đổi học kỳ hoặc năm học, form tự động submit
    document.getElementById('hocKySelect').addEventListener('change', () => {
        document.getElementById('filterForm').submit();
    });
    document.getElementById('namHocSelect').addEventListener('change', () => {
        document.getElementById('filterForm').submit();
    });
</script>

        <!-- Tổng kết -->
        <section class="card-grid-summary">
            <div class="summary-card">
                <span class="summary-title">Điểm rèn luyện (<%= hocKy %> - <%= namHoc %>)</span>
                <span class="summary-value gpa"><%= tongDiem %></span>
                <div class="progress-bar">
                    <div class="progress" style="<%= "width:" + tongDiem + "%;" %>"></div>
                </div>
            </div>
            <div class="summary-card">
                <span class="summary-title">Xếp loại</span>
                <span class="summary-value"><%= xepLoai %></span>
            </div>
        </section>

        <!-- Nút chức năng -->
        <div style="margin:20px 0;">

            <form action="exportRenLuyenPDF.jsp" method="post" style="display:inline-block; margin-left:10px;">
                <input type="hidden" name="maSV" value="<%= maSV %>">
                <input type="hidden" name="hocKy" value="<%= hocKy %>">
                <input type="hidden" name="namHoc" value="<%= namHoc %>">
                <button type="submit" class="btn-download">Tải PDF kết quả</button>
            </form>
        </div>
        <!-- Đăng ký hoạt động -->
<section class="card">
    <div class="card-header">
        <h2 class="section-title">Đăng ký hoạt động rèn luyện</h2>
    </div>
    <div style="padding:15px;">
        <form action="dangkyhoatdong.jsp" method="post">
            <label>Chọn hoạt động:</label>
            <select name="maHD" required>
                <option value="">-- Chọn hoạt động --</option>
                <%
                    PreparedStatement psHD = conn.prepareStatement(
                        "SELECT MaHD, TenHD, Diem FROM hoatdong ORDER BY TenHD ASC"
                    );
                    ResultSet rsHD = psHD.executeQuery();
                    while (rsHD.next()) {
                %>
                <option value="<%= rsHD.getString("MaHD") %>">
                    <%= rsHD.getString("TenHD") %> (+<%= rsHD.getInt("Diem") %> điểm)
                </option>
                <%
                    }
                    rsHD.close();
                    psHD.close();
                %>
            </select>
            <input type="hidden" name="maSV" value="<%= maSV %>">
            <input type="hidden" name="hocKy" value="<%= hocKy %>">
            <input type="hidden" name="namHoc" value="<%= namHoc %>">
            <button type="submit" class="btn-request" style="margin-left:10px;">Đăng ký</button>
        </form>
        <p style="margin-top:8px;font-size:13px;color:gray;">
            Sau khi đăng ký, hoạt động sẽ hiển thị ở danh sách bên dưới với trạng thái “Chờ duyệt”.
        </p>
    </div>
</section>


        <!-- Chi tiết hoạt động -->
        <section class="card">
            <div class="card-header">
                <h2 class="section-title">Chi tiết hoạt động</h2>
            </div>
            <div class="table-responsive">
                <table class="course-table">
                    <thead>
                        <tr>
                            <th>Hoạt động</th>
                            <th>Mục</th>
                            <th>Điểm</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean coDuLieu = false;
                            while (rsCT.next()) {
                                coDuLieu = true;
                        %>
                        <tr>
                            <td><%= rsCT.getString("HoatDong") %></td>
                            <td><%= rsCT.getString("Muc") %></td>
                            <td><%= rsCT.getInt("Diem") %></td>
                            <td><%= rsCT.getString("TrangThai") != null ? rsCT.getString("TrangThai") : "Chưa duyệt" %></td>
                        </tr>
                        <%
                            }
                            if (!coDuLieu) {
                                out.println("<tr><td colspan='4' style='text-align:center;color:gray;'>Không có dữ liệu rèn luyện</td></tr>");
                            }

                            rs.close();
                            rsCT.close();
                            ps.close();
                            psCT.close();
                        %>
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Lịch sử rèn luyện -->
        <section class="card" style="margin-top:30px;">
            <div class="card-header">
                <h2 class="section-title">Lịch sử rèn luyện các học kỳ</h2>
            </div>
            <div class="table-responsive">
                <table class="course-table">
                    <thead>
                        <tr>
                            <th>Học kỳ</th>
                            <th>Năm học</th>
                            <th>Tổng điểm</th>
                            <th>Trạng thái</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean coHis = false;
                            while (rsHis.next()) {
                                coHis = true;
                        %>
                        <tr>
                            <td><%= rsHis.getString("HocKy") %></td>
                            <td><%= rsHis.getString("NamHoc") %></td>
                            <td><%= rsHis.getInt("TongDiem") %></td>
                            <td><%= rsHis.getString("TrangThai") != null ? rsHis.getString("TrangThai") : "Chưa duyệt" %></td>
                        </tr>
                        <%
                            }
                            if (!coHis) {
                                out.println("<tr><td colspan='4' style='text-align:center;color:gray;'>Chưa có lịch sử rèn luyện</td></tr>");
                            }

                            rsHis.close();
                            psHis.close();
                            conn.close();
                        %>
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
