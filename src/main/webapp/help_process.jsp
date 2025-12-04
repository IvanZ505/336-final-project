<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    // Get form data
    String reason = request.getParameter("reason");
    String actionType = request.getParameter("action_type");

    // Get current user_id from session (END_USER)
    Integer userId = (Integer) session.getAttribute("user_id");

    if (reason == null || reason.trim().isEmpty() ||
        actionType == null || actionType.trim().isEmpty() ||
        userId == null) {

        // Missing data or not logged in
        response.sendRedirect("help.jsp?err=Please+log+in+and+fill+out+all+fields");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;

    try {
        ApplicationDB db = new ApplicationDB();
        con = db.getConnection();

        if (con == null) {
            response.sendRedirect("help.jsp?err=Unable+to+connect+to+database");
            return;
        }

        String sql = "INSERT INTO SUPPORTS (reason, action_type, action_time, user_id, rep_id) "
                   + "VALUES (?, ?, NOW(), ?, NULL)";

        ps = con.prepareStatement(sql);
        ps.setString(1, reason);
        ps.setString(2, actionType);
        ps.setInt(3, userId);           // rep_id left NULL for later assignment

        int rows = ps.executeUpdate();

        if (rows > 0) {
            response.sendRedirect("help.jsp?msg=Your+request+has+been+submitted");
        } else {
            response.sendRedirect("help.jsp?err=Failed+to+submit+request");
        }

        db.closeConnection(con);

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("help.jsp?err=An+error+occurred");
    } finally {
        try {
            if (ps != null) ps.close();
        } catch (SQLException e) { e.printStackTrace(); }
    }
%>