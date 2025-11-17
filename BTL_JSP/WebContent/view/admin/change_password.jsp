<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.security.MessageDigest" %>

<%! 
// ===== HÀM MD5 (đặt trong DECLARATION: <%! %>) =====
String md5(String s) throws Exception {
    MessageDigest md = MessageDigest.getInstance("MD5");
    byte[] b = md.digest(s.getBytes("UTF-8"));
    StringBuilder sb = new StringBuilder();
    for (byte x : b) {
        String hex = Integer.toHexString((x & 0xff) | 0x100).substring(1,3);
        sb.append(hex);
    }
    return sb.toString();
}
%>

<%
/* ===== CẤU HÌNH DB & BIẾN TRẠNG THÁI (đặt trong SCRIPTLET: <% %>) ===== */
request.setCharacterEncoding("UTF-8");

final String JDBC_URL  = "jdbc:mysql://localhost:3306/qlsv?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
final String JDBC_USER = "root";
final String JDBC_PASS = "";

// thông báo cho UI
String msg  = null;
String type = null;

// username từ session (nếu có) hoặc từ form
String sessionUser = (String) session.getAttribute("username");
String formUser    = request.getParameter("username");

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String username = (sessionUser != null && !sessionUser.isEmpty())
                        ? sessionUser
                        : (formUser != null ? formUser.trim() : "");
    String oldPass  = request.getParameter("oldPassword")  != null ? request.getParameter("oldPassword")  : "";
    String newPass  = request.getParameter("newPassword")  != null ? request.getParameter("newPassword")  : "";
    String confirm  = request.getParameter("confirmPassword") != null ? request.getParameter("confirmPassword") : "";

    if (username.isEmpty() || oldPass.isEmpty() || newPass.isEmpty() || confirm.isEmpty()) {
        msg = "Vui lòng nhập đầy đủ thông tin.";
        type = "error";
    } else if (!newPass.equals(confirm)) {
        msg = "Mật khẩu mới và xác nhận không khớp.";
        type = "error";
    } else if (newPass.length() < 6) {
        msg = "Mật khẩu mới tối thiểu 6 ký tự.";
        type = "error";
    } else {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASS)) {
                // lấy mật khẩu hiện tại
                String sqlSel = "SELECT MatKhau FROM nguoidung WHERE TenDangNhap=? AND TrangThai=1";
                try (PreparedStatement ps = conn.prepareStatement(sqlSel)) {
                    ps.setString(1, username);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            msg = "Tài khoản không tồn tại hoặc đã bị khóa.";
                            type = "error";
                        } else {
                            String dbPass = rs.getString("MatKhau");
                            boolean okOld = oldPass.equals(dbPass) || md5(oldPass).equalsIgnoreCase(dbPass);

                            if (!okOld) {
                                msg = "Mật khẩu hiện tại không đúng.";
                                type = "error";
                            } else {
                                // cập nhật về MD5 cho đồng nhất
                                String sqlUpd = "UPDATE nguoidung SET MatKhau=? WHERE TenDangNhap=?";
                                try (PreparedStatement up = conn.prepareStatement(sqlUpd)) {
                                    up.setString(1, md5(newPass));
                                    up.setString(2, username);
                                    int n = up.executeUpdate();
                                    if (n > 0) { msg = "Đổi mật khẩu thành công."; type = "success"; }
                                    else      { msg = "Không thể cập nhật mật khẩu."; type = "error"; }
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            msg = "Lỗi hệ thống: " + e.getMessage();
            type = "error";
        }
    }
}
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đổi mật khẩu</title>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
    <style>
        body{font-family:Segoe UI,Arial,sans-serif;background:#f5f8fd;margin:0;display:flex;align-items:center;justify-content:center;height:100vh}
        .card{background:#fff;width:380px;border-radius:16px;box-shadow:0 10px 30px rgba(0,0,0,.08);padding:24px}
        .title{display:flex;gap:8px;align-items:center;font-weight:600;color:#0B63E5;margin-bottom:16px}
        .row{margin-bottom:12px}
        label{display:block;font-size:13px;margin-bottom:6px;color:#333}
        input[type=text],input[type=password]{width:100%;padding:10px 12px;border:1px solid #e4e8f1;border-radius:10px;outline:none}
        input:focus{border-color:#0B63E5}
        .btn{width:100%;padding:12px;border:none;border-radius:12px;background:#0B63E5;color:#fff;font-weight:600;cursor:pointer}
        .btn:hover{opacity:.95}
        .alert{padding:10px 12px;border-radius:10px;margin-bottom:12px}
        .alert.success{background:#e7f7ee;color:#0f6e3b;border:1px solid #bfe7cf}
        .alert.error{background:#fdeeee;color:#9b1c1c;border:1px solid #f5c2c7}
        .note{font-size:12px;color:#666;margin-top:6px}
        .muted{font-size:12px;color:#777;margin-top:8px}
    </style>
</head>
<body>
<div class="card">
    <div class="title"><span class="material-icons-outlined">lock</span>Đổi mật khẩu</div>

    <% if (msg != null) { %>
        <div class="alert <%= ("success".equals(type) ? "success" : "error") %>"><%= msg %></div>
    <% } %>

    <form method="post">
        <%
            boolean hasSessionUser = (sessionUser != null && !sessionUser.isEmpty());
        %>
        <div class="row" <%= hasSessionUser ? "style='display:none'" : "" %>>
            <label>Tên đăng nhập</label>
            <input type="text" name="username" placeholder="vd: sv001" value="<%= (formUser!=null?formUser:"") %>">
            <div class="note">Nếu hệ thống đã đăng nhập, trường này sẽ tự ẩn.</div>
        </div>

        <div class="row">
            <label>Mật khẩu hiện tại</label>
            <input type="password" name="oldPassword" required>
        </div>
        <div class="row">
            <label>Mật khẩu mới</label>
            <input type="password" name="newPassword" required>
        </div>
        <div class="row">
            <label>Nhập lại mật khẩu mới</label>
            <input type="password" name="confirmPassword" required>
        </div>

        <button class="btn" type="submit">Cập nhật</button>
        <div class="muted">Mật khẩu mới được lưu dạng MD5.</div>
    </form>
</div>
</body>
</html>
