<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit User</title>
<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <%-- nav bar --%>
	<div class="navbar">
	    <a href="welcome.jsp">Home</a> | 
	    <a href="create_auction.jsp">Sell Item</a> | 
	    <a href="browse_auctions.jsp">Browse Auctions</a> | 
	    <a href="help.jsp">Help</a> |
	    <a href="search.jsp">Search</a> |
	    <a href="alerts.jsp">Alerts</a> |
	    <a href="logout.jsp">Logout</a>
	</div>

    <h2>Edit User Account</h2>
    
    <%
        Integer repId = (Integer) session.getAttribute("repId");
        if (repId == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("user_id"));
        
        if (request.getMethod().equals("POST")) {
            // Handle update
            String username = request.getParameter("username");
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String address = request.getParameter("address");
            String newPassword = request.getParameter("password");
            String isActiveStr = request.getParameter("is_active");
            boolean isActive = "1".equals(isActiveStr);
            
            try {
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();
                
                String sql;
                PreparedStatement ps;
                
                // Check if password should be updated
                if (newPassword != null && !newPassword.trim().isEmpty()) {
                    // Update with new password
                    sql = "UPDATE USER SET username = ?, name = ?, email = ?, address = ?, is_active = ?, password = ? WHERE user_id = ?";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, username);
                    ps.setString(2, name);
                    ps.setString(3, email);
                    ps.setString(4, address);
                    ps.setBoolean(5, isActive);
                    ps.setString(6, newPassword);
                    ps.setInt(7, userId);
                } else {
                    // Update without changing password
                    sql = "UPDATE USER SET username = ?, name = ?, email = ?, address = ?, is_active = ? WHERE user_id = ?";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, username);
                    ps.setString(2, name);
                    ps.setString(3, email);
                    ps.setString(4, address);
                    ps.setBoolean(5, isActive);
                    ps.setInt(6, userId);
                }
                
                ps.executeUpdate();
                db.closeConnection(con);
                
                response.sendRedirect("manage_users.jsp?msg=User+updated+successfully");
                return;
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
            }
        }
        
        // Load user data
        try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();
            
            String sql = "SELECT * FROM USER WHERE user_id = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                String username = rs.getString("username");
                String name = rs.getString("name");
                String email = rs.getString("email");
                String address = rs.getString("address");
                boolean isActive = rs.getBoolean("is_active");
                String currentPassword = rs.getString("password");
    %>
    
    <form method="post">
        <div class="form-group">
            <label>User ID:</label>
            <input type="text" value="<%= userId %>" disabled>
            <div class="help-text">User ID cannot be changed</div>
        </div>
        
        <div class="form-group">
            <label>Username: *</label>
            <input type="text" name="username" value="<%= username %>" required>
        </div>
        
        <div class="form-group">
            <label>Name:</label>
            <input type="text" name="name" value="<%= name != null ? name : "" %>">
        </div>
        
        <div class="form-group">
            <label>Email: *</label>
            <input type="email" name="email" value="<%= email %>" required>
        </div>
        
        <div class="form-group">
            <label>Address:</label>
            <input type="text" name="address" value="<%= address != null ? address : "" %>">
        </div>
        
        <div class="form-group">
            <label>New Password:</label>
            <input type="password" name="password" placeholder="Leave blank to keep current password">
            <div class="help-text">Current password: <%= currentPassword %></div>
            <div class="help-text">Only fill this field if you want to change the password</div>
        </div>
        
        <div class="form-group">
            <label>Active Status: *</label>
            <select name="is_active">
                <option value="1" <%= isActive ? "selected" : "" %>>Active (Yes)</option>
                <option value="0" <%= !isActive ? "selected" : "" %>>Inactive (No)</option>
            </select>
        </div>
        
        <button type="submit" class="submit-btn">Update User</button>
        <a href="manage_users.jsp" class="cancel-btn">Cancel</a>
    </form>
    
    <%
            } else {
                out.println("<p style='color:red;'>User not found.</p>");
            }
            db.closeConnection(con);
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        }
    %>
</body>
</html>
