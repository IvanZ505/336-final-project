<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    if (session.getAttribute("user_id") == null) {
        request.setAttribute("error", "You must be logged in.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }

    int userId = (int) session.getAttribute("user_id");

    // Read all fields correctly
    String keywords       = trim(request.getParameter("keyword"));
    String size           = trim(request.getParameter("size"));
    String brand          = trim(request.getParameter("brand"));
    String itemCondition  = trim(request.getParameter("item_condition"));
    String color          = trim(request.getParameter("color"));
    String minP           = trim(request.getParameter("minPrice"));
    String maxP           = trim(request.getParameter("maxPrice"));

    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        String sql = 
            "INSERT INTO SETS_ALERT (user_id, keywords, size, brand, item_condition, color, min_price, max_price, is_active) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, userId);
        ps.setString(2, keywords);
        ps.setString(3, size);
        ps.setString(4, brand);
        ps.setString(5, itemCondition);
        ps.setString(6, color);
        ps.setString(7, minP);
        ps.setString(8, maxP);

        ps.executeUpdate();

        db.closeConnection(con);

        request.setAttribute("success", "Alert created successfully.");
        request.getRequestDispatcher("alerts.jsp").forward(request, response);

    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Could not create alert: " + e.getMessage());
        request.getRequestDispatcher("alerts.jsp").forward(request, response);
    }

%>

<%! 
private String trim(String s) {
    if (s == null) return null;
    s = s.trim();
    return s.isEmpty() ? null : s;
}
%>
