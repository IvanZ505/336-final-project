<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>User Auction Participation</title>
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

<%
String username = request.getParameter("username");
if (username == null) {
    out.println("<p style='color:red;'>No user selected.</p>");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = db.getConnection();

PreparedStatement psUser = con.prepareStatement(
    "SELECT user_id FROM USER WHERE username = ?"
);
psUser.setString(1, username);
ResultSet rsUser = psUser.executeQuery();

if (!rsUser.next()) {
    out.println("<p>User not found.</p>");
    return;
}

int userId = rsUser.getInt("user_id");
%>

<h2>Auctions for: <%= username %></h2>

<hr>

<h3>Items Sold</h3>
<table>
<tr><th>Item</th><th>Final Price</th><th>Status</th></tr>

<%
PreparedStatement psSold = con.prepareStatement(
    "SELECT title, current_bid, status FROM ITEM WHERE seller_id = ?"
);
psSold.setInt(1, userId);
ResultSet rsSold = psSold.executeQuery();

boolean hasSold = false;
while (rsSold.next()) {
    hasSold = true;
%>
<tr>
  <td><%= rsSold.getString("title") %></td>
  <td>$<%= rsSold.getBigDecimal("current_bid") %></td>
  <td><%= rsSold.getString("status") %></td>
</tr>
<%
}
if (!hasSold) {
%>
<tr><td colspan="3">No items sold.</td></tr>
<%
}
%>
</table>

<hr>

<h3>Items Bid On</h3>
<table>
<tr><th>Item</th><th>Bid</th><th>Status</th></tr>

<%
PreparedStatement psBid = con.prepareStatement(
    "SELECT i.title, b.bid_amount, i.status " +
    "FROM BID b " +
    "JOIN PLACES p ON b.bid_id = p.bid_id " +
    "JOIN RECEIVES r ON b.bid_id = r.bid_id " +
    "JOIN ITEM i ON r.item_id = i.item_id " +
    "WHERE p.user_id = ?"
);
psBid.setInt(1, userId);
ResultSet rsBid = psBid.executeQuery();

boolean hasBids = false;
while (rsBid.next()) {
    hasBids = true;
%>
<tr>
  <td><%= rsBid.getString("title") %></td>
  <td>$<%= rsBid.getBigDecimal("bid_amount") %></td>
  <td><%= rsBid.getString("status") %></td>
</tr>
<%
}
if (!hasBids) {
%>
<tr><td colspan="3">No bids placed.</td></tr>
<%
}
%>
</table>

<hr>

<h3>Items Won</h3>
<table>
<tr><th>Item</th><th>Final Price</th></tr>

<%
PreparedStatement psWon = con.prepareStatement(
    "SELECT i.title, i.current_bid " +
    "FROM ITEM i " +
    "JOIN RECEIVES r ON i.item_id = r.item_id " +
    "JOIN BID b ON r.bid_id = b.bid_id " +
    "JOIN PLACES p ON b.bid_id = p.bid_id " +
    "WHERE p.user_id = ? AND b.bid_amount = i.current_bid"
);
psWon.setInt(1, userId);
ResultSet rsWon = psWon.executeQuery();

boolean hasWins = false;
while (rsWon.next()) {
    hasWins = true;
%>
<tr>
  <td><%= rsWon.getString("title") %></td>
  <td>$<%= rsWon.getBigDecimal("current_bid") %></td>
</tr>
<%
}
if (!hasWins) {
%>
<tr><td colspan="2">No wins yet.</td></tr>
<%
}
%>
</table>

<%
db.closeConnection(con);
%>

</body>
</html>
