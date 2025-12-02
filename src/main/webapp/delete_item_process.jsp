<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" %>

<%
    //delete_item_process.jsp
    // deletes item listing + related rows so no fk constraints

    // validate user logged in
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userID = (int) session.getAttribute("user_id");
    String item_id_str = request.getParameter("item_id");
    
    if (item_id_str == null) {
        response.sendRedirect("my_history.jsp");
        return;
    }
    int itemID = Integer.parseInt(item_id_str);

    Connection con = null;
    com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB();
    
    try {
        con = db.getConnection();
        con.setAutoCommit(false); // start the transaction

        // verify ownership of item
        PreparedStatement psCheck = con.prepareStatement("SELECT seller_id FROM ITEM WHERE item_id = ?");
        psCheck.setInt(1, itemID);
        ResultSet rsCheck = psCheck.executeQuery();
        
        if (!rsCheck.next()) {
            throw new Exception("Item not found.");
        }
        if (rsCheck.getInt("seller_id") != userID) {
            throw new Exception("Permission Denied: You do not own this item.");
        }

        // delete children manually bc on delete cascade could be missing in live DB

        // find all the bids on this item
        List<Integer> bid_IDs = new ArrayList<>();
        PreparedStatement ps_get_bids = con.prepareStatement("SELECT bid_id FROM RECEIVES WHERE item_id = ?");
        ps_get_bids.setInt(1, itemID);
        ResultSet rs_bids = ps_get_bids.executeQuery();
        while (rs_bids.next()) {
            bid_IDs.add(rs_bids.getInt("bid_id"));
        }

        // delete bids and all their associated links
        if (!bid_IDs.isEmpty()) {
            // turn list into string to use in "in" clause
            StringBuilder temp = new StringBuilder();
            for (int id : bid_IDs) temp.append(id).append(",");
            String idList = temp.substring(0, temp.length() - 1);

            // delete bid from places 
            Statement statem = con.createStatement();
            statem.executeUpdate("DELETE FROM PLACES WHERE bid_id IN (" + idList + ")");
            
            // delete bid from receives
            statem.executeUpdate("DELETE FROM RECEIVES WHERE bid_id IN (" + idList + ")");
            
            // delete bid from automatic_bid if exists 
            statem.executeUpdate("DELETE FROM AUTOMATIC_BID WHERE bid_id IN (" + idList + ")");

            // delete bid from bid table
            statem.executeUpdate("DELETE FROM BID WHERE bid_id IN (" + idList + ")");
        }

        // delete bid from subtype tables
        PreparedStatement ps_shirt = con.prepareStatement("DELETE FROM SHIRT WHERE item_id = ?");
        ps_shirt.setInt(1, itemID);
        ps_shirt.executeUpdate();

        PreparedStatement ps_shoe = con.prepareStatement("DELETE FROM SHOE WHERE item_id = ?");
        ps_shoe.setInt(1, itemID);
        ps_shoe.executeUpdate();

        PreparedStatement ps_bag = con.prepareStatement("DELETE FROM BAG WHERE item_id = ?");
        ps_bag.setInt(1, itemID);
        ps_bag.executeUpdate();
        
        // delete any alerts
        PreparedStatement ps_alert = con.prepareStatement("DELETE FROM SETS_ALERT WHERE item_id = ?");
        ps_alert.setInt(1, itemID);
        ps_alert.executeUpdate();

        // finish by deleting item
        PreparedStatement ps_major = con.prepareStatement("DELETE FROM ITEM WHERE item_id = ?");
        ps_major.setInt(1, itemID);
        ps_major.executeUpdate();

        con.commit();
        response.sendRedirect("my_history.jsp?msg=Item Deleted Successfully");

    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (SQLException ex) {}
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
    } finally {
        if (con != null) db.closeConnection(con);
    }
%>
