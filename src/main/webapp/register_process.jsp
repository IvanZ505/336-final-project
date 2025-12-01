<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    // register_process.jsp
    // deals with user registration, puts into user tabe, puts in end user table, logs in user automatically

    String user = request.getParameter("username");
    String pass = request.getParameter("password");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String addre = request.getParameter("address");

    Connection con = null;
    com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB(); // DB instance declared outside try block
    
    try {
        con = db.getConnection();
        con.setAutoCommit(false); // Transaction start

        // puttint into generic user table
        String insert_usr = "INSERT INTO USER (username, password, name, email, address) VALUES (?, ?, ?, ?, ?)";
        PreparedStatement prep_state = con.prepareStatement(insert_usr, Statement.RETURN_GENERATED_KEYS);
        prep_state.setString(1, user);
        prep_state.setString(2, pass);
        prep_state.setString(3, name);
        prep_state.setString(4, email);
        prep_state.setString(5, addre);
        
        int rows = prep_state.executeUpdate();
        if (rows == 0) throw new SQLException("Registration failed.");

        // get back auto gen user id 
        int userID = -1;
        ResultSet rs = prep_state.getGeneratedKeys();
        if (rs.next()) {
            userID = rs.getInt(1);
        } else {
            throw new SQLException("Registration failed, no ID obtained.");
        }

        // put into end user table
        String insert_end_usr = "INSERT INTO END_USER (user_id) VALUES (?)";
        PreparedStatement prep_stateEU = con.prepareStatement(insert_end_usr);
        prep_stateEU.setInt(1, userID);
        prep_stateEU.executeUpdate();

        con.commit(); // commit the transaction
        
        // log in automatically
        session.setAttribute("username", user);
        session.setAttribute("user_id", userID);
        response.sendRedirect("welcome.jsp");

    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (SQLException ex) {} // if error encountered, rollback
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    } finally {
        if (con != null) db.closeConnection(con);
    }
%>
