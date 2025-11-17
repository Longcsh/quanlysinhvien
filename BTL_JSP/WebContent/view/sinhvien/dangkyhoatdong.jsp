<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

String maSV = request.getParameter("maSV");
String maHD = request.getParameter("maHD");
String hocKy = request.getParameter("hocKy");
String namHoc = request.getParameter("namHoc");

if (maSV == null || maHD == null || hocKy == null || namHoc == null) {
    out.println("<script>alert('Thiếu thông tin!'); history.back();</script>");
    return;
}

// ✅ Kiểm tra trùng lặp
PreparedStatement psCheck = conn.prepareStatement(
    "SELECT COUNT(*) AS Cnt FROM sinhvien_hoatdong WHERE MaSV=? AND MaHD=? AND HocKy=? AND NamHoc=?"
);
psCheck.setString(1, maSV);
psCheck.setString(2, maHD);
psCheck.setString(3, hocKy);
psCheck.setString(4, namHoc);
ResultSet rsCheck = psCheck.executeQuery();
rsCheck.next();
if (rsCheck.getInt("Cnt") > 0) {
    out.println("<script>alert('Bạn đã đăng ký hoạt động này!'); history.back();</script>");
    rsCheck.close();
    psCheck.close();
    conn.close();
    return;
}
rsCheck.close();
psCheck.close();

// ✅ Thêm mới
PreparedStatement ps = conn.prepareStatement(
    "INSERT INTO sinhvien_hoatdong (MaSV, MaHD, HocKy, NamHoc, TrangThai) VALUES (?,?,?,?, 'Chờ duyệt')"
);
ps.setString(1, maSV);
ps.setString(2, maHD);
ps.setString(3, hocKy);
ps.setString(4, namHoc);
ps.executeUpdate();
ps.close();
conn.close();

out.println("<script>alert('Đăng ký hoạt động thành công!'); window.location='ketquarenluyen.jsp?hocKy="+hocKy+"&namHoc="+namHoc+"';</script>");
%>
