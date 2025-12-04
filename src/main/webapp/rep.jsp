<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Customer Rep Dashboard</title>
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 50px;
    }
    .greeting {
        font-size: 32px;
        font-weight: bold;
        margin-bottom: 10px;
    }
    .stats {
        font-size: 18px;
        color: #555;
        margin-bottom: 30px;
    }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 10px; border: 1px solid #ddd; text-align: left; }
    tr:nth-child(even) { background-color: #f2f2f2; }
    th { background-color: #4CAF50; color: white; }
</style>
</head>
<body>

    <%-- nav bar --%>
    <div style="background: #eee; padding: 10px; margin-bottom: 20px;">
        <a href="rep.jsp">Dashboard</a> | 
        <a href="answer_questions.jsp">Answer Questions</a> | 
        <a href="logout.jsp">Logout</a>
    </div>

    <%
        // Get rep ID from session
        Integer repId = (Integer) session.getAttribute("repId");
        
        if (repId == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        String repName = "";
        int unansweredQuestions = 0;
        int activeAuctions = 0;
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();
            
            if (con == null) {
                out.println("<p style='color:red;'>Unable to connect to database.</p>");
            } else {
                // Get rep name
                String nameQuery = "SELECT name FROM CUSTOMER_REP WHERE rep_id = ?";
                ps = con.prepareStatement(nameQuery);
                ps.setInt(1, repId);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    repName = rs.getString("name");
                }
                rs.close();
                ps.close();
                
                // Count unanswered questions (where answer is NULL)
                String questionsQuery = "SELECT COUNT(*) AS count FROM SUPPORTS WHERE answer IS NULL";
                ps = con.prepareStatement(questionsQuery);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    unansweredQuestions = rs.getInt("count");
                }
                rs.close();
                ps.close();
                
                // Count active auctions (status = 'open' and auction hasn't ended)
                String auctionsQuery = "SELECT COUNT(*) AS count FROM ITEM WHERE status = 'open' AND auction_end > NOW()";
                ps = con.prepareStatement(auctionsQuery);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    activeAuctions = rs.getInt("count");
                }
                
                db.closeConnection(con);
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ignore) {}
        }
    %>

    <div class="greeting">Hi <%= repName %></div>
    <div class="stats">
        There are currently <%= unansweredQuestions %> unanswered questions, <%= activeAuctions %> active auctions.
    </div>

    <h3>Quick Actions</h3>
    <ul>
        <li><a href="answer_questions.jsp">View & Answer Customer Questions</a></li>
        <li><a href="browse_auctions.jsp">Browse Active Auctions</a></li>
    </ul>

</body>
</html>