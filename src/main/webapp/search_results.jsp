<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.net.URLEncoder" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Search Results</title>

    <!-- Load SAME stylesheet as search.jsp -->
    <link rel="stylesheet" type="text/css" href="style.css">

<style>
    .results-container {
        background: transparent;
        padding: 20px;
        max-width: 1000px;
        margin: 20px auto;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        background: transparent;
    }

    th {
        background: rgba(255,255,255,0.1);
        color: white;
    }

    td {
        background: rgba(255,255,255,0.05);
        color: white;
    }

    td, th {
        border: 1px solid rgba(255,255,255,0.2);
        padding: 10px;
    }

    .pagination a, .pagination strong {
        margin: 0 6px;
        text-decoration: none;
        color: white;
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

    <div class="results-container">
        <h2>Search Results</h2>

<%
    String error = (String) request.getAttribute("error");
    if (error != null) {
%>
        <p style="color:red; font-weight:bold;"><%= error %></p>
<%
    }

    List<Map<String,Object>> results = (List<Map<String,Object>>) request.getAttribute("results");
    if (results == null) results = new ArrayList<>();

    Integer pageObj = (Integer) request.getAttribute("page");
    int pageNum = (pageObj == null) ? 1 : pageObj;

    Integer totalObj = (Integer) request.getAttribute("totalResults");
    int totalResults = (totalObj == null) ? 0 : totalObj;

    int pageSize = 10;
%>

        <p>
            Found <strong><%= totalResults %></strong> result(s).  
            Showing page <strong><%= pageNum %></strong>.
        </p>

        <table>
            <tr>
                <th>Title</th>
                <th>Category</th>
                <th>Current Bid</th>
                <th>Auction Ends</th>
                <th>Seller</th>
                <th></th>
            </tr>

<%
    if (results.isEmpty()) {
%>
            <tr><td colspan="6">No items found.</td></tr>
<%
    } else {
        for (Map<String,Object> row : results) {
            Integer id = (Integer) row.get("item_id");
            String title = (String) row.get("title");
            String cat = (String) row.get("category");

            Double price = (row.get("current_bid") == null)
                           ? null
                           : ((Number) row.get("current_bid")).doubleValue();

            java.sql.Timestamp end = (java.sql.Timestamp) row.get("auction_end");
            String seller = (String) row.get("seller_username");
%>

            <tr>
                <td><a href="item_details.jsp?itemId=<%= id %>"><%= title %></a></td>
                <td><%= cat %></td>
                <td><%= price == null ? "N/A" : String.format("$%.2f", price) %></td>
                <td><%= end != null ? end.toString() : "No end" %></td>
                <td><%= seller %></td>
                <td><a href="item_details.jsp?itemId=<%= id %>">View</a></td>
            </tr>

<%
        }
    }
%>
        </table>

<%
    int totalPages = (int)Math.ceil(totalResults / (double) pageSize);
    if (totalPages < 1) totalPages = 1;

    StringBuilder baseParams = new StringBuilder();
    Map<String,String[]> prm = request.getParameterMap();

    for (String k : prm.keySet()) {
        if ("page".equals(k)) continue;

        String[] vs = prm.get(k);
        if (vs != null && vs.length > 0 && vs[0] != null && !vs[0].isEmpty()) {
            baseParams.append("&")
                      .append(URLEncoder.encode(k, "UTF-8"))
                      .append("=")
                      .append(URLEncoder.encode(vs[0], "UTF-8"));
        }
    }
%>

        <div class="pagination" style="margin-top:20px;">
            Pages:
<%
    for (int p = 1; p <= totalPages; p++) {
        if (p == pageNum) {
%>
            <strong><%= p %></strong>
<%
        } else {
%>
            <a href="search?page=<%= p %><%= baseParams.toString() %>"><%= p %></a>
<%
        }
    }
%>
        </div>

        <p><a href="search.jsp">← Back to Search</a></p>
    </div>

</body>
</html>
