<%@ page import="java.sql.*, java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String JDBC_URL  = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
    String JDBC_USER = "root";
    String JDBC_PASS = "";

    String action  = request.getParameter("action");
    String MaSV    = request.getParameter("MaSV");
    String MaHP    = request.getParameter("MaHP");

    try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {

        // ===== Xử lý duyệt / hủy đăng ký =====
        if (action != null) {
            if ("approve".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE dangkyhocphan SET TrangThai='daduyet' WHERE MaSV=? AND MaHP=?")) {
                    ps.setString(1, MaSV);
                    ps.setString(2, MaHP);
                    ps.executeUpdate();
                }
            } else if ("reject".equals(action)) {
                try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE dangkyhocphan SET TrangThai='tuchoi' WHERE MaSV=? AND MaHP=?")) {
                    ps.setString(1, MaSV);
                    ps.setString(2, MaHP);
                    ps.executeUpdate();
                }
            }
            response.sendRedirect(request.getRequestURI());
            return;
        }

        // ===== Lấy danh sách đăng ký chờ duyệt =====
        List<Map<String,Object>> dkList = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT dk.MaSV, sv.HoTen, dk.MaHP, mh.TenMon, mh.SoTinChi, dk.NgayDangKy, dk.TrangThai " +
            "FROM dangkyhocphan dk " +
            "JOIN sinhvien sv ON sv.MaSV = dk.MaSV " +
            "JOIN hocphan hp ON hp.MaHP = dk.MaHP " +
            "JOIN monhoc mh ON mh.MaMon = hp.MaMon " +
            "WHERE dk.TrangThai = 'choxacnhan' " +
            "ORDER BY dk.NgayDangKy DESC")) {

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new HashMap<>();
                    row.put("MaSV", rs.getString("MaSV"));
                    row.put("HoTen", rs.getString("HoTen"));
                    row.put("MaHP", rs.getString("MaHP"));
                    row.put("TenMon", rs.getString("TenMon"));
                    row.put("SoTinChi", rs.getInt("SoTinChi"));
                    row.put("NgayDangKy", rs.getTimestamp("NgayDangKy"));
                    row.put("TrangThai", rs.getString("TrangThai"));
                    dkList.add(row);
                }
            }
        }
        request.setAttribute("dkList", dkList);

    } catch (Exception e) {
        e.printStackTrace();
        out.print("<pre>Lỗi: " + e.getMessage() + "</pre>");
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Duyệt đăng ký học phần | MONKEY Edusoft</title>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">

    <style>
        body {
            font-family: "Poppins", sans-serif;
            background-color: #f5f7fb;
            color: #2b2b2b;
            margin: 0;
        }
        .sidebar {
            width: 260px;
            background: linear-gradient(180deg, #1e88e5, #42a5f5);
            color: white;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            overflow-y: auto;
            padding: 1rem;
        }
        .sidebar-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .sidebar-logo {
            display: flex;
            align-items: center;
            text-decoration: none;
            color: white;
        }
        .sidebar-logo img {
            height: 40px;
            margin-right: 8px;
        }
        .nav-list {
            list-style: none;
            margin: 20px 0 0 0;
            padding: 0;
        }
        .nav-item {
            margin-bottom: 8px;
        }
        .nav-link {
            display: flex;
            align-items: center;
            padding: 10px;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            transition: background 0.2s;
        }
        .nav-link:hover, .nav-link.active {
            background: rgba(255,255,255,0.2);
        }
        .nav-link .material-icons-outlined {
            margin-right: 10px;
        }
        .main-content {
            margin-left: 270px;
            padding: 20px;
        }
        .page-title {
            font-size: 22px;
            margin: 0;
            color: #1e88e5;
        }
        .card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 15px;
        }
        th, td {
            border-bottom: 1px solid #ddd;
            padding: 10px;
        }
        th {
            background: #e3f2fd;
            color: #1565c0;
            text-align: left;
        }
        tr:hover {
            background: #f1faff;
        }
        .btn-icon {
            background: none;
            border: none;
            cursor: pointer;
        }
        .btn-icon:hover {
            transform: scale(1.1);
        }
        .section-title {
            margin-bottom: 10px;
            font-weight: 600;
            color: #1e88e5;
        }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <nav class="sidebar">
        <div class="sidebar-header">
            <a href="admin_dashboard.jsp" class="sidebar-logo">
               
            </a>
        </div>

        <ul class="nav-list">
            <li class="nav-item"><a href="admin_dashboard.jsp" class="nav-link"><span class="material-icons-outlined">admin_panel_settings</span>Trang chủ Admin</a></li>
            <li class="nav-section-title">Quản lý</li>
            <li class="nav-item"><a href="admin_qlsv.jsp" class="nav-link"><span class="material-icons-outlined">school</span>Quản lý Sinh viên</a></li>
            <li class="nav-item"><a href="admin_qlgv.jsp" class="nav-link"><span class="material-icons-outlined">account_box</span>Quản lý Giảng viên</a></li>
            <li class="nav-item"><a href="admin_qlmh.jsp" class="nav-link"><span class="material-icons-outlined">book</span>Quản lý Môn học</a></li>
            <li class="nav-item"><a href="admin_qllop.jsp" class="nav-link"><span class="material-icons-outlined">corporate_fare</span>Quản lý Khoa/Lớp</a></li>
            <li class="nav-section-title">Nghiệp vụ</li>

            <li class="nav-item"><a href="admin_xemdiem.jsp" class="nav-link"><span class="material-icons-outlined">grade</span>Quản lý điểm</a></li>
                                        <li class="nav-item"><a href="duyetdangky.jsp" class="nav-link active"><span class="material-icons-outlined">how_to_reg</span>Duyệt đăng ký tín </a></li>
            <li class="nav-item" role="menuitem"><a href="admin_bctk.jsp" class="nav-link active"><span class="material-icons-outlined">assessment</span><span>Báo cáo Thống kê</span></a></li>
        </ul>
    </nav>

    <!-- MAIN CONTENT -->   
    <main class="main-content">
        <h1 class="page-title">Duyệt đăng ký học phần</h1>

        <section class="card">
            <h2 class="section-title">Danh sách chờ duyệt</h2>

            <table>
                <thead>
                    <tr>
                        <th>Mã SV</th>
                        <th>Họ tên</th>
                        <th>Mã HP</th>
                        <th>Tên môn</th>
                        <th>Số TC</th>
                        <th>Ngày đăng ký</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<Map<String,Object>> dkList = (List<Map<String,Object>>) request.getAttribute("dkList");
                        if (dkList != null && !dkList.isEmpty()) {
                            for (Map<String,Object> row : dkList) {
                    %>
                    <tr>
                        <td><%= row.get("MaSV") %></td>
                        <td><%= row.get("HoTen") %></td>
                        <td><%= row.get("MaHP") %></td>
                        <td><%= row.get("TenMon") %></td>
                        <td style="text-align:center"><%= row.get("SoTinChi") %></td>
                        <td><%= row.get("NgayDangKy") %></td>
                        <td><%= row.get("TrangThai") %></td>
                        <td>
                            <form method="post" style="display:inline">
                                <input type="hidden" name="action" value="approve">
                                <input type="hidden" name="MaSV" value="<%= row.get("MaSV") %>">
                                <input type="hidden" name="MaHP" value="<%= row.get("MaHP") %>">
                                <button class="btn-icon" title="Duyệt">
                                    <span class="material-icons-outlined" style="color:green">check</span>
                                </button>
                            </form>
                            <form method="post" style="display:inline" onsubmit="return confirm('Từ chối đăng ký này?');">
                                <input type="hidden" name="action" value="reject">
                                <input type="hidden" name="MaSV" value="<%= row.get("MaSV") %>">
                                <input type="hidden" name="MaHP" value="<%= row.get("MaHP") %>">
                                <button class="btn-icon" title="Từ chối">
                                    <span class="material-icons-outlined" style="color:red">close</span>
                                </button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr><td colspan="8" style="text-align:center;color:gray">Không có đăng ký nào chờ duyệt.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </section>
    </main>
</body>
</html>
