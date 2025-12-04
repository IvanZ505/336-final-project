<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Users</title>
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 50px;
    }
    table { 
        width: 100%; 
        border-collapse: collapse; 
        margin-top: 20px; 
    }
    th, td { 
        padding: 10px; 
        border: 1px solid #ddd; 
        text-align: left; 
    }
    tr:nth-child(even) { 
        background-color: #f2f2f2; 
    }
    th { 
        background-color: #4CAF50; 
        color: white; 
    }
    .submit-btn {
        background-color: #4CAF50;
        color: white;
        padding: 8px 15px;
        border: none;
        cursor: pointer;
        margin-top: 10px;
    }
    .submit-btn:hover {
        background-color: #45a049;
    }
    .delete-btn {
        background-color: #f44336;
        color: white;
        padding: 8px 15px;
        border: none;
        cursor: pointer;
    }
    .delete-btn:hover {
        background-color: #da190b;
    }
    .edit-btn {
        background-color: #2196F3;
        color: white;
        padding: 8px 15px;
        border: none;
        cursor: pointer;
    }
    .edit-btn:hover {
        background-color: #0b7dda;
    }
    input[type="text"], input[type="email"] {
        padding: 8px;
        width: 250px;
    }
    .search-section {
        background-color: #f9f9f9;
        padding: 20px;
        border-radius: 5px;
        margin-bottom: 30px;
    }
</style>
</head>
<body>

    <%-- nav bar --%>
    <div style="background: #eee; padding: 10px; margin-bottom: 20px;">
        <a href="rep.jsp">Dashboard</a> | 
        <a href="answer_questions.jsp">Answer Questions</a> | 
        <a href="manage_users.jsp">Manage Users</a> |
        <a href="manage_bids.jsp">Manage Bids</a> |
        <a href="manage_auctions.jsp">Manage Auctions</a> |
        <a href="logout.jsp">Logout</a>
    </div>

    <%
        // Get rep ID from session
        Integer repId = (Integer) session.getAttribute("repId");
        
        if (repId == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }
     // Handle delete request
        String deleteUserIdStr = request.getParameter("delete_user_id");
        if (deleteUserIdStr != null && !deleteUserIdStr.trim().isEmpty()) {
            int deleteUserId = Integer.parseInt(deleteUserIdStr);
            
            Connection delCon = null;
            PreparedStatement delPs = null;
            
            try {
                ApplicationDB db = new ApplicationDB();
                delCon = db.getConnection();
                
                // Delete from USER (CASCADE will handle related records)
                String deleteSql = "DELETE FROM USER WHERE user_id = ?";
                delPs = delCon.prepareStatement(deleteSql);
                delPs.setInt(1, deleteUserId);
                
                int rows = delPs.executeUpdate();
                db.closeConnection(delCon);
                
                if (rows > 0) {
                    response.sendRedirect("manage_users.jsp?msg=User+deleted+successfully");
                } else {
                    response.sendRedirect("manage_users.jsp?err=Failed+to+delete+user");
                }
                return;
            } catch (Exception e) {
                response.sendRedirect("manage_users.jsp?err=" + e.getMessage());
                return;
            } finally {
                try {
                    if (delPs != null) delPs.close();
                } catch (SQLException ignore) {}
            }
        }

        String msg = request.getParameter("msg");
        String err = request.getParameter("err");
        if (msg != null) {
            out.println("<p style='color:green;'>" + msg + "</p>");
        }
        if (err != null) {
            out.println("<p style='color:red;'>" + err + "</p>");
        }
    %>

    <h2>Manage User Accounts</h2>

    <div class="search-section">
        <h3>Search Users</h3>
        <p>Enter a username or email to find user accounts.</p>
        
        <form action="manage_users.jsp" method="get">
            <input type="text" name="search_user" placeholder="Enter username or email" 
                   value="<%= request.getParameter("search_user") != null ? request.getParameter("search_user") : "" %>">
            <input type="submit" value="Search" class="submit-btn">
            <% if (request.getParameter("search_user") != null) { %>
                <a href="manage_users.jsp"><button type="button" class="submit-btn">Clear Search</button></a>
            <% } %>
        </form>
    </div>

    <%
        String searchUser = request.getParameter("search_user");
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        // Show all users if no search, otherwise show search results
        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();
            
            if (con == null) {
                out.println("<p style='color:red;'>Unable to connect to database.</p>");
            } else {
                String userQuery;
                
                if (searchUser != null && !searchUser.trim().isEmpty()) {
                    // Search mode
                    userQuery = "SELECT user_id, username, name, email, address, is_active " +
                              "FROM USER " +
                              "WHERE username LIKE ? OR email LIKE ? " +
                              "ORDER BY user_id";
                    ps = con.prepareStatement(userQuery);
                    ps.setString(1, "%" + searchUser + "%");
                    ps.setString(2, "%" + searchUser + "%");
                } else {
                    // Show all users
                    userQuery = "SELECT user_id, username, name, email, address, is_active " +
                              "FROM USER " +
                              "ORDER BY user_id";
                    ps = con.prepareStatement(userQuery);
                }
                
                rs = ps.executeQuery();
    %>
    
    <h3><%= searchUser != null && !searchUser.trim().isEmpty() ? "Search Results" : "All Users" %></h3>
    
    <table>
        <tr>
            <th>User ID</th>
            <th>Username</th>
            <th>Name</th>
            <th>Email</th>
            <th>Address</th>
            <th>Active</th>
            <th>Actions</th>
        </tr>
        
        <%
                boolean found = false;
                while (rs.next()) {
                    found = true;
                    int userId = rs.getInt("user_id");
                    String username = rs.getString("username");
                    String name = rs.getString("name");
                    String email = rs.getString("email");
                    String address = rs.getString("address");
                    boolean isActive = rs.getBoolean("is_active");
        %>
        <tr>
            <td><%= userId %></td>
            <td><%= username %></td>
            <td><%= name != null ? name : "N/A" %></td>
            <td><%= email %></td>
            <td><%= address != null ? address : "N/A" %></td>
            <td><%= isActive ? "Yes" : "No" %></td>
            <td>
                <a href="edit_user.jsp?user_id=<%= userId %>"><button class="edit-btn">Edit</button></a>
                <form action="manage_users.jsp" method="post" style="display:inline;" 
				      onsubmit="return confirm('Are you sure you want to delete user <%= username %>? This will delete all their auctions, bids, and related data.');">
				    <input type="hidden" name="delete_user_id" value="<%= userId %>">
				    <input type="submit" value="Delete" class="delete-btn">
				</form>

            </td>
        </tr>
        <%
                }
                
                if (!found) {
                    if (searchUser != null && !searchUser.trim().isEmpty()) {
                        out.println("<tr><td colspan='7'>No users found matching your search criteria.</td></tr>");
                    } else {
                        out.println("<tr><td colspan='7'>No users in the database.</td></tr>");
                    }
                }
        %>
    </table>
    
    <%
                db.closeConnection(con);
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ignore) {}
        }
    %>

</body>
</html>
