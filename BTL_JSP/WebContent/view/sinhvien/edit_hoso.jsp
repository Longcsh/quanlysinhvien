<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.NguoiDung, model.SinhVien, dao.SinhVienDAO" %>
<%
    NguoiDung user = (NguoiDung) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/WebContent/dangnhap.jsp");
        return;
    }
    String maSV = user.getMaThamChieu();
    SinhVien sv = SinhVienDAO.getByMaSV(maSV);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Chỉnh sửa hồ sơ | MONKEY</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<style>
body { background:#f3f4f6; font-family:'Segoe UI',sans-serif; }
.form-card {
    max-width:700px; margin:50px auto; background:white; padding:35px 40px;
    border-radius:16px; box-shadow:0 10px 25px rgba(0,0,0,0.1);
}
.btn-save { background:#2563eb; color:white; border:none; padding:10px 20px; border-radius:6px; }
.btn-save:hover { background:#1e3a8a; }
</style>
</head>
<body>
<div class="form-card">
<h3>✏️ Cập nhật thông tin sinh viên</h3>
<form action="<%=request.getContextPath()%>/WebContent/CapNhatSinhVienController" method="post">
    <input type="hidden" name="maSV" value="<%= sv.getMaSV() %>">
    <div class="mb-3">
        <label class="form-label">Họ tên</label>
        <input type="text" name="hoTen" class="form-control" value="<%= sv.getHoTen() %>">
    </div>
    <div class="mb-3">
        <label class="form-label">Ngày sinh</label>
        <input type="date" name="ngaySinh" class="form-control" value="<%= sv.getNgaySinh() %>">
    </div>
    <div class="mb-3">
        <label class="form-label">Giới tính</label>
        <input type="text" name="gioiTinh" class="form-control" value="<%= sv.getGioiTinh() %>">
    </div>
    <div class="mb-3">
        <label class="form-label">Địa chỉ</label>
        <input type="text" name="diaChi" class="form-control" value="<%= sv.getDiaChi() %>">
    </div>
    <div class="mb-3">
        <label class="form-label">Số điện thoại</label>
        <input type="text" name="soDT" class="form-control" value="<%= sv.getSoDT() %>">
    </div>
    <div class="mb-3">
        <label class="form-label">Email</label>
        <input type="email" name="email" class="form-control" value="<%= sv.getEmail() %>">
    </div>
    <button type="submit" class="btn-save">💾 Lưu thay đổi</button>
    <a href="hoso.jsp" class="btn btn-secondary">← Quay lại</a>
</form>
</div>
</body>
</html>
