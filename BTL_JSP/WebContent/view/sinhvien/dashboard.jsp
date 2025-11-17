<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../db/connect.jsp" %>
<%
    Object user = session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../dangnhap.jsp");
        return;
    }

    // ✅ Lấy thông báo nổi bật
    PreparedStatement psNoiBat = conn.prepareStatement(
        "SELECT * FROM thongbao WHERE noi_bat = TRUE ORDER BY ngay_dang DESC LIMIT 1"
    );
    ResultSet rsNoiBat = psNoiBat.executeQuery();

    // ✅ Lấy 4 tin tức mới
    PreparedStatement psTinMoi = conn.prepareStatement(
        "SELECT * FROM thongbao ORDER BY ngay_dang DESC LIMIT 4"
    );
    ResultSet rsTinMoi = psTinMoi.executeQuery();

    // ✅ Lấy danh sách tất cả thông báo (mới nhất trước)
    PreparedStatement psDanhSach = conn.prepareStatement(
        "SELECT * FROM thongbao ORDER BY ngay_dang DESC"
    );
    ResultSet rsDanhSach = psDanhSach.executeQuery();
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Trang chủ | MONKEY</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/WebContent/assets/css/fix-dropdown.css">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">

    <style>
        .announcement-list {
            margin-top: 40px;
            background: #f5f7f8;
            padding: 30px;
            border-radius: 12px;
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

    <!-- SIDEBAR -->
    <nav id="sidebar" class="sidebar">
        <div class="sidebar-header">
            <a href="dashboard.jsp" class="sidebar-logo">
            </a>
            <button id="close-sidebar" class="btn-icon btn-close-sidebar">
                <span class="material-icons-outlined">close</span>
            </button>
        </div>

        <div class="sidebar-content">
            <ul class="nav-list">
                <li class="nav-item">
                    <a href="dashboard.jsp" class="nav-link active">
                        <span class="material-icons-outlined">space_dashboard</span>
                        <span>Trang chủ</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="dangky.jsp" class="nav-link">
                        <span class="material-icons-outlined">app_registration</span>
                        <span>Đăng ký tín chỉ</span>
                    </a>
                </li>

                <li class="nav-item has-submenu">
                    <a href="#" class="nav-link nav-link-toggle">
                        <span class="material-icons-outlined">bar_chart</span>
                        <span>Kết quả</span>
                        <span class="material-icons-outlined expand-icon">expand_more</span>
                    </a>
                    <ul class="submenu">
                        <li><a href="ketquahoctap.jsp">Kết quả học tập</a></li>
                        <li><a href="ketquarenluyen.jsp">Kết quả rèn luyện</a></li>
                    </ul>
                </li>

                <li class="nav-item has-submenu">
                    <a href="#" class="nav-link nav-link-toggle">
                        <span class="material-icons-outlined">feed</span>
                        <span>Thông tin</span>
                        <span class="material-icons-outlined expand-icon">expand_more</span>
                    </a>
                    <ul class="submenu">
                        <li><a href="thongtinlichhoc.jsp">Thông tin lịch học</a></li>
                        <li><a href="thongtinlichthi.jsp">Thông tin lịch thi</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </nav>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <header class="main-header">
            <div class="header-left">
                <button id="open-sidebar" class="btn-icon">
                    <span class="material-icons-outlined">menu</span>
                </button>
                <h1 class="page-title">Trang chủ</h1>
            </div>

            <div class="header-right">
                <button class="btn-icon">
                    <span class="material-icons-outlined">notifications</span>
                </button>

                <div class="user-profile">
                    <button class="user-profile-btn">
                        <img src="<%= request.getContextPath() %>/assets/images/avatar.png" alt="Avatar" class="avatar">
                        <span><%= session.getAttribute("user") %></span>
                        <span class="material-icons-outlined">expand_more</span>
                    </button>

                    <div class="user-profile-dropdown">
                        <div class="dropdown-user-info">
                            <strong><%= session.getAttribute("user") %></strong>
                            <span>Sinh viên</span>
                        </div>

                        <a href="hoso.jsp"><span class="material-icons-outlined">person</span>Xem hồ sơ</a>
                        <a href="doimatkhau.jsp"><span class="material-icons-outlined">lock</span>Đổi mật khẩu</a>
                        <hr>
                        <a href="../../logout.jsp" class="dropdown-logout">
                            <span class="material-icons-outlined">logout</span>Đăng xuất
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <!-- 🔹 Thông báo nổi bật & Tin tức mới -->
        <div class="main-announcement-grid">

            <!-- 🔸 Thông báo nổi bật -->
            <div class="featured-announcements">
                <h2 class="section-title">Thông báo nổi bật</h2>
                <section class="card featured-card">
                    <div class="featured-card-content">
                        <%
                            if (rsNoiBat.next()) {
                        %>
                            <div class="card-metadata">
                                <span><%= rsNoiBat.getString("loai") %></span>
                                <span class="dot-divider"></span>
                                <span><%= rsNoiBat.getDate("ngay_dang") %></span>
                            </div>
                            <h3 class="featured-title"><%= rsNoiBat.getString("tieu_de") %></h3>
                            <p class="featured-snippet"><%= rsNoiBat.getString("noi_dung") %></p>
                            <a href="javascript:void(0)" class="btn-primary" onclick="xemThongBao('<%= rsNoiBat.getInt("id") %>')">
                                Đọc chi tiết<span class="material-icons-outlined">arrow_forward</span>
                            </a>
                        <%
                            } else {
                                out.println("<p style='padding:10px;color:gray;'>Chưa có thông báo nổi bật.</p>");
                            }
                        %>
                    </div>
                </section>
            </div>

            <!-- 🔸 Tin tức mới -->
            <div class="recent-announcements">
                <h2 class="section-title">Tin tức mới</h2>
                <section class="card recent-card">
                    <ul class="recent-list">
                        <%
                            boolean coTin = false;
                            while (rsTinMoi.next()) {
                                coTin = true;
                        %>
                            <li>
                                <a href="javascript:void(0)" onclick="xemThongBao('<%= rsTinMoi.getInt("id") %>')">
                                    <span class="recent-title"><%= rsTinMoi.getString("tieu_de") %></span>
                                    <span class="recent-date"><%= rsTinMoi.getDate("ngay_dang") %></span>
                                </a>
                            </li>
                        <%
                            }
                            if (!coTin) out.println("<li style='color:gray;text-align:center;'>Chưa có tin tức.</li>");
                        %>
                    </ul>
                </section>
            </div>
        </div>

        <!-- 🔹 Tất cả thông báo -->
        <section class="announcement-list">
            <h2 class="section-title" style="margin-bottom: 15px;">Tất cả thông báo</h2>
            <%
                boolean coThongBao = false;
                while (rsDanhSach.next()) {
                    coThongBao = true;
            %>
                <div class="announcement-item">
                    <h3><%= rsDanhSach.getString("tieu_de") %></h3>
                    <div class="meta">
                        <b><%= rsDanhSach.getString("loai") %></b> | 
                        <%= rsDanhSach.getDate("ngay_dang") %>
                    </div>
                    <p><%= rsDanhSach.getString("noi_dung").length() > 200 
                            ? rsDanhSach.getString("noi_dung").substring(0, 200) + "..." 
                            : rsDanhSach.getString("noi_dung") %></p>
                    <a href="javascript:void(0)" onclick="xemThongBao('<%= rsDanhSach.getInt("id") %>')">Đọc chi tiết →</a>
                </div>
            <%
                }
                if (!coThongBao) out.println("<p style='text-align:center;color:gray;'>Hiện chưa có thông báo nào.</p>");
            %>
        </section>
    </main>

    <!-- POPUP -->
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

    <div id="sidebar-overlay" class="overlay"></div>
    <script src="<%= request.getContextPath() %>/WebContent/assets/js/main.js"></script>

    <script>
    function xemThongBao(id) {
      const popup = document.getElementById("popupThongBao");
      const content = document.getElementById("popupContent");
      popup.style.display = "flex";
      content.innerHTML = "<p style='text-align:center;color:gray;'>Đang tải nội dung...</p>";

      fetch("ajax_chitietthongbao.jsp?id=" + id)
        .then(res => res.text())
        .then(html => { content.innerHTML = html; })
        .catch(() => { content.innerHTML = "<p style='text-align:center;color:red;'>Không tải được thông báo.</p>"; });
    }
    function dongPopup() { document.getElementById("popupThongBao").style.display = "none"; }
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
    rsNoiBat.close();
    rsTinMoi.close();
    rsDanhSach.close();
    psNoiBat.close();
    psTinMoi.close();
    psDanhSach.close();
    conn.close();
%>
