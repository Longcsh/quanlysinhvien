<%@ page language="java" contentType="application/vnd.ms-excel; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../../db/connect.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    // 🟩 Bạn có thể đổi đuôi file giữa Word và Excel:
    // Word  → "attachment; filename=ketqua_renluyen.doc"
    // Excel → "attachment; filename=ketqua_renluyen.xls"
    response.setHeader("Content-Disposition", "attachment; filename=ketqua_renluyen.xls");

    String maSV = request.getParameter("maSV");
    String hocKy = request.getParameter("hocKy");
    String namHoc = request.getParameter("namHoc");

    if (maSV == null || hocKy == null || namHoc == null) {
        out.println("Thiếu tham số!");
        return;
    }

    int tongDiem = 0;
    String xepLoai = "Chưa có";

    PreparedStatement ps = conn.prepareStatement(
        "SELECT SUM(hd.Diem) AS TongDiem FROM sinhvien_hoatdong shd " +
        "JOIN hoatdong hd ON shd.MaHD = hd.MaHD " +
        "WHERE shd.MaSV=? AND shd.HocKy=? AND shd.NamHoc=? AND shd.TrangThai='Đã duyệt'"
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
    rs.close();
    ps.close();

    PreparedStatement psCT = conn.prepareStatement(
        "SELECT hd.TenHD, mr.TenMuc, hd.Diem, shd.TrangThai " +
        "FROM sinhvien_hoatdong shd " +
        "JOIN hoatdong hd ON shd.MaHD = hd.MaHD " +
        "JOIN muc_renluyen mr ON hd.MaMuc = mr.MaMuc " +
        "WHERE shd.MaSV=? AND shd.HocKy=? AND shd.NamHoc=?"
    );
    psCT.setString(1, maSV);
    psCT.setString(2, hocKy);
    psCT.setString(3, namHoc);
    ResultSet rsCT = psCT.executeQuery();

    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
      xmlns:x="urn:schemas-microsoft-com:office:excel"
      xmlns="http://www.w3.org/TR/REC-html40">
<head>
<meta charset="UTF-8">
<style>
    body { font-family: "Times New Roman", Arial, sans-serif; }
    h1 { text-align: center; color: #003366; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #444; padding: 6px; text-align: center; }
    th { background: #eaeaea; }
</style>
</head>
<body>
    <h1>KẾT QUẢ RÈN LUYỆN SINH VIÊN</h1>

    <p><b>Mã sinh viên:</b> <%= maSV %></p>
    <p><b>Học kỳ:</b> <%= hocKy %> &nbsp;&nbsp;&nbsp; <b>Năm học:</b> <%= namHoc %></p>
    <p><b>Tổng điểm:</b> <%= tongDiem %> &nbsp;&nbsp;&nbsp; <b>Xếp loại:</b> <%= xepLoai %></p>

    <table>
        <tr>
            <th>Hoạt động</th>
            <th>Mục</th>
            <th>Điểm</th>
            <th>Trạng thái</th>
        </tr>
        <%
            boolean coDL = false;
            while (rsCT.next()) {
                coDL = true;
        %>
        <tr>
            <td><%= rsCT.getString("TenHD") %></td>
            <td><%= rsCT.getString("TenMuc") %></td>
            <td><%= rsCT.getInt("Diem") %></td>
            <td><%= rsCT.getString("TrangThai") != null ? rsCT.getString("TrangThai") : "Chưa duyệt" %></td>
        </tr>
        <%
            }
            if (!coDL) {
        %>
        <tr><td colspan="4" style="color:gray;">Không có dữ liệu rèn luyện</td></tr>
        <% } %>
    </table>

    <p style="margin-top:30px;">Ngày xuất: <%= sdf.format(new java.util.Date()) %></p>
</body>
</html>

<%
    rsCT.close();
    psCT.close();
    conn.close();
%>
