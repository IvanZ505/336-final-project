<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Help & Support</title>
<link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>

    <%-- nav bar --%>
    <div class="navbar">
        <a href="welcome.jsp">Home</a> | 
        <a href="create_auction.jsp">Sell Item</a> | 
        <a href="browse_auctions.jsp">Browse Auctions</a> | 
        <a href="help.jsp">Help</a> |
        <a href="search.jsp">Search</a> |
        <a href="alerts.jsp">Alerts</a> |
        <a href="logout.jsp">Logout</a> |
    </div>


    <h2>Contact Customer Support</h2>
    <p>Please describe your question below. A customer representative will respond as soon as possible.</p>

    <form action="help_process.jsp" method="post">
        <table>
            <tr>
                <th>Question</th>
                <td>
                    <textarea name="reason" required></textarea>
                </td>
            </tr>
            <tr>
                <th>Type of Request</th>
                <td>
                    <select name="action_type" required>
                        <option value="">-- Select --</option>
                        <option value="issue">Issue</option>
                        <option value="billing">Billing</option>
                        <option value="account">Account</option>
                        <option value="other">Other</option>
                    </select>
                </td>
            </tr>
        </table>
        <br>
        <input type="submit" value="Submit Request">
    </form>

    <% 
        String msg = request.getParameter("msg");
        String err = request.getParameter("err");
        if (msg != null) {
            out.println("<p style='color:green;'>" + msg + "</p>");
        }
        if (err != null) {
            out.println("<p style='color:red;'>" + err + "</p>");
        }
    %>
<hr>

    <h2>My Questions</h2>

    <%
        Integer userId = (Integer) session.getAttribute("user_id"); // END_USER id

        if (userId == null) {
            out.println("<p>You must be logged in to see your questions.</p>");
        } else {
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            try {
                ApplicationDB db = new ApplicationDB();
                con = db.getConnection();

                if (con == null) {
                    out.println("<p style='color:red;'>Unable to connect to database.</p>");
                } else {
                	String sql = "SELECT s.log_id, s.reason, s.answer, s.action_type, s.action_time, r.name " +
                            "FROM SUPPORTS s " +
                            "LEFT JOIN CUSTOMER_REP r ON s.rep_id = r.rep_id " +
                            "WHERE s.user_id = ? " +
                            "ORDER BY s.action_time DESC";
                    ps = con.prepareStatement(sql);
                    ps.setInt(1, userId);
                    rs = ps.executeQuery();
    %>
                    <table>
                        <tr>
                            <th>Log ID</th>
                            <th>Question</th>
                            <th>Answer</th>
                            <th>Type</th>
                            <th>Created At</th>
                            <th>Assigned Rep</th>
                        </tr>
                        <%
                            boolean hasRows = false;
                            while (rs.next()) {
                                hasRows = true;
                                int logId = rs.getInt("log_id");
                                String reasonText = rs.getString("reason");
                                String answerText = rs.getString("answer");
                                String type = rs.getString("action_type");
                                Timestamp created = rs.getTimestamp("action_time");
                                String repName = rs.getString("name");
                        %>
                            <tr>
                                <td><%= logId %></td>
                                <td><%= reasonText %></td>
                                <td><%= (answerText == null ? "No answer yet" : answerText) %></td>
                                <td><%= type %></td>
                                <td><%= created %></td>
                                <td><%= (repName == null ? "Unassigned" : repName) %></td>
                            </tr>
                        <%
                            }
                            if (!hasRows) {
                        %>
                            <tr>
                                <td colspan="5">You have not submitted any questions yet.</td>
                            </tr>
                        <%
                            }
                        %>
                    </table>
    <%
                    db.closeConnection(con);
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error loading your questions: " + e.getMessage() + "</p>");
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                } catch (SQLException ignore) {}
            }
        }
    %>
</body>
</html>