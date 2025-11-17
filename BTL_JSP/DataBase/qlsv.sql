-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th10 22, 2025 lúc 03:40 AM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `qlsv`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dangkyhocphan`
--

CREATE TABLE `dangkyhocphan` (
  `MaSV` varchar(10) NOT NULL,
  `MaHP` varchar(10) NOT NULL,
  `NgayDangKy` date DEFAULT curdate()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `diem`
--

CREATE TABLE `diem` (
  `Id` int(11) NOT NULL,
  `MaSV` varchar(10) DEFAULT NULL,
  `MaMon` varchar(10) DEFAULT NULL,
  `DiemCC` float DEFAULT NULL,
  `DiemGK` float DEFAULT NULL,
  `DiemCK` float DEFAULT NULL,
  `DiemTB` float GENERATED ALWAYS AS (round(`DiemCC` * 0.1 + `DiemGK` * 0.3 + `DiemCK` * 0.6,2)) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `diemrenluyen`
--

CREATE TABLE `diemrenluyen` (
  `Id` int(11) NOT NULL,
  `MaSV` varchar(10) NOT NULL,
  `HocKy` int(11) NOT NULL,
  `NamHoc` varchar(20) NOT NULL,
  `Diem` int(11) DEFAULT NULL CHECK (`Diem` between 0 and 100),
  `XepLoai` varchar(20) DEFAULT NULL,
  `NhanXet` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `giangvien`
--

CREATE TABLE `giangvien` (
  `MaGV` varchar(10) NOT NULL,
  `HoTen` varchar(100) DEFAULT NULL,
  `NgaySinh` date DEFAULT NULL,
  `GioiTinh` varchar(5) DEFAULT NULL,
  `ChuyenMon` varchar(100) DEFAULT NULL,
  `MaKhoa` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `hocphan`
--

CREATE TABLE `hocphan` (
  `MaHP` varchar(10) NOT NULL,
  `MaMon` varchar(10) NOT NULL,
  `MaGV` varchar(10) NOT NULL,
  `HocKy` int(11) NOT NULL,
  `NamHoc` varchar(20) NOT NULL,
  `Nhom` varchar(5) DEFAULT NULL,
  `PhongHoc` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `khoa`
--

CREATE TABLE `khoa` (
  `MaKhoa` varchar(5) NOT NULL,
  `TenKhoa` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `lop`
--

CREATE TABLE `lop` (
  `MaLop` varchar(10) NOT NULL,
  `TenLop` varchar(100) NOT NULL,
  `MaKhoa` varchar(5) DEFAULT NULL,
  `CoVanID` varchar(10) DEFAULT NULL,
  `NienKhoa` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `monhoc`
--

CREATE TABLE `monhoc` (
  `MaMon` varchar(10) NOT NULL,
  `TenMon` varchar(100) NOT NULL,
  `SoTinChi` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nguoidung`
--

