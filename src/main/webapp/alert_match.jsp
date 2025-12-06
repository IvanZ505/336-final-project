<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Alert Matches</title>
<link rel="stylesheet" type="text/css" href="style.css">

<style>
    .match-box {
        background: rgba(255,255,255,0.05);
        padding: 15px;
        margin: 20px auto;
        border-radius: 8px;
        max-width: 1000px;
        color: white;
    }
    .match-box h3 {
        margin-top: 0;
        color: #ffdd57;
    }
    table { width:100%; border-collapse:collapse; color:white; }
    th { background:rgba(255,255,255,0.15); }
    td { background:rgba(255,255,255,0.05); }
    th,td { padding:10px; border:1px solid rgba(255,255,255,0.2); }
</style>
</head>

<body>

<!-- NAVBAR -->
<div class="navbar">
    <a href="welcome.jsp">Home</a> | 
    <a href="create_auction.jsp">Sell Item</a> | 
    <a href="browse_auctions.jsp">Browse Auctions</a> | 
    <a href="search.jsp">Search</a> | 
    <a href="alerts.jsp">Alerts</a> |
    <a href="logout.jsp">Logout</a>
</div>

<h2 style="color:white;">Items Matching Your Alerts</h2>

<%
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (int) session.getAttribute("user_id");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    // Fetch user alerts
    String alertSql = "SELECT * FROM SETS_ALERT WHERE user_id=? AND is_active=1";
    PreparedStatement psA = con.prepareStatement(alertSql);
    psA.setInt(1, userId);
    ResultSet alerts = psA.executeQuery();
%>

<%
boolean hasAnyAlerts = false;

while (alerts.next()) {
    hasAnyAlerts = true;

    int alertId       = alerts.getInt("alert_id");
    String keywords   = alerts.getString("keywords");
    String size       = alerts.getString("size");
    String brand      = alerts.getString("brand");
    String cond       = alerts.getString("item_condition");
    String color      = alerts.getString("color");

    Float minP = (alerts.getObject("min_price") == null) ? null :
                 ((Number) alerts.getObject("min_price")).floatValue();

    Float maxP = (alerts.getObject("max_price") == null) ? null :
                 ((Number) alerts.getObject("max_price")).floatValue();
%>

<div class="match-box">
    <h3>Alert #<%= alertId %></h3>

    <p>
        <strong>Keywords:</strong> <%= keywords %> &nbsp;
        <strong>Size:</strong> <%= size %> &nbsp;
        <strong>Brand:</strong> <%= brand %> &nbsp;
        <strong>Condition:</strong> <%= cond %> &nbsp;
        <strong>Color:</strong> <%= color %> &nbsp;
        <strong>Price:</strong> <%= (minP==null?"-":minP) %> → <%= (maxP==null?"-":maxP) %>
    </p>

<%
    /* --- BUILD DYNAMIC MATCH QUERY --- */

    String sqlMatch =
        "SELECT DISTINCT i.item_id, i.title, i.current_bid, i.auction_end " +
        "FROM ITEM i " +
        "LEFT JOIN SHIRT s ON i.item_id = s.item_id " +
        "LEFT JOIN BAG b ON i.item_id = b.item_id " +
        "LEFT JOIN SHOE sh ON i.item_id = sh.item_id " +
        "WHERE i.auction_end > NOW() ";

    List<Object> params = new ArrayList<>();

    if (keywords != null && !keywords.isEmpty()) {
        sqlMatch += " AND (i.title LIKE ? OR i.description LIKE ?) ";
        params.add("%" + keywords + "%");
        params.add("%" + keywords + "%");
    }
    if (brand != null && !brand.isEmpty()) {
        sqlMatch += " AND (s.brand = ? OR b.brand = ? OR sh.brand = ?) ";
        params.add(brand); params.add(brand); params.add(brand);
    }
    if (cond != null && !cond.isEmpty()) {
        sqlMatch += " AND (s.item_condition = ? OR b.item_condition = ? OR sh.item_condition = ?) ";
        params.add(cond); params.add(cond); params.add(cond);
    }
    if (color != null && !color.isEmpty()) {
        sqlMatch += " AND (s.color = ? OR b.color = ?) ";
        params.add(color); params.add(color);
    }
    if (size != null && !size.isEmpty()) {
        sqlMatch += " AND (s.size = ? OR sh.size = ?) ";
        params.add(size); params.add(size);
    }
    if (minP != null) {
        sqlMatch += " AND COALESCE(i.current_bid, i.starting_price) >= ? ";
        params.add(minP);
    }
    if (maxP != null) {
        sqlMatch += " AND COALESCE(i.current_bid, i.starting_price) <= ? ";
        params.add(maxP);
    }

    PreparedStatement psM = con.prepareStatement(sqlMatch);
    for (int i = 0; i < params.size(); i++) {
        psM.setObject(i + 1, params.get(i));
    }

    ResultSet matches = psM.executeQuery();
%>

    <table>
        <tr>
            <th>Item</th>
            <th>Current Bid</th>
            <th>Auction Ends</th>
            <th></th>
        </tr>

<%
    boolean foundMatches = false;
    while (matches.next()) {
        foundMatches = true;
%>
        <tr>
            <td><%= matches.getString("title") %></td>
            <td><%= matches.getObject("current_bid") %></td>
            <td><%= matches.getTimestamp("auction_end") %></td>
            <td><a href="item_details.jsp?id=<%= matches.getInt("item_id") %>">View</a></td>
        </tr>
<%
    }
    if (!foundMatches) {
%>
        <tr><td colspan="4">No items matched this alert.</td></tr>
<%
    }
%>

    </table>

</div>

<%
} // end alert loop

if (!hasAnyAlerts) {
%>
    <p style="color:white;">You have no alerts set.</p>
<%
}

con.close();
%>

</body>
</html>
