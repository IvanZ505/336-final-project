<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    // Must be logged in
    if (session.getAttribute("user_id") == null) {
        request.setAttribute("error", "You must be logged in.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }

    int userId = (int) session.getAttribute("user_id");

    String alertIdStr = request.getParameter("alert_id");
    
    request.removeAttribute("success");
    request.removeAttribute("error");

    if (alertIdStr == null) {
        request.setAttribute("error", "No alert selected.");
        request.getRequestDispatcher("alerts.jsp").forward(request, response);
        return;
    }

    int alertId = Integer.parseInt(alertIdStr);

    Connection con = null;
    PreparedStatement ps = null;

    try {
        ApplicationDB db = new ApplicationDB();
        con = db.getConnection();

        String sql = "DELETE FROM SETS_ALERT WHERE user_id = ? AND alert_id = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, userId);
        ps.setInt(2, alertId);

        int rows = ps.executeUpdate();

        if (rows > 0) {
            request.setAttribute("success", "Alert deleted successfully.");
        } else {
            request.setAttribute("error", "Unable to delete alert.");
        }

        request.getRequestDispatcher("alerts.jsp").forward(request, response);

    } catch (Exception e) {
        request.setAttribute("error", "Error deleting alert: " + e.getMessage());
        request.getRequestDispatcher("alerts.jsp").forward(request, response);
    } finally {
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
%>
