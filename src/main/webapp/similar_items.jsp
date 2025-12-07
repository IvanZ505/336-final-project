<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<%
String itemId = request.getParameter("item_id");

ApplicationDB db = new ApplicationDB();
Connection con = db.getConnection();

// Determine category SAFELY
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

if (category == null) {
    out.println("<p>No similar items found.</p>");
    return;
}

String query =
  "SELECT i.item_id, i.title, i.current_bid, i.auction_end, i.status, u.username " +
  "FROM ITEM i " +
  "JOIN " + category + " s ON i.item_id = s.item_id " +
  "JOIN USER u ON i.seller_id = u.user_id " +
  "WHERE i.auction_end >= NOW() - INTERVAL 30 DAY " +
  "AND i.item_id <> ?";

PreparedStatement ps = con.prepareStatement(query);
ps.setInt(1, Integer.parseInt(itemId));
ResultSet rs = ps.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Similar Auctions (Last 30 Days)</title>
<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>

<div class="navbar">
    <a href="welcome.jsp">Home</a> | 
    <a href="browse_auctions.jsp">Browse Auctions</a> | 
    <a href="search.jsp">Search</a> |
    <a href="alerts.jsp">Alerts</a> |
    <a href="logout.jsp">Logout</a>
</div>

<h2>Similar Auctions in the Past Month</h2>

<table>
<tr>
  <th>Item</th>
  <th>Price</th>
  <th>Auction End</th>
  <th>Status</th>
  <th>Seller</th>
</tr>

<%
boolean found = false;
while (rs.next()) {
    found = true;
%>
<tr>
  <td><a href="item_details.jsp?id=<%= rs.getInt("item_id") %>">
      <%= rs.getString("title") %>
  </a></td>
  <td>$<%= rs.getBigDecimal("current_bid") %></td>
  <td><%= rs.getTimestamp("auction_end") %></td>
  <td><%= rs.getString("status") %></td>
  <td><%= rs.getString("username") %></td>
</tr>
<%
}
if (!found) {
%>
<tr><td colspan="5">No similar items in the past month.</td></tr>
<%
}
db.closeConnection(con);
%>

</table>

</body>
</html>
