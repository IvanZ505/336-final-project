<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
</head>
<body>
    <h2>Login</h2>
    <form action="login_process.jsp" method="post">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required><br><br>
        
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required><br><br>
        
        <input type="submit" value="Login">
    </form>
    
    <%-- Display a message if login failed --%>
    <% 
        String error = request.getParameter("error");
        if (error != null && error.equals("1")) {
            out.println("<p style='color:red;'>Invalid username or password.</p>");
        }
    %>
</body>
</html>
