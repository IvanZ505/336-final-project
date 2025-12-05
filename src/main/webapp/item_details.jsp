<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Item Details</title>
 <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
<div class="navbar">
    <a href="welcome.jsp">Home</a> | 
    <a href="create_auction.jsp">Sell Item</a> | 
    <a href="browse_auctions.jsp">Browse Auctions</a> | 
    <a href="help.jsp">Help</a> |
    <a href="search.jsp">Search</a> |
    <a href="alerts.jsp">Alerts</a> |
    <a href="logout.jsp">Logout</a>
</div>

    <%-- check if url has error or msg in it, tell the user w/ red or green messages --%>
    <% 
        String error = request.getParameter("error");
        String msg = request.getParameter("msg");
        if (error != null) out.println("<p class='error'>" + error + "</p>");
        if (msg != null) out.println("<p class='msg'>" + msg + "</p>");
    %>

<%
    // figure out item id from url, this is the one to show
    String item_id_str = request.getParameter("id");
    if (item_id_str == null) {
        out.println("<h3 class='error'>Error: No item specified.</h3>");
        return; // don't keep going if no id
    }
    int item_id = Integer.parseInt(item_id_str);

    try {
        // connect to db
        com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB();
        Connection con = db.getConnection();

        // get info abt item and seller's username
        String main_query = "SELECT i.*, u.username FROM ITEM i JOIN USER u ON i.seller_id = u.user_id WHERE item_id = ?";
        PreparedStatement prep_stat = con.prepareStatement(main_query);
        prep_stat.setInt(1, item_id); 
        ResultSet res_set = prep_stat.executeQuery();

        // item doesn't exist if no rows returned
        if (!res_set.next()) {
            out.println("<h3>Item not found.</h3>");
            return;
        }

        // get the data out
        String title = res_set.getString("title");
        String desc = res_set.getString("description");
        double curr_bid = res_set.getDouble("current_bid");
        double incr = res_set.getDouble("bid_increment");
        Timestamp end = res_set.getTimestamp("auction_end");
        String seller = res_set.getString("username");
        boolean is_open = "open".equalsIgnoreCase(res_set.getString("status"));

        // calc min allowed bid
        double minNextBid = curr_bid + incr;
%>
    <%-- show all the main info--%>
    <h2><%= title %></h2>
    
    <div class="info-box">
        <p><strong>Seller:</strong> <%= seller %></p>
        <p><strong>Current Price:</strong> $<%= String.format("%.2f", curr_bid) %></p>
        <p><strong>Closes:</strong> <%= end %></p>
        <p><strong>Description:</strong> <%= desc != null ? desc : "No description" %></p>

        <%-- dyanamic query bc subtype not known, query each table, if result found, show the details --%>
        <h3>Item Details</h3>
        <ul>
        <%
            // check shirt table
            PreparedStatement prep_statShirt = con.prepareStatement("SELECT * FROM SHIRT WHERE item_id=?");
            prep_statShirt.setInt(1, item_id);
            ResultSet res_setShirt = prep_statShirt.executeQuery();
            if (res_setShirt.next()) {
                out.println("<li><strong>Type:</strong> Shirt</li>");
                out.println("<li><strong>Brand:</strong> " + res_setShirt.getString("brand") + "</li>");
                out.println("<li><strong>Color:</strong> " + res_setShirt.getString("color") + "</li>");
                out.println("<li><strong>Size:</strong> " + res_setShirt.getString("size") + "</li>");
                out.println("<li><strong>Condition:</strong> " + res_setShirt.getString("condition") + "</li>");
            }

            // check shoe table
            PreparedStatement prep_statShoe = con.prepareStatement("SELECT * FROM SHOE WHERE item_id=?");
            prep_statShoe.setInt(1, item_id);
            ResultSet res_setShoe = prep_statShoe.executeQuery();
            if (res_setShoe.next()) {
                out.println("<li><strong>Type:</strong> Shoe</li>");
                out.println("<li><strong>Brand:</strong> " + res_setShoe.getString("brand") + "</li>");
                out.println("<li><strong>Size:</strong> " + res_setShoe.getDouble("size") + "</li>");
                out.println("<li><strong>Condition:</strong> " + res_setShoe.getString("condition") + "</li>");
            }

            // check bag table
            PreparedStatement prep_statBag = con.prepareStatement("SELECT * FROM BAG WHERE item_id=?");
            prep_statBag.setInt(1, item_id);
            ResultSet res_setBag = prep_statBag.executeQuery();
            if (res_setBag.next()) {
                out.println("<li><strong>Type:</strong> Bag</li>");
                out.println("<li><strong>Brand:</strong> " + res_setBag.getString("brand") + "</li>");
                out.println("<li><strong>Material:</strong> " + res_setBag.getString("material") + "</li>");
                out.println("<li><strong>Color:</strong> " + res_setBag.getString("color") + "</li>");
            }
        %>
        </ul>
    </div>

    <%-- bidding form, shown if auction still open, data goes to place_bid_process.jsp --%>
    <% if (is_open) { %>
        <div style="border: 2px solid #4CAF50; padding: 20px; margin-top: 20px;">
            <h3>Place a Bid</h3>
            <p>Minimum Bid Required: <strong>$<%= String.format("%.2f", minNextBid) %></strong></p>
            
            <form action="place_bid_process.jsp" method="post">
                <%-- hidden fields giving data to server --%>
                <input type="hidden" name="item_id" value="<%= item_id %>">
                <input type="hidden" name="min_bid" value="<%= minNextBid %>">
                
                <label>Your Bid ($): </label>
                <%-- 'step=0.01' allows decimals. 'min' prevents underbidding on the client side. --%>
                <input type="number" name="amount" step="0.01" min="<%= minNextBid %>" required>
                
                <br><br>
                <%-- checkbox for automatic bidding--%>
                <label>
                    <input type="checkbox" name="is_auto" value="true"> Activate Automatic Bidding?
                </label>
                <br>
                <label style="margin-left: 20px; font-size: 0.9em;">Max Limit for Auto-Bid ($): </label>
                <input type="number" name="auto_limit" step="0.01">
                
                <br><br>
                <input type="submit" value="Place Bid" style="font-size: 1.1em; padding: 5px 15px;">
            </form>
        </div>
    <% } else { %>
        <h3 class="error">This auction is closed.</h3>
    <% } %>

    <%-- bid history, highest on top --%>
    <h3>Bid History</h3>
    <table class="bid-history">
        <tr>
            <th>Bidder</th>
            <th>Amount</th>
        </tr>
        <%
            // joins to link bid amount and username
            String his_query = "SELECT b.bid_amount, u.username " +
                                  "FROM BID b " +
                                  "JOIN RECEIVES r ON b.bid_id = r.bid_id " +
                                  "JOIN PLACES p ON b.bid_id = p.bid_id " +
                                  "JOIN USER u ON p.user_id = u.user_id " +
                                  "WHERE r.item_id = ? " +
                                  "ORDER BY b.bid_amount DESC";
            
            PreparedStatement prep_statHistory = con.prepareStatement(his_query);
            prep_statHistory.setInt(1, item_id);
            ResultSet res_setHistory = prep_statHistory.executeQuery();
            
            boolean has_bids = false;
            while (res_setHistory.next()) {
                has_bids = true;
        %>
            <tr>
                <td><%= res_setHistory.getString("username") %></td>
                <td>$<%= String.format("%.2f", res_setHistory.getDouble("bid_amount")) %></td>
            </tr>
        <%
            }
            if (!has_bids) {
                out.println("<tr><td colspan='2'>No bids yet. Be the first!</td></tr>");
            }
            
            db.closeConnection(con);
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
        %>
    </table>

</body>
</html>
