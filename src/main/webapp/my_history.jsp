<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>History & Alerts</title>
<link rel="stylesheet" type="text/css" href="style.css">
<script>
    function confirmDeleteItem() {
        return confirm("Are you sure you want to delete this listing? This action can't be undone.");
    }
</script>
</head>
<body>
    <%-- shows the auction history of the user --%>
    <%-- includes categories of auctions the user won and the items they have or are selling --%> 

    <div class="navbar">
        <a href="welcome.jsp">Home</a> | 
        <a href="create_auction.jsp">Sell Item</a> | 
        <a href="browse_auctions.jsp">Browse Auctions</a> | 
        <a href="help.jsp">Help</a> |
        <a href="search.jsp">Search</a> |
        <a href="alerts.jsp">Alerts</a> |
        <a href="logout.jsp">Logout</a>
    </div>

    <% 
        String msg = request.getParameter("msg");
        if (msg != null) out.println("<p style='color:green; font-weight:bold;'>" + msg + "</p>");
    %>

    <h2>Won Auctions</h2>
    <table>
        <tr>
            <th>Item</th>
            <th>Final Price</th>
            <th>Seller</th>
            <th>Status</th>
        </tr>
    <%
        // validate user logged in
        if (session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        int userID = (int) session.getAttribute("user_id");
        
        try {
            // connect to db
            com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB();
            Connection con = db.getConnection();

            // looking for wins, joining on items, receives, bids, places, users
            // item closed, UID is me, bid amount matches final price, reserve met if exists
            String win_query = "SELECT i.title, i.current_bid, i.secret_min_price, u.username " +
                              "FROM ITEM i " +
                              "JOIN USER u ON i.seller_id = u.user_id " +
                              "JOIN RECEIVES r ON i.item_id = r.item_id " +
                              "JOIN BID b ON r.bid_id = b.bid_id " +
                              "JOIN PLACES p ON b.bid_id = p.bid_id " +
                              "WHERE i.auction_end < NOW() " +
                              "AND p.user_id = ? " +
                              "AND b.bid_amount = i.current_bid"; 
            
            PreparedStatement ps_wins = con.prepareStatement(win_query);
            ps_wins.setInt(1, userID);
            ResultSet res_set = ps_wins.executeQuery();

            boolean hasWins = false;
            while (res_set.next()) {
                String title = res_set.getString("title");
                double price = res_set.getDouble("current_bid");
                double reserve = res_set.getDouble("secret_min_price");
                String seller = res_set.getString("username");
                boolean reserveMet = (reserve == 0 || price >= reserve);
                
                if (reserveMet) {
                    hasWins = true;
    %>
        <tr>
            <td><%= title %></td>
            <td>$<%= String.format("%.2f", price) %></td>
            <td><%= seller %></td>
            <td>
                <span class="win">WINNER</span>
            </td>
        </tr>
    <%
                }
            }
            if (!hasWins) out.println("<tr><td colspan='4'>No wins yet.</td></tr>");
    %>
    </table>


    <h2>Currently Selling (Active & Finished)</h2>
    <table>
        <tr>
            <th>Item</th>
            <th>Current/Final Price</th>
            <th>Winner / Status</th>
            <th>Action</th>
        </tr>
    <%
        // querying to find active and sold items, show all 
        String soldQuery = "SELECT i.item_id, i.title, i.current_bid, i.secret_min_price, i.auction_end, " +
                           "(SELECT u2.username FROM USER u2 JOIN PLACES p ON u2.user_id = p.user_id JOIN RECEIVES r ON p.bid_id = r.bid_id JOIN BID b ON r.bid_id = b.bid_id WHERE r.item_id = i.item_id AND b.bid_amount = i.current_bid LIMIT 1) as winner_name " +
                           "FROM ITEM i WHERE i.seller_id = ? ORDER BY i.auction_end DESC";

        PreparedStatement ps_sold = con.prepareStatement(soldQuery);
        ps_sold.setInt(1, userID);
        ResultSet rs_sold = ps_sold.executeQuery();
        
        boolean hasSold = false;
        while (rs_sold.next()) {
            hasSold = true;
            int itemId = rs_sold.getInt("item_id");
            String title = rs_sold.getString("title");
            double price = rs_sold.getDouble("current_bid");
            double reserve = rs_sold.getDouble("secret_min_price");
            Timestamp end = rs_sold.getTimestamp("auction_end");
            String winner = rs_sold.getString("winner_name");
            
            boolean isExpired = end.before(new Timestamp(System.currentTimeMillis()));
            boolean reserveMet = (reserve == 0 || price >= reserve);
            
            // setting status text
            String statusText = "";
            String statusClass = "";
            
            if (!isExpired) {
                statusText = "Active (Ends: " + end + ")";
                statusClass = "win"; // Reusing green for active
            } else {
                if (winner == null) {
                    statusText = "Unsold (No Bids)";
                    statusClass = "loss";
                } else if (reserveMet) {
                    statusText = "SOLD to " + winner;
                    statusClass = "win";
                } else {
                    statusText = "Reserve Not Met (High Bidder: " + winner + ")";
                    statusClass = "reserve-fail";
                }
            }
    %>
        <tr>
            <td><%= title %></td>
            <td>$<%= String.format("%.2f", price) %></td>
            <td><span class="<%= statusClass %>"><%= statusText %></span></td>
            <td>
                <%-- the delete button --%>
                <form action="delete_item_process.jsp" method="post" onsubmit="return confirmDeleteItem()">
                    <input type="hidden" name="item_id" value="<%= itemId %>">
                    <input type="submit" value="Delete" class="delete-btn">
                </form>
            </td>
        </tr>
    <%
        }
        if (!hasSold) out.println("<tr><td colspan='4'>Nothing sold yet</td></tr>");

        db.closeConnection(con);
        } catch (Exception e) {
            e.printStackTrace();
        }
    %>
    </table>

</body>
</html>
