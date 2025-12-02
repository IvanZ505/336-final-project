<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    // login_process.jsp
    // checks user against db, sets variables of username and user_id if success
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    try {
        com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB();
        Connection con = db.getConnection();
        
        if (con == null) {
             System.out.println("Connection failed! Check DB credentials.");
             response.sendRedirect("login.jsp?error=1");
             return;
        }

        // user preparedstatement to sercure the query
        String query = "SELECT user_id FROM USER WHERE username = ? AND password = ?";
        PreparedStatement prep_state = con.prepareStatement(query);
        prep_state.setString(1, username);
        prep_state.setString(2, password);

        ResultSet res_state = prep_state.executeQuery();

        if (res_state.next()) {
            // successful login
            session.setAttribute("username", username);
            session.setAttribute("user_id", res_state.getInt("user_id"));
            response.sendRedirect("welcome.jsp");
        } else {
            // failed login
            response.sendRedirect("login.jsp?error=1");
        }
        
        db.closeConnection(con);

    } catch (Exception e) {
        e.printStackTrace();
        // redirection to login page with error
        response.sendRedirect("login.jsp?error=1");
    }
%>
