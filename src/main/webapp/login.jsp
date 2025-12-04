<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
</head>
<body>
    <div class="login-container">
        <h2>Login</h2>
        <form action="login_process.jsp" method="post">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <br>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <div class="user-type">
                <label><strong>Login as:</strong></label><br>
                <input type="radio" id="customer" name="userType" value="customer" checked>
                <label for="user">Customer</label>
                
                <input type="radio" id="customer" name="userType" value="customer_rep">
                <label for="customer">Customer Representative</label>
                
                <input type="radio" id="admin" name="userType" value="admin">
                <label for="admin">Admin</label>
            </div>
            
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