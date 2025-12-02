<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Register</title>
</head>
<body>
    <h2>Create an Account</h2>
    <form action="register_process.jsp" method="post">
        <label>Username:</label>
        <input type="text" name="username" required><br><br>
        
        <label>Password:</label>
        <input type="password" name="password" required><br><br>
        
        <label>Full Name:</label>
        <input type="text" name="name" required><br><br>
        
        <label>Email:</label>
        <input type="email" name="email" required><br><br>
        
        <label>Address:</label>
        <input type="text" name="address" required><br><br>
        
        <input type="submit" value="Register">
    </form>
    
    <br>
    <a href="login.jsp">Already have an account? Login</a>
</body>
</html>

