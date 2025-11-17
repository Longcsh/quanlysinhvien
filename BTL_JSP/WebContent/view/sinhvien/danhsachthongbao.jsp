<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>

<%
    Object user = session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../dangnhap.jsp");
        return;
    }

    // ✅ Lấy toàn bộ danh sách thông báo (mới nhất trước)
    PreparedStatement ps = conn.prepareStatement("SELECT * FROM thongbao ORDER BY ngay_dang DESC");
    ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Danh sách thông báo | MONKEY</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/fix-dropdown.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">

    <style>
        .announcement-list {
            padding: 30px 50px;
            background: #f5f7f8;
            font-family: "Open Sans", sans-serif;
        }
        .announcement-item {
            background: #fff;
            margin-bottom: 18px;
            padding: 20px 25px;
            border-radius: 10px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
            transition: all 0.2s ease;
        }
        .announcement-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.12);
        }
        .announcement-item h3 {
            color: #00334d;
            margin-bottom: 6px;
        }
        .announcement-item .meta {
            color: #777;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .announcement-item p {
            color: #333;
            line-height: 1.6;
            margin-bottom: 8px;
        }
        .announcement-item a {
            color: #caa53f;
            text-decoration: none;
            font-weight: 600;
        }
        .announcement-item a:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>
    <main class="main-content">
        <header class="main-header">
            <div class="header-left">
                <button onclick="window.history.back()" class="btn-icon">
                    <span class="material-icons-outlined">arrow_back</span>
                </button>
                <h1 class="page-title">Danh sách thông báo</h1>
            </div>
        </header>

        <section class="announcement-list">
            <%
                boolean coThongBao = false;
                while (rs.next()) {
                    coThongBao = true;
            %>
                <div class="announcement-item">
                    <h3><%= rs.getString("tieu_de") %></h3>
                    <div class="meta">
                        <b><%= rs.getString("loai") %></b> | 
                        <%= rs.getDate("ngay_dang") %>
                    </div>
                    <p><%= rs.getString("noi_dung").length() > 180 
                            ? rs.getString("noi_dung").substring(0, 180) + "..." 
                            : rs.getString("noi_dung") %></p>
                    <a href="javascript:void(0)" onclick="xemThongBao(<%= rs.getInt("id") %>)">Đọc chi tiết →</a>
                </div>
            <%
                }
                if (!coThongBao) {
                    out.println("<p style='text-align:center;color:gray;'>Hiện chưa có thông báo nào.</p>");
                }
            %>
        </section>
    </main>

    <!-- POPUP hiển thị chi tiết -->
    <div id="popupThongBao" class="popup-overlay" style="display:none;">
      <div class="popup-box">
        <button class="close-btn" onclick="dongPopup()">
          <span class="material-icons-outlined">close</span>
        </button>
        <div id="popupContent" class="popup-content">
          <p style="text-align:center;color:gray;">Đang tải nội dung...</p>
        </div>
      </div>
    </div>

    <!-- JS -->
    <script>
    function xemThongBao(id) {
      const popup = document.getElementById("popupThongBao");
      const content = document.getElementById("popupContent");
      popup.style.display = "flex";
      content.innerHTML = "<p style='text-align:center;color:gray;'>Đang tải nội dung...</p>";

      fetch("ajax_chitietthongbao.jsp?id=" + id)
        .then(res => res.text())
        .then(html => { content.innerHTML = html; })
        .catch(() => {
          content.innerHTML = "<p style='text-align:center;color:red;'>Không tải được thông báo.</p>";
        });
    }
    function dongPopup() {
      document.getElementById("popupThongBao").style.display = "none";
    }
    </script>

    <style>
    .popup-overlay {
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0,0,0,0.4);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 9999;
    }
    .popup-box {
      background: #fff;
      border-radius: 14px;
      max-width: 700px;
      width: 90%;
      padding: 30px 40px;
      box-shadow: 0 8px 20px rgba(0,0,0,0.25);
      position: relative;
      animation: fadeIn 0.25s ease;
    }
    .close-btn {
      position: absolute;
      top: 12px;
      right: 12px;
      background: transparent;
      border: none;
      cursor: pointer;
      color: #444;
      font-size: 22px;
    }
    .close-btn:hover { color: #caa53f; }
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(-10px); }
      to { opacity: 1; transform: translateY(0); }
    }
    </style>
</body>
</html>

<%
    rs.close();
    ps.close();
    conn.close();
%>
