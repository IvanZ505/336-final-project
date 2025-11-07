<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        String query = "SELECT * FROM USER WHERE username = ? AND password = ?";
        PreparedStatement ps = con.prepareStatement(query);
        ps.setString(1, username);
        ps.setString(2, password);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            // Login successful
            session.setAttribute("username", username);
            response.sendRedirect("welcome.jsp");
        } else {
            // Login failed
            response.sendRedirect("login.jsp?error=1");
        }
        
        db.closeConnection(con);

    } catch (Exception e) {
        e.printStackTrace();
        // Redirect to a generic error page or back to login
        response.sendRedirect("login.jsp?error=1");
    }
%>
