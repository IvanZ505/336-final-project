<%@ page import="java.io.*" %>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
 <%
        // Get form parameter
        String repName = request.getParameter("rep_name");
		String password = request.getParameter("password");
		
        // Get admin ID from session
        Integer adminId = (Integer) session.getAttribute("adminId");
        
        // Database connection objects
        ApplicationDB db = new ApplicationDB();
        Connection connection = null;
        PreparedStatement pstatement = null;
        ResultSet rs = null;
        
        // Check if form was submitted
        if(repName != null && !repName.isEmpty()) {
            // Check if admin is logged in
            if(adminId == null) {
            	// adminId = 1;
                out.println("<p style='color: red;'>Error: You must be logged in as an admin to create accounts.</p>");
            }
            else {
                try {
                    // Get connection using ApplicationDB
                    connection = db.getConnection();
                    
                    // First, get the next available rep_id using MAX()
                    String maxQuery = "SELECT COALESCE(MAX(rep_id), 0) + 1 AS next_id FROM customer_rep";
                    pstatement = connection.prepareStatement(maxQuery);
                    rs = pstatement.executeQuery();
                    
                    int nextRepId = 1;
                    if(rs.next()) {
                        nextRepId = rs.getInt("next_id");
                    }
                    
                    // Close the first statement and result set
                    rs.close();
                    pstatement.close();
                    
                    // Now insert the new record
                    String insertQuery = "INSERT INTO customer_rep(rep_id, admin_id, name, rep_pass) VALUES(?, ?, ?, ?)";
                    pstatement = connection.prepareStatement(insertQuery);
                    pstatement.setInt(1, nextRepId);
                    pstatement.setInt(2, adminId);
                    pstatement.setString(3, repName);
                    pstatement.setString(4, password);
                    
                    // Execute update
                    int updateQuery = pstatement.executeUpdate();
                    
                    if (updateQuery != 0) {
    %>
                        <br>
                        <table style="background-color: #E3E4FA; margin-top: 20px;">
                            <tr><th style="color: green;">Customer representative account created successfully!</th></tr>
                            <tr><td>Representative Name: <%= repName %></td></tr>
                            <tr><td>Assigned Rep ID: <%= nextRepId %></td></tr>
                            <tr><td>Created by Admin ID: <%= adminId %></td></tr>
                        </table>
    <%
                    }
                } catch (Exception ex) {
                    out.println("<p style='color: red;'>Error: " + ex.getMessage() + "</p>");
                } finally {
                    // Close connections
                    try {
                        if(rs != null) rs.close();
                        if(pstatement != null) pstatement.close();
                        if(connection != null) db.closeConnection(connection);
                    } catch(SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    %>