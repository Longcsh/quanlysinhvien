<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="layout-container">

    <!-- SIDEBAR -->
    <nav id="sidebar" class="sidebar">
        <div class="sidebar-header">
            <a href="dashboard.jsp" class="sidebar-logo">
            </a>
        </div>

        <div class="sidebar-content">
            <ul class="nav-list">
                <li class="nav-item"><a href="dashboard.jsp" class="nav-link"><span class="material-icons-outlined">space_dashboard</span>Trang chủ</a></li>
                <li class="nav-item"><a href="dangky.jsp" class="nav-link"><span class="material-icons-outlined">app_registration</span>Đăng ký tín chỉ</a></li>

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

</div>
