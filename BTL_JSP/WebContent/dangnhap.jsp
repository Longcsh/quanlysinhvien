<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="db/connect.jsp" %>
<%@ page session="true" %>

<%
String message = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String tenDangNhap = request.getParameter("username");
    String matKhau = request.getParameter("password");
    String vaiTroChon = request.getParameter("role");

    if (tenDangNhap != null && matKhau != null && vaiTroChon != null) {
        try {
            String sql = "SELECT * FROM nguoidung WHERE TenDangNhap=? AND MatKhau=? AND VaiTro=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, tenDangNhap);
            ps.setString(2, matKhau);
            ps.setString(3, vaiTroChon);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                int vaiTro = rs.getInt("VaiTro");
                String maThamChieu = rs.getString("MaThamChieu");

                session.setAttribute("user", tenDangNhap);
                session.setAttribute("vaiTro", vaiTro);
                session.setAttribute("maThamChieu", maThamChieu);

                if (vaiTro == 1) {
                    response.sendRedirect("view/admin/admin_dashboard.jsp");
                } else if (vaiTro == 2) {
                    response.sendRedirect("view/giangvien/giangvien_dashboard.jsp");
                } else {
                    response.sendRedirect("view/sinhvien/dashboard.jsp");
                }
                return;
            } else {
                message = "❌ Sai thông tin đăng nhập hoặc vai trò!";
            }

            rs.close();
            ps.close();
        } catch (SQLException e) {
            message = "Lỗi CSDL: " + e.getMessage();
        } finally {
            if (conn != null) conn.close();
        }
    } else {
        message = "⚠️ Vui lòng nhập đầy đủ thông tin.";
    }
}
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng nhập hệ thống</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <style>
       body {
    margin: 0;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: #eeedf3;
    font-family: "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}

.login-container {
    background: #fff;
    width: 400px;
    padding: 36px 38px 32px;
    border-radius: 14px;
    box-shadow: 0 6px 20px rgba(0,0,0,0.08);
    text-align: center;
}

.logo {
    width: 95px;
    height: auto;
    display: block;
    margin: 0 auto 12px;
}

h2 {
    font-size: 20px;
    font-weight: 600;
    color: #173d87;
    margin-bottom: 20px;
}

/* Căn chỉnh chiều cao và khoảng cách các ô nhập */
select, input {
    width: 100%;
    height: 42px; /* 👈 đồng nhất tất cả */
    padding: 0 12px;
    margin-bottom: 14px;
    border: 1px solid #ccc;
    border-radius: 8px;
    font-size: 15px;
    transition: all 0.2s;
    box-sizing: border-box;
}

select:focus, input:focus {
    outline: none;
    border-color: #2563eb;
    box-shadow: 0 0 5px rgba(37,99,235,0.25);
}

.link {
    text-align: right;
    margin-top: -4px;
    margin-bottom: 12px;
}

.link a {
    color: #2563eb;
    text-decoration: none;
    font-size: 13px;
}
.link a:hover { text-decoration: underline; }

/* Nút cân đều và cùng chiều cao */
.btn-group {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    margin-top: 8px;
}

.btn {
    flex: 1;
    height: 42px;
    border: none;
    border-radius: 8px;
    color: #fff;
    font-weight: 600;
    font-size: 15px;
    cursor: pointer;
    transition: 0.2s;
}

.btn-primary { background-color: #1e88e5; }
.btn-secondary { background-color: #d32f2f; }

.btn:hover { opacity: 0.9; }

.error {
    margin-top: 14px;
    color: #c53030;
    font-size: 14px;
    min-height: 18px;
}

    </style>
</head>
<body>
    <div class="login-container">
        <!-- ⚙️ Cập nhật đường dẫn logo cho đúng -->
        <img src="img/Logo_Trường_Đại_học_Thủ_đô_Hà_Nội.jpg" alt="Logo Trường Đại học Thủ Đô Hà Nội" class="logo">

        <h2>Đăng nhập tài khoản</h2>

        <form method="post">
            <select name="role" required>
                <option value="">-- Chọn vai trò --</option>
                <option value="3">Sinh viên</option>
                <option value="2">Giảng viên</option>
                <option value="1">Quản trị viên</option>
            </select>

            <input type="text" name="username" placeholder="Tài khoản" required>
            <input type="password" name="password" placeholder="Mật khẩu" required>

            <div class="link">
                <a href="quenmatkhau.jsp">[ Quên mật khẩu ]</a>
            </div>

            <div class="btn-group">
                <button type="submit" class="btn btn-primary">Đăng nhập</button>
            </div>

            <div class="error"><%= message %></div>
        </form>
    </div>
</body>
</html>
