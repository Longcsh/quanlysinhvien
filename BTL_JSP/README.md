-sau khi đổi mật khẩu kết nối db thì chạy terminal dòng dưới
javac -encoding UTF-8 -d WebContent/WEB-INF/classes -cp lib/mssql-jdbc-12.8.1.jre11.jar src/dao/DBConnection.java

- nếu lỗi 500 chạy dòng lệnh dưới ở terminal
javac -encoding UTF-8 ^
-d "D:\LTUD-Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\webapps\BTL_JSP\WEB-INF\classes" ^
-cp "D:\LTUD-Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\webapps\BTL_JSP\WEB-INF\lib\mysql-connector-j-8.0.33.jar" ^
src\dao\DBConnection.java

--src = nơi bạn viết code
--WEB-INF/classes = nơi code đã biên dịch và được Tomcat chạy


Nếu cậu thêm nhiều DAO, model, controller…
thì sửa dòng javac trong file .bat thành:

javac -encoding UTF-8 ^
-d "D:\LTUD_Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\webapps\BTL_JSP\WEB-INF\classes" ^
-cp "D:\LTUD_Java\apache-tomcat-9.0.108-windows-x64\apache-tomcat-9.0.108\webapps\BTL_JSP\WEB-INF\lib\*" ^
src\dao\*.java src\model\*.java src\controller\*.java src\util\*.java

→ Tự compile toàn bộ Java project, không cần chạy riêng từng file.