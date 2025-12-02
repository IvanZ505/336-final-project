<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%-- Import standard SQL libraries and our custom Database Helper class --%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Browse Auctions</title>
<style>
    /* formatting for the tables*/
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 10px; border: 1px solid #ddd; text-align: left; }
    tr:nth-child(even) { background-color: #f2f2f2; } 
    th { background-color: #4CAF50; color: white; }
</style>
</head>
<body>

    <%-- nav bar to hold links to other parts of the site --%>
    <div style="background: #eee; padding: 10px; margin-bottom: 20px;">
        <a href="welcome.jsp">Home</a> | 
        <a href="create_auction.jsp">Sell Item</a> | 
        <a href="browse_auctions.jsp">Browse Auctions</a> | 
        <a href="logout.jsp">Logout</a>
    </div>

    <h2>Active Auctions</h2>

    <%-- auction table, lists all items for sale rn, rows dynamically generated through java code --%>
    <table>
        <tr>
            <th>Item</th>
            <th>Current Bid</th>
            <th>Closes At</th>
            <th>Seller</th>
            <th>Action</th>
        </tr>

        <%
            try {
                // connect to db
                com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB();
                Connection con = db.getConnection();

                // show the items that are for sale right now
                String query = "SELECT i.item_id, i.title, i.current_bid, i.auction_end, u.username " +
                               "FROM ITEM i JOIN USER u ON i.seller_id = u.user_id " +
                               "WHERE i.status = 'open' AND i.auction_end > NOW() " +
                               "ORDER BY i.auction_end ASC"; // Show items ending soonest first.
                
                // query execution
                Statement statem = con.createStatement();
                ResultSet rs = statem.executeQuery(query);

                // loop through result for every item
                while (rs.next()) {
                    // get data from current row and put into java var
                    int itemID = rs.getInt("item_id");
                    String title = rs.getString("title");
                    double price = rs.getDouble("current_bid");
                    Timestamp end = rs.getTimestamp("auction_end");
                    String seller = rs.getString("username");
        %>
            <%-- show the row --%>
            <tr>
                <td><%= title %></td>
                <td>$<%= String.format("%.2f", price) %></td> <%-- Format price to 2 decimal places (e.g. 10.50) --%>
                <td><%= end %></td>
                <td><%= seller %></td>
                <%-- put item id into url--%>
                <td><a href="item_details.jsp?id=<%= itemID %>">View & Bid</a></td>
            </tr>
        <%
                } // Closing the while loop
                
                db.closeConnection(con);
            } catch (Exception e) {
                // print out error message if something goes wrong
                out.println("Error: " + e.getMessage());
            }
        %>
    </table>

</body>
</html>
