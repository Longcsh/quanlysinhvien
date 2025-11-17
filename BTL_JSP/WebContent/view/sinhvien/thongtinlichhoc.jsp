<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*" %>

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

    if (!vaiTro.toString().equals("3")) { // chỉ sinh viên
        response.sendRedirect(request.getContextPath() + "/dangnhap.jsp");
        return;
    }

    String maSV = maThamChieu.toString();

    // ✅ Lấy học kỳ và năm học (mặc định HK1 - 2025-2026)
    String hocKy = request.getParameter("hocKy") != null ? request.getParameter("hocKy") : "1";
    String namHoc = request.getParameter("namHoc") != null ? request.getParameter("namHoc") : "2025-2026";

    // ✅ Truy vấn danh sách học phần đã được duyệt
    String sql =
        "SELECT mh.TenMon, mh.SoTinChi, hp.MaHP, hp.Nhom, hp.HocKy, hp.NamHoc, " +
        "hp.PhongHoc, hp.ThuHoc, hp.TietBatDau, hp.SoTiet, hp.NgayBatDau, hp.NgayKetThuc, " +
        "gv.HoTen AS TenGV " +
        "FROM dangkyhocphan dk " +
        "JOIN hocphan hp ON dk.MaHP = hp.MaHP " +
        "JOIN monhoc mh ON hp.MaMon = mh.MaMon " +
        "JOIN giangvien gv ON hp.MaGV = gv.MaGV " +
        "WHERE dk.MaSV = ? AND dk.TrangThai = 'daduyet' " +
        "AND hp.HocKy = ? AND hp.NamHoc = ? " +
        "ORDER BY FIELD(hp.ThuHoc, 'Thứ 2','Thứ 3','Thứ 4','Thứ 5','Thứ 6','Thứ 7'), hp.TietBatDau";

    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setString(1, maSV);
    ps.setString(2, hocKy);
    ps.setString(3, namHoc);
    ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin lịch học | MONKEY</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
</head>
<body>

<!-- ===================== SIDEBAR ===================== -->
<nav class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <a href="dashboard.jsp" class="sidebar-logo">
            <img src="<%= request.getContextPath() %>/WebContent/assets/images/logo.png" alt="Logo">
            <span>MONKEY</span>
        </a>
        <button class="btn-icon btn-close-sidebar" aria-label="Đóng menu" id="close-sidebar">
            <span class="material-icons-outlined">close</span>
        </button>
    </div>

    <div class="sidebar-content">
        <ul class="nav-list" role="menu">
            <li class="nav-item"><a href="dashboard.jsp" class="nav-link"><span class="material-icons-outlined">space_dashboard</span><span>Trang chủ</span></a></li>
            <li class="nav-item"><a href="dangky.jsp" class="nav-link"><span class="material-icons-outlined">app_registration</span><span>Đăng ký tín chỉ</span></a></li>

            <li class="nav-item has-submenu">
                <a href="#" class="nav-link-toggle">
                    <span class="material-icons-outlined">bar_chart</span><span>Kết quả</span>
                    <span class="material-icons-outlined expand-icon">expand_more</span>
                </a>
                <ul class="submenu">
                    <li><a href="ketquahoctap.jsp">Kết quả học tập</a></li>
                    <li><a href="ketquarenluyen.jsp">Kết quả rèn luyện</a></li>
                </ul>
            </li>

            <li class="nav-item has-submenu is-open">
                <a href="#" class="nav-link-toggle">
                    <span class="material-icons-outlined">feed</span><span>Thông tin</span>
                    <span class="material-icons-outlined expand-icon">expand_more</span>
                </a>
                <ul class="submenu">
                    <li><a href="thongtinlichhoc.jsp" class="active">Thông tin lịch học</a></li>
                    <li><a href="thongtinlichthi.jsp">Thông tin lịch thi</a></li>
                </ul>
            </li>
        </ul>
    </div>
</nav>

