<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" %>

<%
    // validate user logged in
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int userID = (int) session.getAttribute("user_id");

    Connection con = null;
    com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB();
    
    try {
        con = db.getConnection();
        con.setAutoCommit(false); // start the transaction

        // find all items user is selling, delete them and their dependencies
        List<Integer> item_ids = new ArrayList<>();
        PreparedStatement ps_get_items = con.prepareStatement("SELECT item_id FROM ITEM WHERE seller_id = ?");
        ps_get_items.setInt(1, userID);
        ResultSet rs_items = ps_get_items.executeQuery();
        while (rs_items.next()) {
            item_ids.add(rs_items.getInt("item_id"));
        }

        for (int itemId : item_ids) {
            // getting item's bids
            List<Integer> bid_ids = new ArrayList<>();
            PreparedStatement ps_getBids = con.prepareStatement("SELECT bid_id FROM RECEIVES WHERE item_id = ?");
            ps_getBids.setInt(1, itemId);
            ResultSet rs_bids = ps_getBids.executeQuery();
            while (rs_bids.next()) bid_ids.add(rs_bids.getInt("bid_id"));

            // deleting item's bids
            if (!bid_ids.isEmpty()) {
                StringBuilder temp = new StringBuilder();
                for (int id : bid_ids) temp.append(id).append(",");
                String id_list = temp.substring(0, temp.length() - 1);

                Statement statem = con.createStatement();
                statem.executeUpdate("DELETE FROM PLACES WHERE bid_id IN (" + id_list + ")");
                statem.executeUpdate("DELETE FROM RECEIVES WHERE bid_id IN (" + id_list + ")");
                statem.executeUpdate("DELETE FROM AUTOMATIC_BID WHERE bid_id IN (" + id_list + ")");
                statem.executeUpdate("DELETE FROM BID WHERE bid_id IN (" + id_list + ")");
            }

            // get rid of subtypes
            PreparedStatement psDelSub = con.prepareStatement("DELETE FROM SHIRT WHERE item_id = ?");
            psDelSub.setInt(1, itemId);
            psDelSub.executeUpdate();
            psDelSub = con.prepareStatement("DELETE FROM SHOE WHERE item_id = ?");
            psDelSub.setInt(1, itemId);
            psDelSub.executeUpdate();
            psDelSub = con.prepareStatement("DELETE FROM BAG WHERE item_id = ?");
            psDelSub.setInt(1, itemId);
            psDelSub.executeUpdate();
            
            // get rid of alerts
            psDelSub = con.prepareStatement("DELETE FROM SETS_ALERT WHERE item_id = ?");
            psDelSub.setInt(1, itemId);
            psDelSub.executeUpdate();

            // finally delete item
            psDelSub = con.prepareStatement("DELETE FROM ITEM WHERE item_id = ?");
            psDelSub.setInt(1, itemId);
            psDelSub.executeUpdate();
        }

        // delete all the bids made by this user
        List<Integer> mybid_ids = new ArrayList<>();
        PreparedStatement curr_bids = con.prepareStatement("SELECT bid_id FROM PLACES WHERE user_id = ?");
        curr_bids.setInt(1, userID);
        ResultSet rs_curr_bids = curr_bids.executeQuery();
        while (rs_curr_bids.next()) mybid_ids.add(rs_curr_bids.getInt("bid_id"));

        if (!mybid_ids.isEmpty()) {
            StringBuilder temp = new StringBuilder();
            for (int id : mybid_ids) temp.append(id).append(",");
            String id_list = temp.substring(0, temp.length() - 1);

            Statement statem = con.createStatement();
            // get rid of links
            statem.executeUpdate("DELETE FROM RECEIVES WHERE bid_id IN (" + id_list + ")");
            statem.executeUpdate("DELETE FROM PLACES WHERE bid_id IN (" + id_list + ")");
            statem.executeUpdate("DELETE FROM AUTOMATIC_BID WHERE bid_id IN (" + id_list + ")");
            // get rid of bids
            statem.executeUpdate("DELETE FROM BID WHERE bid_id IN (" + id_list + ")");
        }
        
        // delete all the alerts set by user
        PreparedStatement ps_alerts = con.prepareStatement("DELETE FROM SETS_ALERT WHERE user_id = ?");
        ps_alerts.setInt(1, userID);
        ps_alerts.executeUpdate();

        // delete from end_user table
        PreparedStatement ps_enduser = con.prepareStatement("DELETE FROM END_USER WHERE user_id = ?");
        ps_enduser.setInt(1, userID);
        ps_enduser.executeUpdate();

        // delete user
        PreparedStatement ps_user = con.prepareStatement("DELETE FROM USER WHERE user_id = ?");
        ps_user.setInt(1, userID);
        ps_user.executeUpdate();

        con.commit();
        db.closeConnection(con);
        
        // log user out
        session.invalidate();
        response.sendRedirect("login.jsp?msg=Account Deleted");

    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (SQLException ex) {}
        e.printStackTrace();
        out.println("Error deleting account: " + e.getMessage());
    }
%>
