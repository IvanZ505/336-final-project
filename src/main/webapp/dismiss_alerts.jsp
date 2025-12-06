<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
if (session.getAttribute("user_id") == null) return;

int userId = (int) session.getAttribute("user_id");

ApplicationDB db = new ApplicationDB();
Connection con = db.getConnection();

String sql = "UPDATE SETS_ALERT SET is_active = 0 " +
             "WHERE user_id = ? AND alert_message IS NOT NULL";

PreparedStatement ps = con.prepareStatement(sql);
ps.setInt(1, userId);
ps.executeUpdate();

ps.close();
con.close();
%>
