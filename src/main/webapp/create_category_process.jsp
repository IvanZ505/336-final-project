<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    // Check admin authentication
    Integer adminId = (Integer) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("login.jsp?error=1");
        return;
    }

    // Get form parameters
    String categoryName = request.getParameter("category_name");
    
    if (categoryName == null || categoryName.trim().isEmpty()) {
        response.sendRedirect("create_category.jsp?err=Invalid+form+data");
        return;
    }
    
    // Store original name for display
    String displayName = categoryName.trim();
    // Convert to uppercase for table name
    String tableName = categoryName.trim().toUpperCase();
    
    // Validate category name (only letters and underscores)
    if (!tableName.matches("^[A-Z_]+$")) {
        response.sendRedirect("create_category.jsp?err=Invalid+category+name.+Use+only+letters+and+underscores.");
        return;
    }
    
    Connection con = null;
    Statement stmt = null;
    PreparedStatement ps = null;
    
    try {
        ApplicationDB db = new ApplicationDB();
        con = db.getConnection();
        
        if (con == null) {
            response.sendRedirect("create_category.jsp?err=Database+connection+failed");
            return;
        }
        
        // Check if category already exists in ITEM_CATEGORIES
        ps = con.prepareStatement("SELECT category_id FROM ITEM_CATEGORIES WHERE table_name = ?");
        ps.setString(1, tableName);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            rs.close();
            ps.close();
            db.closeConnection(con);
            response.sendRedirect("create_category.jsp?err=Category+already+exists");
            return;
        }
        rs.close();
        ps.close();
        
        stmt = con.createStatement();
        
        // Build CREATE TABLE SQL
        StringBuilder createTableSQL = new StringBuilder();
        createTableSQL.append("CREATE TABLE `").append(tableName).append("` (");
        createTableSQL.append("`item_id` INT PRIMARY KEY");

        // Add foreign key constraint
        createTableSQL.append(", CONSTRAINT `fk_").append(tableName.toLowerCase()).append("_item` ");
        createTableSQL.append("FOREIGN KEY (`item_id`) REFERENCES `ITEM`(`item_id`) ON DELETE CASCADE");
        createTableSQL.append(")");
        
        // Execute CREATE TABLE
        stmt.executeUpdate(createTableSQL.toString());
        stmt.close();
        
        // Insert into ITEM_CATEGORIES table
        ps = con.prepareStatement("INSERT INTO ITEM_CATEGORIES (category_name, table_name) VALUES (?, ?)");
        ps.setString(1, displayName);
        ps.setString(2, tableName);
        ps.executeUpdate();
        ps.close();
        
        db.closeConnection(con);
        
        response.sendRedirect("create_category.jsp?msg=Category+" + tableName + "+created+successfully!");
        
    } catch (SQLSyntaxErrorException e) {
        String error = e.getMessage();
        if (error.contains("already exists")) {
            response.sendRedirect("create_category.jsp?err=Category+table+already+exists");
        } else {
            response.sendRedirect("create_category.jsp?err=SQL+error:+" + java.net.URLEncoder.encode(error, "UTF-8"));
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("create_category.jsp?err=Error+creating+category:+" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
    } finally {
        try {
            if (ps != null) ps.close();
            if (stmt != null) stmt.close();
            if (con != null) con.close();
        } catch (SQLException ignore) {}
    }
%>
