<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    // login_process.jsp
    // checks user against db, sets variables based on user type
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String userType = request.getParameter("userType");

    try {
        com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB();
        Connection con = db.getConnection();
        
        if (con == null) {
             System.out.println("Connection failed! Check DB credentials.");
             response.sendRedirect("login.jsp?error=1");
             return;
        }

        String query = "";
        String idColumn = "";
        
        // Determine which table to query based on user type
        if ("admin".equals(userType)) {
            // Query admin table
            query = "SELECT admin_id FROM admin WHERE admin_id = ? AND admin_pass = ?";
            idColumn = "admin_id";
        } else if ("customer".equals(userType)) {
            // Query customer_rep table
            query = "SELECT rep_id FROM customer_rep WHERE rep_name = ? AND password = ?";
            idColumn = "rep_id";
        } else {
            // Query USER table (default)
            query = "SELECT user_id FROM USER WHERE username = ? AND password = ?";
            idColumn = "user_id";
        }

        // Use preparedstatement to secure the query
        PreparedStatement prep_state = con.prepareStatement(query);
        prep_state.setString(1, username);
        prep_state.setString(2, password);

        ResultSet res_state = prep_state.executeQuery();

        if (res_state.next()) {
            // Successful login
            session.setAttribute("username", username);
            session.setAttribute("userType", userType);
            
            if ("admin".equals(userType)) {
                session.setAttribute("adminId", res_state.getInt(idColumn));
                response.sendRedirect("admin.jsp");
            } else if ("customer".equals(userType)) {
                session.setAttribute("repId", res_state.getInt(idColumn));
                response.sendRedirect("rep.jsp");
            } else {
                session.setAttribute("user_id", res_state.getInt(idColumn));
                response.sendRedirect("welcome.jsp");
            }
        } else {
            // Failed login
            response.sendRedirect("login.jsp?error=1");
        }
        
        res_state.close();
        prep_state.close();
        db.closeConnection(con);

    } catch (Exception e) {
        e.printStackTrace();
        // Redirection to login page with error
        response.sendRedirect("login.jsp?error=1");
    }
%>
