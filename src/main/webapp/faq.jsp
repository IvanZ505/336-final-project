<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>FAQ - Questions & Answers</title>
<link rel="stylesheet" type="text/css" href="style.css">

<style>
    .faq-box {
        max-width: 1100px;
        margin: 20px auto;
        background: rgba(255,255,255,0.05);
        padding: 20px;
        border-radius: 8px;
        color: white;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 15px;
    }

    th, td {
        border: 1px solid rgba(255,255,255,0.2);
        padding: 10px;
        text-align: left;
    }

    th {
        background: rgba(255,255,255,0.15);
    }

    td {
        background: rgba(255,255,255,0.05);
    }

    .search-bar {
        margin-bottom: 15px;
    }

    .search-bar input {
        padding: 6px;
        width: 260px;
    }

    .search-bar input[type=submit] {
        width: auto;
        cursor: pointer;
    }
</style>
</head>

<body>

<!-- ✅ NAVBAR -->
<div class="navbar">
    <a href="welcome.jsp">Home</a> | 
    <a href="create_auction.jsp">Sell Item</a> | 
    <a href="browse_auctions.jsp">Browse Auctions</a> | 
    <a href="help.jsp">Help</a> |
    <a href="search.jsp">Search</a> |
    <a href="alerts.jsp">Alerts</a> |
    <a href="logout.jsp">Logout</a>
</div>

<div class="faq-box">
    <h2>Frequently Asked Questions</h2>

    <!-- ✅ SEARCH BAR -->
    <form class="search-bar" method="get" action="faq.jsp">
        <input type="text" name="q" placeholder="Search questions by keyword..."
               value="<%= request.getParameter("q") == null ? "" : request.getParameter("q") %>">
        <input type="submit" value="Search">
    </form>

<%
    String keyword = request.getParameter("q");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    PreparedStatement ps;
    ResultSet rs;

    String sql =
        "SELECT s.log_id, s.reason, s.answer, s.action_type, s.action_time, u.username, r.name " +
        "FROM SUPPORTS s " +
        "JOIN USER u ON s.user_id = u.user_id " +
        "LEFT JOIN CUSTOMER_REP r ON s.rep_id = r.rep_id " +
        "WHERE s.answer IS NOT NULL ";

    if (keyword != null && !keyword.trim().isEmpty()) {
        sql += " AND s.reason LIKE ? ";
        ps = con.prepareStatement(sql);
        ps.setString(1, "%" + keyword.trim() + "%");
    } else {
        ps = con.prepareStatement(sql);
    }

    rs = ps.executeQuery();
%>

    <table>
        <tr>
            <th>Question</th>
            <th>Answer</th>
            <th>Category</th>
            <th>Asked By</th>
            <th>Answered By</th>
            <th>Date</th>
        </tr>

<%
    boolean hasRows = false;
    while (rs.next()) {
        hasRows = true;
%>
        <tr>
            <td><%= rs.getString("reason") %></td>
            <td><%= rs.getString("answer") %></td>
            <td><%= rs.getString("action_type") %></td>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getString("name") == null ? "Unassigned" : rs.getString("name") %></td>
            <td><%= rs.getTimestamp("action_time") %></td>
        </tr>
<%
    }

    if (!hasRows) {
%>
        <tr>
            <td colspan="6">No matching questions found.</td>
        </tr>
<%
    }

    rs.close();
    ps.close();
    db.closeConnection(con);
%>

    </table>
</div>

</body>
</html>
