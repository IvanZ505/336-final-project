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

    String sql =
        "SELECT alert_id, keywords, size, brand, condition, color, " +
        "       min_price, max_price, is_active " +
        "FROM SETS_ALERT WHERE user_id=?";

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
    <td><%= rs.getString("condition") == null ? "" : rs.getString("condition") %></td>
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
if (!any) out.println("<tr><td colspan='9'>No alerts.</td></tr>");

db.closeConnection(con);
%>
</table>

<p><a href="set_alert.jsp">+ Create New Alert</a></p>

</body>
</html>
