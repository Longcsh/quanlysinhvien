@echo off
title 🧱 JSP Auto Rebuild & Restart
echo --------------------------------------------
echo 🚧  Bắt đầu biên dịch lại file Java...
echo --------------------------------------------

javac -encoding UTF-8 ^
-d "E:\LTUD-Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\webapps\BTL_JSP\WEB-INF\classes" ^
-cp "E:\LTUD-Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\webapps\BTL_JSP\WEB-INF\lib\mysql-connector-j-8.0.33.jar" ^
src\dao\DBConnection.java

echo --------------------------------------------
echo 🧹  Xoá cache cũ của Tomcat...
echo --------------------------------------------
rd /s /q "E:\LTUD-Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\work\Catalina\localhost\BTL_JSP" >nul 2>&1
rd /s /q "E:\LTUD-Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\temp" >nul 2>&1

echo --------------------------------------------
echo 🛑  Dừng Tomcat...
echo --------------------------------------------
E:\LTUD-Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\bin\shutdown.bat
timeout /t 2 >nul

echo --------------------------------------------
echo 🚀  Khởi động lại Tomcat...
echo --------------------------------------------
E:\LTUD-Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\bin\startup.bat

echo --------------------------------------------
echo ✅  Hoàn tất! Giờ mở lại trình duyệt và F5.
echo --------------------------------------------
pause
