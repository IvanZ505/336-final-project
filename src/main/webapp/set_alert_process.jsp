<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    if (session.getAttribute("user_id") == null) {
        request.setAttribute("error", "You must be logged in.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }

    int userId = (int) session.getAttribute("user_id");

    // Get and normalize parameters
    String keywords = request.getParameter("keyword");
    String category = request.getParameter("category");
    String minP     = request.getParameter("minPrice");
    String maxP     = request.getParameter("maxPrice");

    keywords = (keywords == null || keywords.trim().isEmpty()) ? null : keywords.trim();
    category = (category == null || category.trim().isEmpty()) ? null : category.trim();
    minP     = (minP == null || minP.trim().isEmpty()) ? null : minP;
    maxP     = (maxP == null || maxP.trim().isEmpty()) ? null : maxP;

    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        String sql =
            "INSERT INTO SETS_ALERT (user_id, keywords, condition, color, size, brand, min_price, max_price, is_active) " +
            "VALUES (?, ?, ?, NULL, NULL, NULL, ?, ?, 1)";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, userId);
        ps.setString(2, keywords);
        ps.setString(3, category);  // store category in condition column
        ps.setString(4, minP);
        ps.setString(5, maxP);

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