<!-- ===================== MAIN ===================== -->
<main class="main-content">
    <header class="main-header">
        <div class="header-left">
            <button class="btn-icon btn-open-sidebar" id="open-sidebar">
                <span class="material-icons-outlined">menu</span>
            </button>
            <h1 class="page-title">Thông tin lịch học</h1>
        </div>
    </header>

    <div class="page-content-wrapper">
        <section class="card">
            <div class="card-header">
                <h2 class="section-title">Thời khóa biểu (HK<%= hocKy %> - <%= namHoc %>)</h2>
                <button class="btn-primary-outline" onclick="window.print()">
                    <span class="material-icons-outlined">print</span> In lịch học
                </button>
            </div>

            <!-- ✅ Bộ lọc học kỳ + năm học (đã sửa đúng logic) -->
            <form method="get" id="filterForm" 
                  action="thongtinlichhoc.jsp" 
                  style="margin:15px 0; display:flex; gap:10px; align-items:center;">
                <label>Học kỳ:</label>
                <select name="hocKy" id="hocKySelect">
                    <option value="1" <%= hocKy.equals("1") ? "selected" : "" %>>HK1</option>
                    <option value="2" <%= hocKy.equals("2") ? "selected" : "" %>>HK2</option>
                </select>

                <label>Năm học:</label>
                <select name="namHoc" id="namHocSelect">
                    <%
                        String sqlNam = 
                            "SELECT DISTINCT hp.NamHoc " +
                            "FROM hocphan hp " +
                            "JOIN dangkyhocphan dk ON hp.MaHP = dk.MaHP " +
                            "WHERE dk.MaSV = ? " +
                            "ORDER BY hp.NamHoc DESC";
                        PreparedStatement psNam = conn.prepareStatement(sqlNam);
                        psNam.setString(1, maSV);
                        ResultSet rsNam = psNam.executeQuery();
                        while (rsNam.next()) {
                            String nam = rsNam.getString("NamHoc");
                    %>
                        <option value="<%= nam %>" <%= nam.equals(namHoc) ? "selected" : "" %>>
                            <%= nam %>
                        </option>
                    <%
                        }
                        rsNam.close();
                        psNam.close();
                    %>
                </select>
            </form>

            <script>
                // ✅ Tự động submit khi thay đổi lựa chọn
                const form = document.getElementById('filterForm');
                document.getElementById('hocKySelect').addEventListener('change', () => form.submit());
                document.getElementById('namHocSelect').addEventListener('change', () => form.submit());
            </script>

            <div class="table-responsive">
                <table class="schedule-table">
                    <thead>
                        <tr>
                            <th>Mã HP</th>
                            <th>Môn học</th>
                            <th>Số tín chỉ</th>
                            <th>Giảng viên</th>
                            <th>Phòng học</th>
                            <th>Thứ</th>
                            <th>Tiết bắt đầu</th>
                            <th>Số tiết</th>
                            <th>Ngày bắt đầu</th>
                            <th>Ngày kết thúc</th>
                            <th>Nhóm</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean coLich = false;
                            while (rs.next()) {
                                coLich = true;
                        %>
                        <tr>
                            <td><%= rs.getString("MaHP") %></td>
                            <td><%= rs.getString("TenMon") %></td>
                            <td><%= rs.getInt("SoTinChi") %></td>
                            <td><%= rs.getString("TenGV") %></td>
                            <td><%= rs.getString("PhongHoc") %></td>
                            <td><%= rs.getString("ThuHoc") %></td>
                            <td><%= rs.getInt("TietBatDau") %></td>
                            <td><%= rs.getInt("SoTiet") %></td>
                            <td><%= rs.getDate("NgayBatDau") %></td>
                            <td><%= rs.getDate("NgayKetThuc") %></td>
                            <td><%= rs.getString("Nhom") %></td>
                        </tr>
                        <%
                            }
                            if (!coLich) {
                        %>
                        <tr><td colspan="11" style="text-align:center;color:gray;">Chưa có thời khóa biểu được duyệt</td></tr>
                        <%
                            }
                            rs.close();
                            ps.close();
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
