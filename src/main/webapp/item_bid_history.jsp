<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Bid History</title>
<link rel="stylesheet" type="text/css" href="style.css">

<style>
    table { width: 100%; border-collapse: collapse; background: transparent; }
    th { background: rgba(255,255,255,0.1); color: white; }
    td { background: rgba(255,255,255,0.05); color: white; }
    td, th { padding: 10px; border: 1px solid rgba(255,255,255,0.2); }
</style>
</head>
<body>

    <div class="navbar">
        <a href="welcome.jsp">Home</a> | 
        <a href="create_auction.jsp">Sell Item</a> | 
        <a href="browse_auctions.jsp">Browse Auctions</a> | 
        <a href="help.jsp">Help</a> |
        <a href="search.jsp">Search</a> |
        <a href="alerts.jsp">Alerts</a> |
        <a href="logout.jsp">Logout</a> |
    </div>


<h2>Bid History</h2>

<%
    String itemId = request.getParameter("itemId");
    if (itemId == null) {
        out.println("<p style='color:red'>Invalid item.</p>");
        return;
    }

    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        String sql =
            "SELECT b.bid_amount, b.bid_status, b.is_automatic, " +
            "       p.user_id, u.username, r.item_id " +
            "FROM BID b " +
            "JOIN RECEIVES r ON b.bid_id = r.bid_id " +
            "JOIN PLACES p ON b.bid_id = p.bid_id " +
            "JOIN USER u ON u.user_id = p.user_id " +
            "WHERE r.item_id = ? ORDER BY b.bid_amount DESC";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, itemId);
        ResultSet rs = ps.executeQuery();
%>

<table>
    <tr>
        <th>Bidder</th>
        <th>Amount</th>
        <th>Type</th>
    </tr>

<%
    boolean has = false;
    while (rs.next()) {
        has = true;
        String bidder = rs.getString("username");
        double amt = rs.getDouble("bid_amount");
        boolean auto = rs.getInt("is_automatic") == 1;
%>
    <tr>
        <td><%= bidder %></td>
        <td>$<%= String.format("%.2f", amt) %></td>
        <td><%= auto ? "Automatic" : "Manual" %></td>
    </tr>
<%
    }
    if (!has) out.println("<tr><td colspan='3'>No bids yet.</td></tr>");

    db.closeConnection(con);
    } catch (Exception e) {
        out.println("<p style='color:red'>Error loading bid history.</p>");
        e.printStackTrace();
    }
%>
</table>

<p><a href="view_item.jsp?itemId=<%= itemId %>">← Back to item</a></p>

</body>
</html>
