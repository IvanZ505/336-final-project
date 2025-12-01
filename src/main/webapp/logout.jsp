<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    // invalidate session, log user out
    session.invalidate();
    
    // redirection back to login page
    response.sendRedirect("login.jsp");
%>
