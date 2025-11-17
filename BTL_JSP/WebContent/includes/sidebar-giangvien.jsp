<%@ page pageEncoding="UTF-8" %>

<aside class="sidebar" id="sidebar">
  <div class="sidebar-header">
    <h2>👨‍🏫 Giảng Viên</h2>
    <button id="toggle-btn">☰</button>
  </div>

  <nav class="sidebar-menu">
    <a href="giangvien_dashboard.jsp" class="<%= request.getRequestURI().contains("giangvien_dashboard.jsp") ? "active" : "" %>">🏠 Trang chủ</a>
    <a href="giangvien_hocphan.jsp" class="<%= request.getRequestURI().contains("giangvien_hocphan.jsp") ? "active" : "" %>">📚 Học phần</a>
    <a href="giangvien_dssv.jsp" class="<%= request.getRequestURI().contains("giangvien_dssv.jsp") ? "active" : "" %>">👨‍🎓 Sinh viên</a>
    <a href="giangvien_chonmon.jsp" class="<%= request.getRequestURI().contains("giangvien_nhapdiem.jsp") ? "active" : "" %>">✏️ Nhập điểm</a>
    <a href="giangvien_renluyen.jsp" class="<%= request.getRequestURI().contains("giangvien_renluyen.jsp") ? "active" : "" %>">🏅 Rèn luyện</a>
    <a href="../../logout.jsp" class="logout">🚪 Đăng xuất</a>
  </nav>
</aside>

<style>
/* ===== SIDEBAR ===== */
.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  width: 230px;
  height: 100vh;
  background: linear-gradient(180deg, #002b5b 0%, #003b7a 100%);
  color: white;
  display: flex;
  flex-direction: column;
  box-shadow: 2px 0 8px rgba(0,0,0,0.15);
  transition: all 0.3s ease;
  z-index: 1000;
  overflow-y: auto;
}
.sidebar::-webkit-scrollbar {
  width: 6px;
}
.sidebar::-webkit-scrollbar-thumb {
  background: rgba(255,255,255,0.25);
  border-radius: 4px;
}

/* ===== HEADER ===== */
.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 18px 20px;
  background: #004080;
  border-bottom: 1px solid rgba(255,255,255,0.2);
}
.sidebar-header h2 {
  font-size: 17px;
  margin: 0;
  color: #fff;
  white-space: nowrap;
}
#toggle-btn {
  background: none;
  border: none;
  color: white;
  font-size: 22px;
  cursor: pointer;
  transition: transform 0.3s;
}
#toggle-btn:hover {
  transform: rotate(90deg);
}

/* ===== MENU ===== */
.sidebar-menu {
  display: flex;
  flex-direction: column;
  padding: 10px 0;
  flex-grow: 1;
}
.sidebar-menu a {
  color: #d8e4ff;
  text-decoration: none;
  padding: 12px 25px;
  display: block;
  font-size: 15px;
  transition: all 0.25s ease;
  border-left: 3px solid transparent;
}
.sidebar-menu a:hover {
  background: rgba(255,255,255,0.1);
  padding-left: 35px;
}
.sidebar-menu a.active {
  background: rgba(255,255,255,0.15);
  border-left: 3px solid #1e90ff;
  color: #fff;
  font-weight: 600;
}
.sidebar-menu .logout {
  margin-top: auto;
  color: #ffc0c0;
  background: rgba(255,255,255,0.05);
  border-top: 1px solid rgba(255,255,255,0.1);
  font-weight: 500;
}
.sidebar-menu .logout:hover {
  background: #d9534f;
  color: white;
  padding-left: 25px;
}

/* ===== THU GỌN ===== */
.sidebar.collapsed {
  width: 70px;
}
.sidebar.collapsed .sidebar-header h2 {
  display: none;
}
.sidebar.collapsed a {
  text-align: center;
  padding: 14px 0;
  font-size: 18px;
}
.sidebar.collapsed a:hover,
.sidebar.collapsed a.active {
  padding-left: 0;
}

/* ===== MAIN CONTENT ĐỒNG BỘ ===== */
.main-content {
  transition: margin-left 0.3s ease, width 0.3s ease;
}
.main-content.expand {
  margin-left: 70px !important;
  width: calc(100% - 70px) !important;
}
</style>

<script>
document.getElementById('toggle-btn').addEventListener('click', function() {
  const sidebar = document.getElementById('sidebar');
  const main = document.querySelector('.main-content');
  sidebar.classList.toggle('collapsed');
  main.classList.toggle('expand');
});
</script>
