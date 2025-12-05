<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    body {
        font-family: 'Arial', sans-serif;
        background: linear-gradient(135deg, #1e1e1e 0%, #2d2d2d 100%);
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        color: #ffffff;
    }
    
    .login-container {
        max-width: 500px;
        width: 90%;
        padding: 50px 40px;
        text-align: center;
    }
    
    h2 {
        font-size: 36px;
        font-weight: bold;
        letter-spacing: 3px;
        text-transform: uppercase;
        margin-bottom: 50px;
        color: #ffffff;
    }
    
    .form-group {
        margin-bottom: 30px;
        position: relative;
    }
    
    label {
        display: none;
    }
    
    input[type="text"],
    input[type="password"] {
        width: 100%;
        padding: 15px 0;
        background: transparent;
        border: none;
        border-bottom: 2px solid rgba(255, 255, 255, 0.3);
        color: #ffffff;
        font-size: 16px;
        outline: none;
        transition: border-color 0.3s ease;
    }
    
    input[type="text"]::placeholder,
    input[type="password"]::placeholder {
        color: rgba(255, 255, 255, 0.5);
    }
    
    input[type="text"]:focus,
    input[type="password"]:focus {
        border-bottom-color: #ffffff;
    }
    
    .user-type {
        margin: 30px 0 40px 0;
        text-align: left;
    }
    
    .user-type label {
        display: inline-block;
        color: rgba(255, 255, 255, 0.7);
        font-size: 14px;
        margin-right: 15px;
        cursor: pointer;
        transition: color 0.3s ease;
    }
    
    .user-type label:first-child {
        display: block;
        font-weight: bold;
        margin-bottom: 15px;
        color: #ffffff;
    }
    
    .user-type input[type="radio"] {
        margin-right: 8px;
        cursor: pointer;
    }
    
    .user-type label:hover {
        color: #ffffff;
    }
    
    input[type="submit"] {
        width: 100%;
        max-width: 200px;
        padding: 15px 40px;
        background: transparent;
        color: #ffffff;
        border: 2px solid #ffffff;
        border-radius: 50px;
        font-size: 16px;
        font-weight: bold;
        letter-spacing: 2px;
        text-transform: uppercase;
        cursor: pointer;
        transition: all 0.3s ease;
        margin-top: 20px;
    }
    
    input[type="submit"]:hover {
        background: #ffffff;
        color: #2d2d2d;
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(255, 255, 255, 0.3);
    }
    
    a {
        color: rgba(255, 255, 255, 0.7);
        text-decoration: none;
        font-size: 14px;
        display: inline-block;
        margin-top: 30px;
        transition: color 0.3s ease;
    }
    
    a:hover {
        color: #ffffff;
    }
    
    p {
        margin-top: 20px;
        font-size: 14px;
    }
    
    p[style*="color:red"] {
        color: #ff6b6b !important;
        background: rgba(255, 107, 107, 0.1);
        padding: 10px;
        border-radius: 5px;
        border-left: 3px solid #ff6b6b;
    }
    
    p[style*="color:green"] {
        color: #51cf66 !important;
        background: rgba(81, 207, 102, 0.1);
        padding: 10px;
        border-radius: 5px;
        border-left: 3px solid #51cf66;
    }
</style>

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