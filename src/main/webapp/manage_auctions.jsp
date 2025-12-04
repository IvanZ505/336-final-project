<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Auctions</title>
<link rel="stylesheet" type="text/css" href="style.css">

</head>
<body>

    <%-- nav bar --%>
    <div class="navbar">
        <a href="rep.jsp">Dashboard</a> | 
        <a href="answer_questions.jsp">Answer Questions</a> | 
        <a href="manage_users.jsp">Manage Users</a> |
        <a href="manage_auctions.jsp">Manage Auctions</a> |
        <a href="logout.jsp">Logout</a>
    </div>

    <%
        // Get rep ID from session
        Integer repId = (Integer) session.getAttribute("repId");
        
        if (repId == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        // Handle delete auction
        String deleteAuctionIdStr = request.getParameter("delete_auction_id");
        if (deleteAuctionIdStr != null && !deleteAuctionIdStr.trim().isEmpty()) {
            int deleteAuctionId = Integer.parseInt(deleteAuctionIdStr);
            
            Connection delCon = null;
            PreparedStatement delPs = null;
            
            try {
                ApplicationDB db = new ApplicationDB();
                delCon = db.getConnection();
                
                String deleteSql = "DELETE FROM ITEM WHERE item_id = ?";
                delPs = delCon.prepareStatement(deleteSql);
                delPs.setInt(1, deleteAuctionId);
                
                int rows = delPs.executeUpdate();
                db.closeConnection(delCon);
                
                if (rows > 0) {
                    response.sendRedirect("manage_auctions.jsp?msg=Auction+deleted+successfully");
                } else {
                    response.sendRedirect("manage_auctions.jsp?err=Failed+to+delete+auction");
                }
                return;
            } catch (Exception e) {
                response.sendRedirect("manage_auctions.jsp?err=" + e.getMessage());
                return;
            } finally {
                try {
                    if (delPs != null) delPs.close();
                } catch (SQLException ignore) {}
            }
        }

        // Handle delete bid
        String deleteBidIdStr = request.getParameter("delete_bid_id");
        String itemIdStr = request.getParameter("item_id");
        if (deleteBidIdStr != null && !deleteBidIdStr.trim().isEmpty()) {
            int deleteBidId = Integer.parseInt(deleteBidIdStr);
            
            Connection delCon = null;
            PreparedStatement delPs = null;
            
            try {
                ApplicationDB db = new ApplicationDB();
                delCon = db.getConnection();
                
                String deleteSql = "DELETE FROM BID WHERE bid_id = ?";
                delPs = delCon.prepareStatement(deleteSql);
                delPs.setInt(1, deleteBidId);
                
                int rows = delPs.executeUpdate();
                db.closeConnection(delCon);
                
                if (rows > 0) {
                    response.sendRedirect("manage_auctions.jsp?item_id=" + itemIdStr + "&msg=Bid+deleted+successfully");
                } else {
                    response.sendRedirect("manage_auctions.jsp?item_id=" + itemIdStr + "&err=Failed+to+delete+bid");
                }
                return;
            } catch (Exception e) {
                response.sendRedirect("manage_auctions.jsp?item_id=" + itemIdStr + "&err=" + e.getMessage());
                return;
            } finally {
                try {
                    if (delPs != null) delPs.close();
                } catch (SQLException ignore) {}
            }
        }

        String msg = request.getParameter("msg");
        String err = request.getParameter("err");
        if (msg != null) {
            out.println("<p style='color:green;'>" + msg + "</p>");
        }
        if (err != null) {
            out.println("<p style='color:red;'>" + err + "</p>");
        }

        // Check if viewing specific auction
        String viewItemIdStr = request.getParameter("item_id");
        
        if (viewItemIdStr != null && !viewItemIdStr.trim().isEmpty()) {
            // DETAIL VIEW - Show specific auction and its bids
            int viewItemId = Integer.parseInt(viewItemIdStr);
    %>
            <a href="manage_auctions.jsp" class="back-btn">← Back to All Auctions</a>
            
            <h2>Auction Details</h2>
            
            <%
                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                
                try {
                    ApplicationDB db = new ApplicationDB();
                    con = db.getConnection();
                    
                    // Get auction details
                    String auctionQuery = "SELECT i.*, u.username as seller_name, u.email as seller_email " +
                                         "FROM ITEM i " +
                                         "JOIN END_USER eu ON i.seller_id = eu.user_id " +
                                         "JOIN USER u ON eu.user_id = u.user_id " +
                                         "WHERE i.item_id = ?";
                    ps = con.prepareStatement(auctionQuery);
                    ps.setInt(1, viewItemId);
                    rs = ps.executeQuery();
                    
                    if (rs.next()) {
                        int itemId = rs.getInt("item_id");
                        String title = rs.getString("title");
                        double startingPrice = rs.getDouble("starting_price");
                        double bidIncrement = rs.getDouble("bid_increment");
                        Double secretMinPrice = rs.getObject("secret_min_price") != null ? rs.getDouble("secret_min_price") : null;
                        Timestamp auctionStart = rs.getTimestamp("auction_start");
                        Timestamp auctionEnd = rs.getTimestamp("auction_end");
                        String status = rs.getString("status");
                        Double currentBid = rs.getObject("current_bid") != null ? rs.getDouble("current_bid") : null;
                        String description = rs.getString("description");
                        int sellerId = rs.getInt("seller_id");
                        String sellerName = rs.getString("seller_name");
                        String sellerEmail = rs.getString("seller_email");
            %>
                        <div class="detail-box">
                            <h3><%= title %></h3>
                            
                            <div class="info-row">
                                <span class="info-label">Item ID:</span> <%= itemId %>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Status:</span> <%= status %>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Description:</span> <%= description != null ? description : "N/A" %>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Starting Price:</span> $<%= String.format("%.2f", startingPrice) %>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Current Bid:</span> <%= currentBid != null ? "$" + String.format("%.2f", currentBid) : "No bids yet" %>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Bid Increment:</span> $<%= String.format("%.2f", bidIncrement) %>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Reserve Price:</span> <%= secretMinPrice != null ? "$" + String.format("%.2f", secretMinPrice) : "None" %>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Auction Start:</span> <%= auctionStart %>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Auction End:</span> <%= auctionEnd %>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Seller:</span> <%= sellerName %> (ID: <%= sellerId %>)
                            </div>
                            <div class="info-row">
                                <span class="info-label">Seller Email:</span> <%= sellerEmail %>
                            </div>
                            
                            <br>
                            <form action="manage_auctions.jsp" method="post" style="display:inline;" 
                                  onsubmit="return confirm('Are you sure you want to delete this auction? This will delete all associated bids.');">
                                <input type="hidden" name="delete_auction_id" value="<%= itemId %>">
                                <input type="submit" value="Delete This Auction" class="delete-btn">
                            </form>
                        </div>
                        
                        <h3>Bids on This Auction</h3>
            <%
                        rs.close();
                        ps.close();
                        
                        // Get all bids for this auction
                        String bidsQuery = "SELECT b.bid_id, b.bid_amount, b.bid_status, b.is_automatic, " +
                                          "u.user_id, u.username, u.email " +
                                          "FROM BID b " +
                                          "JOIN RECEIVES r ON b.bid_id = r.bid_id " +
                                          "JOIN PLACES p ON b.bid_id = p.bid_id " +
                                          "JOIN USER u ON p.user_id = u.user_id " +
                                          "WHERE r.item_id = ? " +
                                          "ORDER BY b.bid_amount DESC";
                        ps = con.prepareStatement(bidsQuery);
                        ps.setInt(1, viewItemId);
                        rs = ps.executeQuery();
            %>
                        <table>
                            <tr>
                                <th>Bid ID</th>
                                <th>Bidder</th>
                                <th>Bidder Email</th>
                                <th>Bid Amount</th>
                                <th>Status</th>
                                <th>Type</th>
                                <th>Action</th>
                            </tr>
            <%
                        boolean hasBids = false;
                        while (rs.next()) {
                            hasBids = true;
                            int bidId = rs.getInt("bid_id");
                            double bidAmount = rs.getDouble("bid_amount");
                            String bidStatus = rs.getString("bid_status");
                            boolean isAutomatic = rs.getBoolean("is_automatic");
                            int userId = rs.getInt("user_id");
                            String username = rs.getString("username");
                            String email = rs.getString("email");
            %>
                            <tr>
                                <td><%= bidId %></td>
                                <td><%= username %> (ID: <%= userId %>)</td>
                                <td><%= email %></td>
                                <td>$<%= String.format("%.2f", bidAmount) %></td>
                                <td><%= bidStatus != null ? bidStatus : "N/A" %></td>
                                <td><%= isAutomatic ? "Automatic" : "Manual" %></td>
                                <td>
                                    <form action="manage_auctions.jsp" method="post" style="display:inline;" 
                                          onsubmit="return confirm('Are you sure you want to delete this bid?');">
                                        <input type="hidden" name="delete_bid_id" value="<%= bidId %>">
                                        <input type="hidden" name="item_id" value="<%= viewItemId %>">
                                        <input type="submit" value="Delete" class="delete-btn">
                                    </form>
                                </td>
                            </tr>
            <%
                        }
                        
                        if (!hasBids) {
            %>
                            <tr>
                                <td colspan="7">No bids have been placed on this auction yet.</td>
                            </tr>
            <%
                        }
            %>
                        </table>
            <%
                    } else {
                        out.println("<p style='color:red;'>Auction not found.</p>");
                    }
                    
                    db.closeConnection(con);
                } catch (Exception e) {
                    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (ps != null) ps.close();
                    } catch (SQLException ignore) {}
                }
            %>
    <%
        } else {
            // LIST VIEW - Show all auctions
    %>
            <h2>All Auctions</h2>

            <%
                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;

                try {
                    ApplicationDB db = new ApplicationDB();
                    con = db.getConnection();
                    
                    if (con == null) {
                        out.println("<p style='color:red;'>Unable to connect to database.</p>");
                    } else {
                        // Show all auctions
                        String auctionQuery = "SELECT i.item_id, i.title, i.current_bid, i.status, " +
                                          "i.auction_end, u.username " +
                                          "FROM ITEM i " +
                                          "JOIN END_USER eu ON i.seller_id = eu.user_id " +
                                          "JOIN USER u ON eu.user_id = u.user_id " +
                                          "ORDER BY i.auction_end DESC";
                        ps = con.prepareStatement(auctionQuery);
                        rs = ps.executeQuery();
            %>
            
            <table>
                <tr>
                    <th>Item ID</th>
                    <th>Title</th>
                    <th>Seller</th>
                    <th>Current Bid</th>
                    <th>Status</th>
                    <th>Auction End</th>
                    <th>Actions</th>
                </tr>
                
                <%
                        boolean found = false;
                        while (rs.next()) {
                            found = true;
                            int itemId = rs.getInt("item_id");
                            String title = rs.getString("title");
                            Double currentBid = rs.getObject("current_bid") != null ? rs.getDouble("current_bid") : null;
                            String status = rs.getString("status");
                            Timestamp auctionEnd = rs.getTimestamp("auction_end");
                            String seller = rs.getString("username");
                %>
                <tr>
                    <td><%= itemId %></td>
                    <td><%= title %></td>
                    <td><%= seller %></td>
                    <td><%= currentBid != null ? "$" + String.format("%.2f", currentBid) : "No bids" %></td>
                    <td><%= status %></td>
                    <td><%= auctionEnd %></td>
                    <td>
                        <a href="manage_auctions.jsp?item_id=<%= itemId %>" class="submit-btn">View Details</a>
                    </td>
                </tr>
                <%
                        }
                        
                        if (!found) {
                            out.println("<tr><td colspan='7'>No auctions in the database.</td></tr>");
                        }
                %>
            </table>
            
            <%
                        db.closeConnection(con);
                    }
                } catch (Exception e) {
                    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (ps != null) ps.close();
                    } catch (SQLException ignore) {}
                }
            %>
    <%
        }
    %>

</body>
</html>
