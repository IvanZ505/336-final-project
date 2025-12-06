<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.*, com.cs336.pkg.ApplicationDB" %>

<%
    // create_auction_process.jsp deals w/ creating new auctions
    // validates inputs, inserts into tables
    
    // make sure user logged in
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection con = null;
    com.cs336.pkg.ApplicationDB db = new com.cs336.pkg.ApplicationDB(); // Declare DB outside try block

    try {
        // user id from session
        int sellerID = (int) session.getAttribute("user_id");

        // item parameters from form
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        double start_price = Double.parseDouble(request.getParameter("starting_price"));
        double bid_increment = Double.parseDouble(request.getParameter("bid_increment"));
        String secret_min_priceStr = request.getParameter("secret_min_price");
        Double secret_min_price = (secret_min_priceStr != null && !secret_min_priceStr.isEmpty()) ? Double.parseDouble(secret_min_priceStr) : null;
        
        // datetime stuff
        String auctionEndStr = request.getParameter("auction_end");
        LocalDateTime auctionEnd = LocalDateTime.parse(auctionEndStr);

        // database stuff
        con = db.getConnection();
        
        // transaction for two inserts, item and subtype
        con.setAutoCommit(false);

        // insert to the item table
        String item_query = "INSERT INTO ITEM (seller_id, title, description, starting_price, bid_increment, secret_min_price, auction_start, auction_end, status, current_bid) VALUES (?, ?, ?, ?, ?, ?, NOW(), ?, 'open', ?)";
        PreparedStatement psItem = con.prepareStatement(item_query, Statement.RETURN_GENERATED_KEYS);
        
        psItem.setInt(1, sellerID);
        psItem.setString(2, title);
        psItem.setString(3, description);
        psItem.setDouble(4, start_price);
        psItem.setDouble(5, bid_increment);
        if (secret_min_price != null) {
            psItem.setDouble(6, secret_min_price);
        } else {
            psItem.setNull(6, Types.DECIMAL);
        }
        psItem.setTimestamp(7, Timestamp.valueOf(auctionEnd));
        psItem.setDouble(8, start_price); // Initial current_bid is the starting price

        int item_rows_affected = psItem.executeUpdate();

        if (item_rows_affected == 0) {
            throw new SQLException("Creating item failed, no rows affected.");
        }

        // get generated item id
        int new_item_id = -1;
        try (ResultSet generatedKeys = psItem.getGeneratedKeys()) {
            if (generatedKeys.next()) {
                new_item_id = generatedKeys.getInt(1);
            } else {
                throw new SQLException("Creating item failed, no ID obtained.");
            }
        }

        // insert into appropriate subtype table
        String subtype_query = "";
        PreparedStatement ps_subtype = null;

        if ("shirt".equals(category)) {
            subtype_query = "INSERT INTO SHIRT (item_id, brand, color, size, `item_condition`) VALUES (?, ?, ?, ?, ?)";
            ps_subtype = con.prepareStatement(subtype_query);
            ps_subtype.setInt(1, new_item_id);
            ps_subtype.setString(2, request.getParameter("shirt-brand"));
            ps_subtype.setString(3, request.getParameter("shirt-color"));
            ps_subtype.setString(4, request.getParameter("shirt-size"));
            ps_subtype.setString(5, request.getParameter("shirt-condition"));
        } else if ("bag".equals(category)) {
            subtype_query = "INSERT INTO BAG (item_id, brand, material, color, `item_condition`) VALUES (?, ?, ?, ?, ?)";
            ps_subtype = con.prepareStatement(subtype_query);
            ps_subtype.setInt(1, new_item_id);
            ps_subtype.setString(2, request.getParameter("bag-brand"));
            ps_subtype.setString(3, request.getParameter("bag-material"));
            ps_subtype.setString(4, request.getParameter("bag-color"));
            ps_subtype.setString(5, request.getParameter("bag-condition"));
        } else if ("shoe".equals(category)) {
            subtype_query = "INSERT INTO SHOE (item_id, brand, size, `item_condition`) VALUES (?, ?, ?, ?)";
            ps_subtype = con.prepareStatement(subtype_query);
            ps_subtype.setInt(1, new_item_id);
            ps_subtype.setString(2, request.getParameter("shoe-brand"));
            
            // if size empty
            String shoe_sizeStr = request.getParameter("shoe-size");
            double shoe_size = (shoe_sizeStr != null && !shoe_sizeStr.isEmpty()) ? Double.parseDouble(shoe_sizeStr) : 0.0;
            
            ps_subtype.setDouble(3, shoe_size);
            ps_subtype.setString(4, request.getParameter("shoe-condition"));
        }

        if (ps_subtype != null) {
            ps_subtype.executeUpdate();
        }

        // transaction commit if no errors
        con.commit();
        
        // redirect to success page
        response.sendRedirect("welcome.jsp?auction_success=true");

    } catch (Exception e) {
        // if errors, no transaction 
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        e.printStackTrace();
        // goes to error page
        response.sendRedirect("create_auction.jsp?error=1");
    } finally {
        if (con != null) {
            try {
                con.setAutoCommit(true); // reset auto-commit
                con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>
