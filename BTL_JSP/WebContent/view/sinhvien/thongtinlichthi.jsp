<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    // ✅ Kiểm tra đăng nhập (chỉ cho phép sinh viên)
    Object svUser = session.getAttribute("user");
    Object vaiTro = session.getAttribute("vaiTro");
    Object maThamChieu = session.getAttribute("maThamChieu");

    if (svUser == null || vaiTro == null || maThamChieu == null || !vaiTro.toString().equals("3")) {
        response.sendRedirect(request.getContextPath() + "/dangnhap.jsp");
        return;
    }

    String maSV = maThamChieu.toString();

    // ✅ Lấy học kỳ & năm học từ request hoặc gán mặc định
    String hocKy = request.getParameter("hocKy") != null ? request.getParameter("hocKy") : "1";
    String namHoc = request.getParameter("namHoc") != null ? request.getParameter("namHoc") : "2025-2026";
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin lịch thi | MONKEY</title>
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
        <button class="btn-icon btn-close-sidebar" id="close-sidebar">
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
                    <li><a href="thongtinlichhoc.jsp">Thông tin lịch học</a></li>
                    <li><a href="thongtinlichthi.jsp" class="active">Thông tin lịch thi</a></li>
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
            <h1 class="page-title">Thông tin lịch thi</h1>
        </div>
    </header>

    <div class="page-content-wrapper">
        <section class="card">
            <div class="card-header">
                <h2 class="section-title">Lịch thi (HK<%= hocKy %> - <%= namHoc %>)</h2>

                <!-- 🔍 Bộ lọc học kỳ + năm học -->
                <form method="get" id="filterForm" style="display:flex; align-items:center; gap:10px;">
                    <label>Học kỳ:</label>
                    <select name="hocKy" id="hocKySelect">
                        <option value="1" <%= hocKy.equals("1") ? "selected" : "" %>>1</option>
                        <option value="2" <%= hocKy.equals("2") ? "selected" : "" %>>2</option>
                    </select>

                    <label>Năm học:</label>
                    <select name="namHoc" id="namHocSelect">
                        <%
                            // ✅ Lấy danh sách năm học từ bảng lichthi của sinh viên
                            String sqlNam = 
                                "SELECT DISTINCT NamHoc FROM lichthi WHERE MaSV = ? ORDER BY NamHoc DESC";
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

                    <button type="button" class="btn-primary-outline" onclick="window.print()">
                        <span class="material-icons-outlined">print</span> In lịch thi
                    </button>
                </form>
            </div>

            <script>
                // ✅ Tự động submit khi chọn học kỳ hoặc năm học
                const f = document.getElementById('filterForm');
                document.getElementById('hocKySelect').addEventListener('change', () => f.submit());
                document.getElementById('namHocSelect').addEventListener('change', () => f.submit());
            </script>

            <div class="table-responsive">
                <table class="course-table">
                    <thead>
                        <tr>
                            <th>Mã HP</th>
                            <th>Tên học phần</th>
                            <th>Ngày thi</th>
                            <th>Giờ thi</th>
                            <th>Phòng thi</th>
                            <th>Hình thức</th>
                            <th>SBD</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // ✅ Lấy dữ liệu lịch thi của sinh viên
                            String sqlThi = 
                                "SELECT lt.MaHP, mh.TenMon, lt.NgayThi, lt.GioThi, lt.PhongThi, lt.HinhThuc, lt.SBD " +
                                "FROM lichthi lt " +
                                "JOIN hocphan hp ON lt.MaHP = hp.MaHP " +
                                "JOIN monhoc mh ON hp.MaMon = mh.MaMon " +
                                "WHERE lt.MaSV = ? AND lt.HocKy = ? AND lt.NamHoc = ? " +
                                "ORDER BY lt.NgayThi ASC";

                            PreparedStatement ps = conn.prepareStatement(sqlThi);
                            ps.setString(1, maSV);
                            ps.setString(2, hocKy);
                            ps.setString(3, namHoc);
                            ResultSet rs = ps.executeQuery();

                            boolean hasData = false;
                            while (rs.next()) {
                                hasData = true;
                        %>
                        <tr>
                            <td><%= rs.getString("MaHP") %></td>
                            <td><%= rs.getString("TenMon") %></td>
                            <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("NgayThi")) %></td>
                            <td><%= rs.getString("GioThi") %></td>
                            <td><%= rs.getString("PhongThi") %></td>
                            <td><%= rs.getString("HinhThuc") %></td>
                            <td><%= rs.getString("SBD") %></td>
                        </tr>
                        <%
                            }
                            if (!hasData) {
                        %>
                        <tr>
                            <td colspan="7" style="text-align:center; color:gray;">Không có lịch thi nào cho học kỳ này</td>
                        </tr>
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
