<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Answer Customer Questions</title>
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 50px;
    }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 10px; border: 1px solid #ddd; text-align: left; }
    tr:nth-child(even) { background-color: #f2f2f2; }
    th { background-color: #4CAF50; color: white; }
    textarea { width: 100%; height: 80px; }
    .submit-btn {
        background-color: #4CAF50;
        color: white;
        padding: 8px 15px;
        border: none;
        cursor: pointer;
    }
    .submit-btn:hover {
        background-color: #45a049;
    }
</style>
</head>
<body>

    <%-- nav bar --%>
    <div style="background: #eee; padding: 10px; margin-bottom: 20px;">
        <a href="rep.jsp">Dashboard</a> | 
        <a href="answer_questions.jsp">Answer Questions</a> | 
        <a href="logout.jsp">Logout</a>
    </div>

    <h2>Unanswered Customer Questions</h2>

    <%
        // Get rep ID from session
        Integer repId = (Integer) session.getAttribute("repId");
        
        if (repId == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        String msg = request.getParameter("msg");
        String err = request.getParameter("err");
        if (msg != null) {
            out.println("<p style='color:green;'>" + msg + "</p>");
        }
        if (err != null) {
            out.println("<p style='color:red;'>" + err + "</p>");
        }
    %>

    <table>
        <tr>
            <th>Log ID</th>
            <th>User ID</th>
            <th>Question</th>
            <th>Type</th>
            <th>Submitted</th>
            <th>Your Answer</th>
            <th>Action</th>
        </tr>

        <%
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                ApplicationDB db = new ApplicationDB();
                con = db.getConnection();

                if (con == null) {
                    out.println("<tr><td colspan='7' style='color:red;'>Unable to connect to database.</td></tr>");
                } else {
                    // Get all unanswered questions (answer IS NULL)
                    String query = "SELECT log_id, user_id, reason, action_type, action_time " +
                                   "FROM SUPPORTS " +
                                   "WHERE answer IS NULL " +
                                   "ORDER BY action_time ASC"; // Oldest first
                    
                    ps = con.prepareStatement(query);
                    rs = ps.executeQuery();

                    boolean hasQuestions = false;
                    while (rs.next()) {
                        hasQuestions = true;
                        int logId = rs.getInt("log_id");
                        int userId = rs.getInt("user_id");
                        String reason = rs.getString("reason");
                        String actionType = rs.getString("action_type");
                        Timestamp actionTime = rs.getTimestamp("action_time");
        %>
            <tr>
                <td><%= logId %></td>
                <td><%= userId %></td>
                <td><%= reason %></td>
                <td><%= actionType %></td>
                <td><%= actionTime %></td>
                <td>
                    <form action="submit_qanswer.jsp" method="post">
                        <input type="hidden" name="log_id" value="<%= logId %>">
                        <textarea name="answer" required placeholder="Type your answer here..."></textarea>
                </td>
                <td>
                        <input type="submit" value="Submit Answer" class="submit-btn">
                    </form>
                </td>
            </tr>
        <%
                    } // End while loop

                    if (!hasQuestions) {
        %>
            <tr>
                <td colspan="7">No unanswered questions at this time. Great job!</td>
            </tr>
        <%
                    }

                    db.closeConnection(con);
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='7' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                } catch (SQLException ignore) {}
            }
        %>
    </table>

</body>
</html>
