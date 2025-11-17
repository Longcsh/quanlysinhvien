@echo off
echo 🔧 Đang biên dịch toàn bộ mã nguồn JSP project...
javac -encoding UTF-8 ^
-d "D:\LTUD_Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\webapps\BTL_JSP\WEB-INF\classes" ^
-cp "D:\LTUD_Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\webapps\BTL_JSP\WEB-INF\lib\*" ^
src\dao\*.java src\model\*.java src\controller\*.java src\util\*.java
echo ✅ Biên dịch hoàn tất!
pause
