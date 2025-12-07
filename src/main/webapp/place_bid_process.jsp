<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    // place_bid_process.jsp works on the bidding logic (validation, insertion, auto counter-bids) 

    // validation, make sure user logged in
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userID = (int) session.getAttribute("user_id");
    int itemID = Integer.parseInt(request.getParameter("item_id"));
    double bid_amount = Double.parseDouble(request.getParameter("amount"));
    double min_bid = Double.parseDouble(request.getParameter("min_bid"));
    
    // see if auto-bid chosen
    boolean is_auto = request.getParameter("is_auto") != null;
    Double auto_lim = null;
    if (is_auto && request.getParameter("auto_limit") != null && !request.getParameter("auto_limit").isEmpty()) {
        auto_lim = Double.parseDouble(request.getParameter("auto_limit"));
    }

    // check if bid high enough
    if (bid_amount < min_bid) {
        response.sendRedirect("item_details.jsp?id=" + itemID + "&error=Bid too low");
        return;
    }

    Connection con = null;
    com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB();
    
    try {
        con = db.getConnection();
        con.setAutoCommit(false); // start transaction for data integrity (multiple things happen at once, only works if all works)

        // lock item row so no race conditions happen
        PreparedStatement ps_lock = con.prepareStatement("SELECT title, current_bid, bid_increment FROM ITEM WHERE item_id = ? FOR UPDATE");
        ps_lock.setInt(1, itemID);
        ResultSet rs_lock = ps_lock.executeQuery();
        rs_lock.next();
        String itemTitle = rs_lock.getString("title");
        double currentDbPrice = rs_lock.getDouble("current_bid");
        double increment = rs_lock.getDouble("bid_increment");

        // make sure price hasn't changed since page loaded
        if (bid_amount < (currentDbPrice + increment)) {
             throw new Exception("Please refresh, someone else placed a bid while you were watching.");
        }

        // FIND PREVIOUS HIGHEST BIDDER TO ALERT THEM (IF THEY ARE NOT THE SAME AS CURRENT USER)
        String findPrevBidderSql = 
            "SELECT p.user_id " +
            "FROM RECEIVES r " +
            "JOIN BID b ON r.bid_id = b.bid_id " +
            "JOIN PLACES p ON b.bid_id = p.bid_id " +
            "WHERE r.item_id = ? " +
            "ORDER BY b.bid_amount DESC LIMIT 1";
            
        PreparedStatement psPrev = con.prepareStatement(findPrevBidderSql);
        psPrev.setInt(1, itemID);
        ResultSet rsPrev = psPrev.executeQuery();
        
        if (rsPrev.next()) {
            int prevBidderId = rsPrev.getInt("user_id");
            if (prevBidderId != userID) {
                // Alert previous bidder they have been outbid
                String outbidMsg = "You have been outbid on item '" + itemTitle + "'. Current price: $" + String.format("%.2f", bid_amount);
                
                // Check for duplicate alert to avoid spamming
                String checkDupSql = "SELECT alert_id FROM SETS_ALERT WHERE user_id=? AND alert_message=? AND is_active=1";
                PreparedStatement psCheck = con.prepareStatement(checkDupSql);
                psCheck.setInt(1, prevBidderId);
                psCheck.setString(2, outbidMsg);
                if (!psCheck.executeQuery().next()) {
                    // Create alert
                    PreparedStatement psAlert = con.prepareStatement(
                        "INSERT INTO SETS_ALERT (user_id, alert_message, is_active) VALUES (?, ?, 1)"
                    );
                    psAlert.setInt(1, prevBidderId);
                    psAlert.setString(2, outbidMsg);
                    psAlert.executeUpdate();
                }
            }
        }

        // place manual bids
        int manbidID = place_bid(con, userID, itemID, bid_amount);
        
        // insert into auto bid table if enabled
        if (is_auto && auto_lim != null) {
             PreparedStatement psAuto = con.prepareStatement("INSERT INTO AUTOMATIC_BID (bid_id, upper_limit) VALUES (?, ?)");
             psAuto.setInt(1, manbidID);
             psAuto.setDouble(2, auto_lim);
             psAuto.executeUpdate();
        }

        // update item table w/new highest price
        update_item_price(con, itemID, bid_amount);

        // look for current auto-bidders
        // if past auto-bidders found, set the one with the highest limit to fight agains the user
        String auto_query = "SELECT ab.upper_limit, p.user_id " +
                           "FROM AUTOMATIC_BID ab " +
                           "JOIN BID b ON ab.bid_id = b.bid_id " +
                           "JOIN RECEIVES r ON b.bid_id = r.bid_id " +
                           "JOIN PLACES p ON b.bid_id = p.bid_id " +
                           "WHERE r.item_id = ? " +
                           "AND ab.upper_limit > ? " +
                           "AND p.user_id != ? " +  // prevents self-bidding
                           "ORDER BY ab.upper_limit DESC LIMIT 1"; 
        
        PreparedStatement psCheckAuto = con.prepareStatement(auto_query);
        psCheckAuto.setInt(1, itemID);
        psCheckAuto.setDouble(2, bid_amount);
        psCheckAuto.setInt(3, userID);
        ResultSet rs_auto = psCheckAuto.executeQuery();

        if (rs_auto.next()) {
            // auto-bidder found
            double defender_lim = rs_auto.getDouble("upper_limit");
            int defID = rs_auto.getInt("user_id");

            // find the next minimum counter-bid
            double counterbid_amount = bid_amount + increment;
            
            // don't let the counter-bid go over the defender's limit
            if (counterbid_amount > defender_lim) {
                counterbid_amount = defender_lim;
            }

            // do the autom counter-bid for the defender
            place_bid(con, defID, itemID, counterbid_amount);
            update_item_price(con, itemID, counterbid_amount);
            
            // Alert manual bidder immediately if they are instantly outbid by auto-bidder
            if (counterbid_amount > bid_amount) {
                 String outbidMsg = "Your bid on '" + itemTitle + "' was immediately outbid by an automatic bidder. Current price: $" + String.format("%.2f", counterbid_amount);
                 PreparedStatement psAlert = con.prepareStatement(
                    "INSERT INTO SETS_ALERT (user_id, alert_message, is_active) VALUES (?, ?, 1)"
                 );
                 psAlert.setInt(1, userID);
                 psAlert.setString(2, outbidMsg);
                 psAlert.executeUpdate();
            }
            
            // loop of auto-bidding if current user also has auto-bid
            // keep checking limits of each user and set the auto-bids higher until one reaches their limit
            // the other person then wins
            while (true) {
                if (is_auto && auto_lim != null && auto_lim > counterbid_amount) {
                     // attacker counters
                     double next_bid = counterbid_amount + increment;
                     if (next_bid > auto_lim) next_bid = auto_lim;
                     
                     place_bid(con, userID, itemID, next_bid);
                     update_item_price(con, itemID, next_bid);
                     bid_amount = next_bid; // Update current standing price
                     
                     // see if defender counters
                     if (defender_lim > bid_amount) {
                         counterbid_amount = bid_amount + increment;
                         if (counterbid_amount > defender_lim) counterbid_amount = defender_lim;
                         
                         place_bid(con, defID, itemID, counterbid_amount);
                         update_item_price(con, itemID, counterbid_amount);
                     } else {
                         // Defender hit limit - ALERT DEFENDER
                         String limitMsg = "Your automatic bid limit of $" + String.format("%.2f", defender_lim) + " for item '" + itemTitle + "' has been exceeded.";
                         PreparedStatement psAlert = con.prepareStatement(
                            "INSERT INTO SETS_ALERT (user_id, alert_message, is_active) VALUES (?, ?, 1)"
                         );
                         psAlert.setInt(1, defID);
                         psAlert.setString(2, limitMsg);
                         psAlert.executeUpdate();
                         break; // defender hit limit
                     }
                } else {
                    // Current user hit limit or didn't have auto-bid
                    if (is_auto && auto_lim != null && auto_lim <= counterbid_amount) {
                         // Attacker hit limit - ALERT ATTACKER
                         String limitMsg = "Your automatic bid limit of $" + String.format("%.2f", auto_lim) + " for item '" + itemTitle + "' has been reached/exceeded.";
                         PreparedStatement psAlert = con.prepareStatement(
                            "INSERT INTO SETS_ALERT (user_id, alert_message, is_active) VALUES (?, ?, 1)"
                         );
                         psAlert.setInt(1, userID);
                         psAlert.setString(2, limitMsg);
                         psAlert.executeUpdate();
                    }
                    break; // current user hit limit or didn't have auto-bid
                }
            }
        }

        con.commit(); // commit all the changes
        response.sendRedirect("item_details.jsp?id=" + itemID + "&msg=Bid Placed");

    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (SQLException ex) {} // if a error occurs any step of the way
        e.printStackTrace();
        response.sendRedirect("item_details.jsp?id=" + itemID + "&error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } finally {
        if (con != null) db.closeConnection(con);
    }
%>

<%!
    // helper to insert bid row + link tables
    public int place_bid(Connection con, int userID, int itemID, double amount) throws SQLException {
        // insert into bid table
        PreparedStatement ps_bid = con.prepareStatement("INSERT INTO BID (bid_amount, bid_status) VALUES (?, 'active')", Statement.RETURN_GENERATED_KEYS);
        ps_bid.setDouble(1, amount);
        ps_bid.executeUpdate();
        
        int bidID = -1;
        ResultSet rs = ps_bid.getGeneratedKeys();
        if (rs.next()) bidID = rs.getInt(1);
        
        // link to user, place table
        PreparedStatement ps_places = con.prepareStatement("INSERT INTO PLACES (user_id, bid_id) VALUES (?, ?)");
        ps_places.setInt(1, userID);
        ps_places.setInt(2, bidID);
        ps_places.executeUpdate();
        
        // link to item, receive table
        PreparedStatement ps_receives = con.prepareStatement("INSERT INTO RECEIVES (item_id, bid_id) VALUES (?, ?)");
        ps_receives.setInt(1, itemID);
        ps_receives.setInt(2, bidID);
        ps_receives.executeUpdate();
        
        return bidID;
    }

    // helper to update item's current bid price
    public void update_item_price(Connection con, int itemID, double newPrice) throws SQLException {
        PreparedStatement ps = con.prepareStatement("UPDATE ITEM SET current_bid = ? WHERE item_id = ?");
        ps.setDouble(1, newPrice);
        ps.setInt(2, itemID);
        ps.executeUpdate();
    }
%>
