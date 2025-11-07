<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Welcome</title>
</head>
<body>

<%
    // Check if the user is logged in
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
    } else {
        String username = (String) session.getAttribute("username");
%>
    <h2>Welcome, <%= username %>!</h2>
    <p>You have successfully logged in.</p>
    
    <a href="logout.jsp">Logout</a>
<%
    }
%>

</body>
</html>
