<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<%
    String itemId = request.getParameter("item_id");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    // Determine item category
    String categoryQuery =
      "SELECT 'SHIRT' AS cat FROM SHIRT WHERE item_id = ? " +
      "UNION SELECT 'BAG' FROM BAG WHERE item_id = ? " +
      "UNION SELECT 'SHOE' FROM SHOE WHERE item_id = ?";
    
    PreparedStatement c = con.prepareStatement(categoryQuery);
    c.setInt(1, Integer.parseInt(itemId));
    c.setInt(2, Integer.parseInt(itemId));
    c.setInt(3, Integer.parseInt(itemId));

    ResultSet catRS = c.executeQuery();

    String category = null;
    if (catRS.next()) category = catRS.getString("cat");

    String query =
      "SELECT i.item_id, i.title, i.current_bid, i.auction_end " +
      "FROM ITEM i " +
      "JOIN " + category + " s ON i.item_id = s.item_id " +
      "WHERE i.auction_start >= NOW() - INTERVAL 30 DAY " +
      "AND i.item_id <> ?";

    PreparedStatement ps = con.prepareStatement(query);
    ps.setInt(1, Integer.parseInt(itemId));
    ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Similar Items</title>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>

    <div class="navbar">
        <a href="welcome.jsp">Home</a> | 
        <a href="create_auction.jsp">Sell Item</a> | 
        <a href="browse_auctions.jsp">Browse Auctions</a> | 
        <a href="help.jsp">Help</a> |
        <a href="logout.jsp">Logout</a> |
        <a href="search.jsp">Search</a> |
	    <a href="alerts.jsp">Alerts</a>
    </div>


    <%-- Page Heading --%>
    <h2 class="page-heading">Similar Items</h2>

    <%-- Table for displaying similar items --%>
    <table class="result-table">
        <tr>
            <th>Item</th>
            <th>Current Bid</th>
            <th>Auction Ends</th>
        </tr>

        <%
        while (rs.next()) {
        %>
        <tr>
            <td><a href="item_details.jsp?item_id=<%=rs.getInt("item_id")%>">
                <%= rs.getString("title") %>
            </a></td>
            <td>$<%= rs.getBigDecimal("current_bid").setScale(2, java.math.RoundingMode.HALF_UP) %></td>
            <td><%= rs.getTimestamp("auction_end") %></td>
        </tr>
        <%
        }
        %>
    </table>

    <%
    db.closeConnection(con);
    %>

</body>
</html>
