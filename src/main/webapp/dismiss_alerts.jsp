<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    // dismiss_alerts.jsp - Bulk dismiss logic
    
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (int) session.getAttribute("user_id");
    
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    
    try {
        // Only delete alerts that are notifications (have a message)
        // Search criteria alerts (message IS NULL) are preserved
        String sql = "DELETE FROM SETS_ALERT WHERE user_id=? AND alert_message IS NOT NULL";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, userId);
        ps.executeUpdate();
        
        response.sendRedirect("alerts.jsp?msg=All notifications dismissed.");
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("alerts.jsp?error=Failed to dismiss notifications.");
    } finally {
        db.closeConnection(con);
    }
%>
