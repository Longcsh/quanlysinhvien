<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>

<%
    // ✅ Kiểm tra đăng nhập
    Object user = session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../dangnhap.jsp");
        return;
    }

    // ✅ Lấy ID thông báo
    String idParam = request.getParameter("id");
    if (idParam == null) {
        out.println("<h3>Thiếu mã thông báo!</h3>");
        return;
    }

    int id = Integer.parseInt(idParam);

    // ✅ Truy vấn chi tiết thông báo
    PreparedStatement ps = conn.prepareStatement("SELECT * FROM thongbao WHERE id = ?");
    ps.setInt(1, id);
    ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết thông báo | MONKEY</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">

    <style>
        body {
            font-family: "Open Sans", sans-serif;
            background: #f6f8fb;
            color: #333;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 950px;
            margin: 60px auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 40px 60px;
        }
        .back-btn {
            display: inline-flex;
            align-items: center;
            color: #00334d;
            font-weight: 600;
            text-decoration: none;
            margin-bottom: 25px;
            transition: color 0.2s;
        }
        .back-btn:hover { color: #caa53f; }
        .back-btn span {
            font-size: 20px;
            margin-right: 6px;
        }
        h1 {
            font-size: 28px;
            color: #00334d;
            margin-bottom: 10px;
        }
        .meta {
            font-size: 15px;
            color: #6b6b6b;
            margin-bottom: 25px;
        }
        hr {
            border: none;
            height: 1px;
            background: #e0e0e0;
            margin: 25px 0;
        }
        .content {
            font-size: 17px;
            line-height: 1.8;
            color: #222;
            white-space: pre-line;
        }
        .no-result {
            text-align: center;
            padding: 50px;
            color: #999;
            font-size: 18px;
        }
    </style>
</head>
<body>

    <div class="container">
        <a href="dashboard.jsp" class="back-btn">
            <span class="material-icons-outlined">arrow_back</span> Quay lại trang chủ
        </a>

        <%
            if (rs.next()) {
        %>
            <h1><%= rs.getString("tieu_de") %></h1>
            <div class="meta">
                <span><b>Loại:</b> <%= rs.getString("loai") %></span> |
                <span><b>Ngày đăng:</b> <%= rs.getDate("ngay_dang") %></span>
            </div>
            <hr>
            <div class="content">
                <%= rs.getString("noi_dung") %>
            </div>
        <%
            } else {
        %>
            <div class="no-result">Không tìm thấy thông báo này.</div>
        <%
            }
            rs.close();
            ps.close();
            conn.close();
        %>
    </div>

</body>
</html>