CREATE TABLE `nguoidung` (
  `Id` int(11) NOT NULL,
  `TenDangNhap` varchar(50) DEFAULT NULL,
  `MatKhau` varchar(255) NOT NULL,
  `VaiTro` int(11) NOT NULL,
  `MaThamChieu` varchar(10) DEFAULT NULL,
  `TrangThai` tinyint(1) DEFAULT 1,
  `NgayTao` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `sinhvien`
--

CREATE TABLE `sinhvien` (
  `MaSV` varchar(10) NOT NULL,
  `HoTen` varchar(100) DEFAULT NULL,
  `NgaySinh` date DEFAULT NULL,
  `GioiTinh` varchar(5) DEFAULT NULL,
  `DiaChi` varchar(200) DEFAULT NULL,
  `SoDT` varchar(15) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `MaLop` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `v_diemsinhvien`
-- (See below for the actual view)
--
CREATE TABLE `v_diemsinhvien` (
`MaSV` varchar(10)
,`TenSinhVien` varchar(100)
,`MaMon` varchar(10)
,`TenMon` varchar(100)
,`DiemCC` float
,`DiemGK` float
,`DiemCK` float
,`DiemTB` float
,`DiemChu` varchar(1)
,`XepLoai` varchar(10)
);

-- --------------------------------------------------------

--
-- Cấu trúc cho view `v_diemsinhvien`
--
DROP TABLE IF EXISTS `v_diemsinhvien`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_diemsinhvien`  AS SELECT `d`.`MaSV` AS `MaSV`, `sv`.`HoTen` AS `TenSinhVien`, `d`.`MaMon` AS `MaMon`, `m`.`TenMon` AS `TenMon`, `d`.`DiemCC` AS `DiemCC`, `d`.`DiemGK` AS `DiemGK`, `d`.`DiemCK` AS `DiemCK`, `d`.`DiemTB` AS `DiemTB`, CASE WHEN `d`.`DiemTB` >= 8.5 THEN 'A' WHEN `d`.`DiemTB` >= 7.0 THEN 'B' WHEN `d`.`DiemTB` >= 5.5 THEN 'C' WHEN `d`.`DiemTB` >= 4.0 THEN 'D' ELSE 'F' END AS `DiemChu`, CASE WHEN `d`.`DiemTB` >= 8.5 THEN 'Giỏi' WHEN `d`.`DiemTB` >= 7.0 THEN 'Khá' WHEN `d`.`DiemTB` >= 5.5 THEN 'Trung bình' WHEN `d`.`DiemTB` >= 4.0 THEN 'Yếu' ELSE 'Kém' END AS `XepLoai` FROM ((`diem` `d` join `sinhvien` `sv` on(`d`.`MaSV` = `sv`.`MaSV`)) join `monhoc` `m` on(`d`.`MaMon` = `m`.`MaMon`)) ;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `dangkyhocphan`
--
ALTER TABLE `dangkyhocphan`
  ADD PRIMARY KEY (`MaSV`,`MaHP`),
  ADD KEY `MaHP` (`MaHP`);

--
-- Chỉ mục cho bảng `diem`
--
ALTER TABLE `diem`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `MaSV` (`MaSV`),
  ADD KEY `MaMon` (`MaMon`);

--
-- Chỉ mục cho bảng `diemrenluyen`
--
ALTER TABLE `diemrenluyen`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `MaSV` (`MaSV`);

--
-- Chỉ mục cho bảng `giangvien`
--
ALTER TABLE `giangvien`
  ADD PRIMARY KEY (`MaGV`),
  ADD KEY `MaKhoa` (`MaKhoa`);

--
-- Chỉ mục cho bảng `hocphan`
--
ALTER TABLE `hocphan`
  ADD PRIMARY KEY (`MaHP`),
  ADD KEY `MaGV` (`MaGV`),
  ADD KEY `MaMon` (`MaMon`);

--
-- Chỉ mục cho bảng `khoa`
--
ALTER TABLE `khoa`
  ADD PRIMARY KEY (`MaKhoa`);

--
-- Chỉ mục cho bảng `lop`
--
ALTER TABLE `lop`
  ADD PRIMARY KEY (`MaLop`),
  ADD KEY `MaKhoa` (`MaKhoa`),
  ADD KEY `CoVanID` (`CoVanID`);

--
-- Chỉ mục cho bảng `monhoc`
--
ALTER TABLE `monhoc`
  ADD PRIMARY KEY (`MaMon`);

--
-- Chỉ mục cho bảng `nguoidung`
--
ALTER TABLE `nguoidung`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `TenDangNhap` (`TenDangNhap`);

--
-- Chỉ mục cho bảng `sinhvien`
--
ALTER TABLE `sinhvien`
  ADD PRIMARY KEY (`MaSV`),
  ADD KEY `MaLop` (`MaLop`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `diem`
--
ALTER TABLE `diem`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `diemrenluyen`
--
ALTER TABLE `diemrenluyen`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `nguoidung`
--
ALTER TABLE `nguoidung`
  MODIFY `Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `dangkyhocphan`
--
ALTER TABLE `dangkyhocphan`
  ADD CONSTRAINT `dangkyhocphan_ibfk_1` FOREIGN KEY (`MaSV`) REFERENCES `sinhvien` (`MaSV`),
  ADD CONSTRAINT `dangkyhocphan_ibfk_2` FOREIGN KEY (`MaHP`) REFERENCES `hocphan` (`MaHP`);

--
-- Các ràng buộc cho bảng `diem`
--
ALTER TABLE `diem`
  ADD CONSTRAINT `diem_ibfk_1` FOREIGN KEY (`MaSV`) REFERENCES `sinhvien` (`MaSV`),
  ADD CONSTRAINT `diem_ibfk_2` FOREIGN KEY (`MaMon`) REFERENCES `monhoc` (`MaMon`);

--
-- Các ràng buộc cho bảng `diemrenluyen`
--
ALTER TABLE `diemrenluyen`
  ADD CONSTRAINT `diemrenluyen_ibfk_1` FOREIGN KEY (`MaSV`) REFERENCES `sinhvien` (`MaSV`);

--
-- Các ràng buộc cho bảng `giangvien`
--
ALTER TABLE `giangvien`
  ADD CONSTRAINT `giangvien_ibfk_1` FOREIGN KEY (`MaKhoa`) REFERENCES `khoa` (`MaKhoa`);

--
-- Các ràng buộc cho bảng `hocphan`
--
ALTER TABLE `hocphan`
  ADD CONSTRAINT `hocphan_ibfk_1` FOREIGN KEY (`MaGV`) REFERENCES `giangvien` (`MaGV`),
  ADD CONSTRAINT `hocphan_ibfk_2` FOREIGN KEY (`MaMon`) REFERENCES `monhoc` (`MaMon`);

--
-- Các ràng buộc cho bảng `lop`
--
ALTER TABLE `lop`
  ADD CONSTRAINT `lop_ibfk_1` FOREIGN KEY (`MaKhoa`) REFERENCES `khoa` (`MaKhoa`),
  ADD CONSTRAINT `lop_ibfk_2` FOREIGN KEY (`CoVanID`) REFERENCES `giangvien` (`MaGV`);

--
-- Các ràng buộc cho bảng `sinhvien`
--
ALTER TABLE `sinhvien`
  ADD CONSTRAINT `sinhvien_ibfk_1` FOREIGN KEY (`MaLop`) REFERENCES `lop` (`MaLop`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
