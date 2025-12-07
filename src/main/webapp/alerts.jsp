<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Your Alerts</title>
<link rel="stylesheet" type="text/css" href="style.css">

<style>
table { width: 100%; border-collapse: collapse; background: transparent; }
th { background: rgba(255,255,255,0.1); color: white; }
td { background: rgba(255,255,255,0.05); color: white; }
td, th { padding: 10px; border: 1px solid rgba(255,255,255,0.2); }

.alert-message-box {
    background: rgba(255, 221, 87, 0.1);
    border-left: 4px solid #ffdd57;
    padding: 15px;
    margin: 10px 0;
    color: white;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.alert-message-box .message-content {
    flex-grow: 1;
}
.alert-message-box .dismiss-btn {
    background: transparent;
    border: 1px solid #ffdd57;
    color: #ffdd57;
    padding: 5px 10px;
    border-radius: 4px;
    cursor: pointer;
    margin-left: 15px;
}
.alert-message-box .dismiss-btn:hover {
    background: #ffdd57;
    color: black;
}
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
    <a href="logout.jsp">Logout</a>
</div>

<h2>Your Alerts</h2>

<div style="margin: 15px 0;">
    <a href="alert_match.jsp" 
       style="
           display:inline-block;
           padding:10px 18px;
           background:#ffdd57;
           color:#000;
           font-weight:bold;
           border-radius:6px;
           text-decoration:none;
           transition:0.2s;
       "
       onmouseover="this.style.background='#ffe680';"
       onmouseout="this.style.background='#ffdd57';">
        🔍 View Items Matching Your Alerts
    </a>
</div>

<div style="margin-bottom: 20px;">
    <form action="dismiss_alerts.jsp" method="post" style="display: inline;">
        <input type="submit" value="Dismiss All Notifications" class="delete-btn" style="padding: 8px 15px; background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.3);">
    </form>
</div>

<%
    String msg = request.getParameter("msg");
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");

    if (msg != null) {
        out.println("<p style='color:green;'>" + msg + "</p>");
    }
    if (error != null) {
        out.println("<p style='color:red;'>" + error + "</p>");
    }
    if (success != null) {
        out.println("<p style='color:green;'>" + success + "</p>");
    }
%>

<%
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (int) session.getAttribute("user_id");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    // 1. Fetch Notification Alerts (Outbid, Won, etc.)
    String notifSql = "SELECT alert_id, alert_message FROM SETS_ALERT WHERE user_id=? AND alert_message IS NOT NULL AND is_active=1 ORDER BY alert_id DESC";
    PreparedStatement psNotif = con.prepareStatement(notifSql);
    psNotif.setInt(1, userId);
    ResultSet rsNotif = psNotif.executeQuery();
    
    boolean hasNotifs = false;
    while (rsNotif.next()) {
        hasNotifs = true;
        int aId = rsNotif.getInt("alert_id");
        String message = rsNotif.getString("alert_message");
%>
        <div class="alert-message-box">
            <span class="message-content">🔔 <%= message %></span>
            <form action="delete_alert.jsp" method="post" style="margin:0;">
                <input type="hidden" name="alert_id" value="<%= aId %>">
                <input type="hidden" name="redirect" value="alerts.jsp">
                <input type="submit" value="Dismiss" class="dismiss-btn">
            </form>
        </div>
<%
    }
    if (!hasNotifs) {
%>
    <p style="color: #888; font-style: italic;">No new notifications.</p>
<%
    }
    rsNotif.close();
    psNotif.close();
%>

<h3>Your Search Alerts</h3>

<%
    String sql =
        "SELECT alert_id, keywords, size, brand, item_condition, color, " +
        "       min_price, max_price, is_active " +
        "FROM SETS_ALERT WHERE user_id=? AND alert_message IS NULL";

    PreparedStatement ps = con.prepareStatement(sql);
    ps.setInt(1, userId);
    ResultSet rs = ps.executeQuery();
%>

<table>
<tr>
    <th>Keyword</th>
    <th>Size</th>
    <th>Brand</th>
    <th>Condition</th>
    <th>Color</th>
    <th>Min Price</th>
    <th>Max Price</th>
    <th>Status</th>
    <th></th>
</tr>

<%
boolean any = false;
while (rs.next()) {
    any = true;
%>
<tr>
    <td><%= rs.getString("keywords") == null ? "" : rs.getString("keywords") %></td>
    <td><%= rs.getString("size") == null ? "" : rs.getString("size") %></td>
    <td><%= rs.getString("brand") == null ? "" : rs.getString("brand") %></td>
    <td><%= rs.getString("item_condition") == null ? "" : rs.getString("item_condition") %></td>
    <td><%= rs.getString("color") == null ? "" : rs.getString("color") %></td>
    <td>
        <%
            Object minObj = rs.getObject("min_price");
            out.print(minObj == null ? "" : minObj.toString());
        %>
    </td>
    <td>
        <%
            Object maxObj = rs.getObject("max_price");
            out.print(maxObj == null ? "" : maxObj.toString());
        %>
    </td>
    <td><%= rs.getInt("is_active") == 1 ? "Active" : "Inactive" %></td>
    <td>
        <form action="delete_alert.jsp" method="post" style="display:inline;">
            <input type="hidden" name="alert_id" value="<%= rs.getInt("alert_id") %>">
            <input type="submit" value="Delete">
        </form>
    </td>
</tr>
<%
}
if (!any) out.println("<tr><td colspan='9'>No search alerts set.</td></tr>");

db.closeConnection(con);
%>
</table>

<p><a href="set_alert.jsp">+ Create New Search Alert</a></p>

</body>
</html>
