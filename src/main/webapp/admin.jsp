<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>

    <%-- nav bar --%>
    <div class="navbar">
        <a href="admin.jsp">Dashboard</a> | 
        <a href="logout.jsp">Logout</a>
    </div>

    <%
        // Get admin ID from session
        Integer adminId = (Integer) session.getAttribute("adminId");
        
        if (adminId == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        String msg = request.getParameter("msg");
        String err = request.getParameter("err");
        if (msg != null) {
            out.println("<p style='color:green;'>" + msg + "</p>");
        }
        if (err != null) {
            out.println("<p style='color:red;'>" + err + "</p>");
        }

        // Get statistics
        int totalUsers = 0;
        int totalAuctions = 0;
        int activeAuctions = 0;
        int totalReps = 0;
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();
            
            if (con != null) {
                // Count total users
                ps = con.prepareStatement("SELECT COUNT(*) as count FROM USER");
                rs = ps.executeQuery();
                if (rs.next()) totalUsers = rs.getInt("count");
                rs.close();
                ps.close();
                
                // Count total auctions
                ps = con.prepareStatement("SELECT COUNT(*) as count FROM ITEM");
                rs = ps.executeQuery();
                if (rs.next()) totalAuctions = rs.getInt("count");
                rs.close();
                ps.close();
                
                // Count active auctions
                ps = con.prepareStatement("SELECT COUNT(*) as count FROM ITEM WHERE status = 'open' AND auction_end > NOW()");
                rs = ps.executeQuery();
                if (rs.next()) activeAuctions = rs.getInt("count");
                rs.close();
                ps.close();
                
                // Count customer reps
                ps = con.prepareStatement("SELECT COUNT(*) as count FROM CUSTOMER_REP");
                rs = ps.executeQuery();
                if (rs.next()) totalReps = rs.getInt("count");
                rs.close();
                ps.close();
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading stats: " + e.getMessage() + "</p>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ignore) {}
        }
    %>

    <div class="greeting">Admin Dashboard</div>
    <div class="stats">
        Total Users: <%= totalUsers %> | 
        Total Auctions: <%= totalAuctions %> | 
        Active Auctions: <%= activeAuctions %> | 
        Customer Reps: <%= totalReps %>
    </div>

    <!-- SECTION 1: Create Customer Representative Account -->
    <h2>Create Customer Representative Account</h2>
    
    <form action="create_account.jsp" method="post">
        <div class="form-group">
            <label>Representative Name:</label>
            <input type="text" name="rep_name" required>
        </div>
        <div class="form-group">
            <label>Password:</label>
            <input type="password" name="password" required>
        </div>
        <input type="submit" value="Create Account" class="submit-btn">
    </form>

    <!-- SECTION 2: Sales Reports -->
    <div class="section">
        <h2>Sales Reports</h2>
        
        <%
            try {
                ApplicationDB db = new ApplicationDB();
                con = db.getConnection();
                
                if (con == null) {
                    out.println("<p style='color:red;'>Unable to connect to database.</p>");
                } else {
                    // Total Earnings (sum of all closed/sold auctions)
                    String totalEarningsQuery = "SELECT SUM(current_bid) as total FROM ITEM WHERE status = 'closed' AND current_bid IS NOT NULL";
                    ps = con.prepareStatement(totalEarningsQuery);
                    rs = ps.executeQuery();
                    
                    double totalEarnings = 0;
                    if (rs.next()) {
                        totalEarnings = rs.getDouble("total");
                    }
                    rs.close();
                    ps.close();
        %>
        
        <!-- Total Earnings -->
        <div class="report-box">
            <h3>Total Earnings</h3>
            <div class="total-earnings">$<%= String.format("%.2f", totalEarnings) %></div>
            <p>From all completed auctions</p>
        </div>

        <!-- Earnings Per Item -->
        <h3>Earnings Per Item</h3>
        <table>
            <tr>
                <th>Item ID</th>
                <th>Title</th>
                <th>Seller</th>
                <th>Final Price</th>
                <th>Status</th>
            </tr>
            <%
                    String itemEarningsQuery = "SELECT i.item_id, i.title, i.current_bid, i.status, u.username " +
                                              "FROM ITEM i " +
                                              "JOIN END_USER eu ON i.seller_id = eu.user_id " +
                                              "JOIN USER u ON eu.user_id = u.user_id " +
                                              "WHERE i.status = 'closed' AND i.current_bid IS NOT NULL " +
                                              "ORDER BY i.current_bid DESC";
                    ps = con.prepareStatement(itemEarningsQuery);
                    rs = ps.executeQuery();
                    
                    boolean hasItems = false;
                    while (rs.next()) {
                        hasItems = true;
                        int itemId = rs.getInt("item_id");
                        String title = rs.getString("title");
                        double price = rs.getDouble("current_bid");
                        String status = rs.getString("status");
                        String seller = rs.getString("username");
            %>
            <tr>
                <td><%= itemId %></td>
                <td><%= title %></td>
                <td><%= seller %></td>
                <td>$<%= String.format("%.2f", price) %></td>
                <td><%= status %></td>
            </tr>
            <%
                    }
                    if (!hasItems) {
            %>
            <tr>
                <td colspan="5">No completed sales yet.</td>
            </tr>
            <%
                    }
                    rs.close();
                    ps.close();
            %>
        </table>

        <!-- Earnings Per Item Type -->
        <h3>Earnings Per Item Type</h3>
        <table>
            <tr>
                <th>Item Type</th>
                <th>Total Sales</th>
                <th>Number of Items Sold</th>
                <th>Average Price</th>
            </tr>
            <%
                    // Earnings for shirts
                    String shirtEarningsQuery = "SELECT SUM(i.current_bid) as total, COUNT(*) as count, AVG(i.current_bid) as avg " +
                                               "FROM ITEM i JOIN SHIRT s ON i.item_id = s.item_id " +
                                               "WHERE i.status = 'closed' AND i.current_bid IS NOT NULL";
                    ps = con.prepareStatement(shirtEarningsQuery);
                    rs = ps.executeQuery();
                    
                    if (rs.next()) {
                        double shirtTotal = rs.getDouble("total");
                        int shirtCount = rs.getInt("count");
                        double shirtAvg = rs.getDouble("avg");
            %>
            <tr>
                <td>Shirt</td>
                <td>$<%= String.format("%.2f", shirtTotal) %></td>
                <td><%= shirtCount %></td>
                <td>$<%= String.format("%.2f", shirtAvg) %></td>
            </tr>
            <%
                    }
                    rs.close();
                    ps.close();
                    
                    // Earnings for bags
                    String bagEarningsQuery = "SELECT SUM(i.current_bid) as total, COUNT(*) as count, AVG(i.current_bid) as avg " +
                                             "FROM ITEM i JOIN BAG b ON i.item_id = b.item_id " +
                                             "WHERE i.status = 'closed' AND i.current_bid IS NOT NULL";
                    ps = con.prepareStatement(bagEarningsQuery);
                    rs = ps.executeQuery();
                    
                    if (rs.next()) {
                        double bagTotal = rs.getDouble("total");
                        int bagCount = rs.getInt("count");
                        double bagAvg = rs.getDouble("avg");
            %>
            <tr>
                <td>Bag</td>
                <td>$<%= String.format("%.2f", bagTotal) %></td>
                <td><%= bagCount %></td>
                <td>$<%= String.format("%.2f", bagAvg) %></td>
            </tr>
            <%
                    }
                    rs.close();
                    ps.close();
                    
                    // Earnings for shoes
                    String shoeEarningsQuery = "SELECT SUM(i.current_bid) as total, COUNT(*) as count, AVG(i.current_bid) as avg " +
                                              "FROM ITEM i JOIN SHOE sh ON i.item_id = sh.item_id " +
                                              "WHERE i.status = 'closed' AND i.current_bid IS NOT NULL";
                    ps = con.prepareStatement(shoeEarningsQuery);
                    rs = ps.executeQuery();
                    
                    if (rs.next()) {
                        double shoeTotal = rs.getDouble("total");
                        int shoeCount = rs.getInt("count");
                        double shoeAvg = rs.getDouble("avg");
            %>
            <tr>
                <td>Shoe</td>
                <td>$<%= String.format("%.2f", shoeTotal) %></td>
                <td><%= shoeCount %></td>
                <td>$<%= String.format("%.2f", shoeAvg) %></td>
            </tr>
            <%
                    }
                    rs.close();
                    ps.close();
            %>
        </table>

        <!-- Earnings Per End User (Seller) -->
        <h3>Earnings Per Seller</h3>
        <table>
            <tr>
                <th>User ID</th>
                <th>Username</th>
                <th>Email</th>
                <th>Total Sales</th>
                <th>Items Sold</th>
            </tr>
            <%
                    String sellerEarningsQuery = "SELECT u.user_id, u.username, u.email, " +
                                                "SUM(i.current_bid) as total_sales, COUNT(*) as items_sold " +
                                                "FROM USER u " +
                                                "JOIN END_USER eu ON u.user_id = eu.user_id " +
                                                "JOIN ITEM i ON eu.user_id = i.seller_id " +
                                                "WHERE i.status = 'closed' AND i.current_bid IS NOT NULL " +
                                                "GROUP BY u.user_id, u.username, u.email " +
                                                "ORDER BY total_sales DESC";
                    ps = con.prepareStatement(sellerEarningsQuery);
                    rs = ps.executeQuery();
                    
                    boolean hasSellers = false;
                    while (rs.next()) {
                        hasSellers = true;
                        int userId = rs.getInt("user_id");
                        String username = rs.getString("username");
                        String email = rs.getString("email");
                        double totalSales = rs.getDouble("total_sales");
                        int itemsSold = rs.getInt("items_sold");
            %>
            <tr>
                <td><%= userId %></td>
                <td><%= username %></td>
                <td><%= email %></td>
                <td>$<%= String.format("%.2f", totalSales) %></td>
                <td><%= itemsSold %></td>
            </tr>
            <%
                    }
                    if (!hasSellers) {
            %>
            <tr>
                <td colspan="5">No seller data available.</td>
            </tr>
            <%
                    }
                    rs.close();
                    ps.close();
            %>
        </table>

        <!-- Best-Selling Items -->
        <h3>Best-Selling Items (Top 10 by Price)</h3>
        <table>
            <tr>
                <th>Rank</th>
                <th>Item ID</th>
                <th>Title</th>
                <th>Seller</th>
                <th>Final Price</th>
                <th>Number of Bids</th>
            </tr>
            <%
                    String bestItemsQuery = "SELECT i.item_id, i.title, i.current_bid, u.username, " +
                                           "COUNT(r.bid_id) as bid_count " +
                                           "FROM ITEM i " +
                                           "JOIN END_USER eu ON i.seller_id = eu.user_id " +
                                           "JOIN USER u ON eu.user_id = u.user_id " +
                                           "LEFT JOIN RECEIVES r ON i.item_id = r.item_id " +
                                           "WHERE i.status = 'closed' AND i.current_bid IS NOT NULL " +
                                           "GROUP BY i.item_id, i.title, i.current_bid, u.username " +
                                           "ORDER BY i.current_bid DESC LIMIT 10";
                    ps = con.prepareStatement(bestItemsQuery);
                    rs = ps.executeQuery();
                    
                    int rank = 1;
                    boolean hasBestItems = false;
                    while (rs.next()) {
                        hasBestItems = true;
                        int itemId = rs.getInt("item_id");
                        String title = rs.getString("title");
                        double price = rs.getDouble("current_bid");
                        String seller = rs.getString("username");
                        int bidCount = rs.getInt("bid_count");
            %>
            <tr>
                <td><%= rank++ %></td>
                <td><%= itemId %></td>
                <td><%= title %></td>
                <td><%= seller %></td>
                <td>$<%= String.format("%.2f", price) %></td>
                <td><%= bidCount %></td>
            </tr>
            <%
                    }
                    if (!hasBestItems) {
            %>
            <tr>
                <td colspan="6">No sales data available.</td>
            </tr>
            <%
                    }
                    rs.close();
                    ps.close();
            %>
        </table>

        <!-- Best Buyers -->
        <h3>Best Buyers (Top 10 by Total Spending)</h3>
        <table>
            <tr>
                <th>Rank</th>
                <th>User ID</th>
                <th>Username</th>
                <th>Email</th>
                <th>Total Spent</th>
                <th>Items Won</th>
            </tr>
            <%
                    String bestBuyersQuery = "SELECT u.user_id, u.username, u.email, " +
                                            "SUM(b.bid_amount) as total_spent, COUNT(DISTINCT i.item_id) as items_won " +
                                            "FROM USER u " +
                                            "JOIN PLACES p ON u.user_id = p.user_id " +
                                            "JOIN BID b ON p.bid_id = b.bid_id " +
                                            "JOIN RECEIVES r ON b.bid_id = r.bid_id " +
                                            "JOIN ITEM i ON r.item_id = i.item_id " +
                                            "WHERE i.status = 'closed' AND b.bid_amount = i.current_bid " +
                                            "GROUP BY u.user_id, u.username, u.email " +
                                            "ORDER BY total_spent DESC LIMIT 10";
                    ps = con.prepareStatement(bestBuyersQuery);
                    rs = ps.executeQuery();
                    
                    rank = 1;
                    boolean hasBuyers = false;
                    while (rs.next()) {
                        hasBuyers = true;
                        int userId = rs.getInt("user_id");
                        String username = rs.getString("username");
                        String email = rs.getString("email");
                        double totalSpent = rs.getDouble("total_spent");
                        int itemsWon = rs.getInt("items_won");
            %>
            <tr>
                <td><%= rank++ %></td>
                <td><%= userId %></td>
                <td><%= username %></td>
                <td><%= email %></td>
                <td>$<%= String.format("%.2f", totalSpent) %></td>
                <td><%= itemsWon %></td>
            </tr>
            <%
                    }
                    if (!hasBuyers) {
            %>
            <tr>
                <td colspan="6">No buyer data available.</td>
            </tr>
            <%
                    }
                    rs.close();
                    ps.close();
                    
                    db.closeConnection(con);
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error generating reports: " + e.getMessage() + "</p>");
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                } catch (SQLException ignore) {}
            }
        %>
    </div>

</body>
</html>
