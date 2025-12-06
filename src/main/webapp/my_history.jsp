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
    String msgParam = request.getParameter("msg");
    if (msgParam != null) out.println("<p style='color:green; font-weight:bold;'>" + msgParam + "</p>");
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
if (session.getAttribute("user_id") == null) {
    response.sendRedirect("login.jsp");
    return;
}

int userID = (int) session.getAttribute("user_id");

try {
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    String win_query =
        "SELECT i.item_id, i.title, i.current_bid, i.secret_min_price, u.username " +
        "FROM ITEM i " +
        "JOIN USER u ON i.seller_id = u.user_id " +
        "JOIN RECEIVES r ON i.item_id = r.item_id " +
        "JOIN BID b ON r.bid_id = b.bid_id " +
        "JOIN PLACES p ON b.bid_id = p.bid_id " +
        "WHERE i.auction_end < NOW() AND p.user_id = ? " +
        "AND b.bid_amount = i.current_bid";

    PreparedStatement ps_wins = con.prepareStatement(win_query);
    ps_wins.setInt(1, userID);
    ResultSet res_set = ps_wins.executeQuery();

    boolean hasWins = false;

    while (res_set.next()) {
        hasWins = true;

        int itemId = res_set.getInt("item_id");
        String title = res_set.getString("title");
        double price = res_set.getDouble("current_bid");
        double reserve = res_set.getDouble("secret_min_price");
        String seller = res_set.getString("username");

        boolean reserveMet = (reserve == 0 || price >= reserve);
        if (!reserveMet) continue;

        String winMsg = "🎉 You won " + title + " for $" + String.format("%.2f", price);
%>

<tr>
    <td><%= title %></td>
    <td>$<%= String.format("%.2f", price) %></td>
    <td><%= seller %></td>
    <td><span class="win">WINNER</span></td>
</tr>

<%
        // Insert win alert only if not already added
        String checkSql = "SELECT alert_id FROM SETS_ALERT WHERE user_id=? AND alert_message=? LIMIT 1";
        PreparedStatement psCheck = con.prepareStatement(checkSql);
        psCheck.setInt(1, userID);
        psCheck.setString(2, winMsg);
        ResultSet rsCheck = psCheck.executeQuery();

        boolean exists = rsCheck.next();
        rsCheck.close();
        psCheck.close();

        if (!exists) {
            PreparedStatement psA = con.prepareStatement(
                "INSERT INTO SETS_ALERT (user_id, alert_message, is_active) VALUES (?, ?, 1)"
            );
            psA.setInt(1, userID);
            psA.setString(2, winMsg);
            psA.executeUpdate();
            psA.close();
        }
    }

    if (!hasWins) {
%>
<tr><td colspan="4">No wins yet.</td></tr>
<%
    }
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
    // Query: selling items
    String soldQuery =
        "SELECT i.item_id, i.title, i.current_bid, i.secret_min_price, i.auction_end, " +
        "(SELECT u2.username FROM USER u2 " +
        "JOIN PLACES p ON u2.user_id = p.user_id " +
        "JOIN RECEIVES r ON p.bid_id = r.bid_id " +
        "JOIN BID b ON r.bid_id = b.bid_id " +
        "WHERE r.item_id = i.item_id AND b.bid_amount = i.current_bid LIMIT 1) AS winner_name " +
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

        String statusText = "";
        String statusClass = "";

        if (!isExpired) {
            statusText = "Active (Ends: " + end + ")";
            statusClass = "win";
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
        <form action="delete_item_process.jsp" method="post" onsubmit="return confirmDeleteItem()">
            <input type="hidden" name="item_id" value="<%= itemId %>">
            <input type="submit" value="Delete" class="delete-btn">
        </form>
    </td>
</tr>

<%
    }

    if (!hasSold) {
%>
<tr><td colspan="4">Nothing sold yet</td></tr>
<%
    }

    con.close();

} catch (Exception e) {
    e.printStackTrace();
}
%>

</table>

</body>
</html>
