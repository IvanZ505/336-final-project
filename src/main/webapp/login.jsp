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
    
    <br>
    <a href="register.jsp">Don't have an account? Create one here</a>
    
    <%-- show message when login fails--%>
    <% 
        String error = request.getParameter("error");
        String messge = request.getParameter("messge");
        
        if (error != null && error.equals("1")) {
            out.println("<p style='color:red;'>Invalid username or password</p>");
        }
        if (messge != null) {
            out.println("<p style='color:green;'>" + messge + "</p>");
        }
    %>
</body>
</html>
