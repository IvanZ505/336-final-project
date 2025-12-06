<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.sql.*, java.util.*, com.cs336.pkg.ApplicationDB" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Welcome</title>
<script>
    function confirmDelete() {
        return confirm("Are you sure you want to delete your account? This action can't be undone");
    }
</script>
<link rel="stylesheet" type="text/css" href="style.css">
</head>

<body>

<%
    // Redirect if not logged in
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    int userId = (session.getAttribute("user_id") != null)
                 ? (int) session.getAttribute("user_id")
                 : -1;
%>

<h2>Welcome, <%= username %>!</h2>

<h3>Actions</h3>
<ul>
    <li><a href="browse_auctions.jsp">Browse Active Auctions</a></li>
    <li><a href="create_auction.jsp">Sell an Item</a></li>
    <li><a href="my_history.jsp">Bids & Sales History</a></li>
    <li><a href="help.jsp">Get Customer Service Help</a></li>
    <li><a href="search.jsp">Search</a></li>
    <li><a href="alerts.jsp">Alerts</a></li>
</ul>

<%
/* ============================================================
   PART 1 — AUTO-GENERATE ITEM MATCH ALERTS (NEW FEATURE)
   ============================================================ */

ApplicationDB dbMatch = new ApplicationDB();
Connection conMatch = dbMatch.getConnection();

// Load only rule-style alerts (alert_message IS NULL)
String sqlRules = "SELECT * FROM SETS_ALERT WHERE user_id=? AND alert_message IS NULL AND is_active=1";
PreparedStatement psR = conMatch.prepareStatement(sqlRules);
psR.setInt(1, userId);
ResultSet rsR = psR.executeQuery();

List<String> newlyCreatedAlerts = new ArrayList<>();

while (rsR.next()) {
    int aid     = rsR.getInt("alert_id");
    String kw   = rsR.getString("keywords");
    String size = rsR.getString("size");
    String brand= rsR.getString("brand");
    String cond = rsR.getString("item_condition");
    String color= rsR.getString("color");

    Float minP = (rsR.getObject("min_price") == null ? null : ((Number)rsR.getObject("min_price")).floatValue());
    Float maxP = (rsR.getObject("max_price") == null ? null : ((Number)rsR.getObject("max_price")).floatValue());

    // Build dynamic query
    String q =
        "SELECT DISTINCT i.item_id, i.title, i.current_bid " +
        "FROM ITEM i " +
        "LEFT JOIN SHIRT s ON i.item_id = s.item_id " +
        "LEFT JOIN BAG b ON i.item_id = b.item_id " +
        "LEFT JOIN SHOE sh ON i.item_id = sh.item_id " +
        "WHERE i.auction_end > NOW() ";

    List<Object> params = new ArrayList<>();

    if (kw != null)   { q += "AND (i.title LIKE ? OR i.description LIKE ?) "; params.add("%"+kw+"%"); params.add("%"+kw+"%"); }
    if (brand != null){ q += "AND (s.brand=? OR b.brand=? OR sh.brand=? ) "; params.add(brand); params.add(brand); params.add(brand); }
    if (cond != null) { q += "AND (s.item_condition=? OR b.item_condition=? OR sh.item_condition=? ) "; params.add(cond); params.add(cond); params.add(cond); }
    if (color != null){ q += "AND (s.color=? OR b.color=? ) "; params.add(color); params.add(color); }
    if (size != null) { q += "AND (s.size=? OR sh.size=? ) "; params.add(size); params.add(size); }
    if (minP != null) { q += "AND COALESCE(i.current_bid, i.starting_price) >= ? "; params.add(minP); }
    if (maxP != null) { q += "AND COALESCE(i.current_bid, i.starting_price) <= ? "; params.add(maxP); }

    PreparedStatement psM = conMatch.prepareStatement(q);
    for (int i = 0; i < params.size(); i++) psM.setObject(i+1, params.get(i));

    ResultSet m = psM.executeQuery();

    while (m.next()) {
        String t = m.getString("title");
        double cb = m.getDouble("current_bid");

        String alertMsg = "🔔 New item matching your alert: " + t +
                          " ($" + String.format("%.2f", cb) + ")";

        // Prevent duplicates
        String chk =
            "SELECT alert_id FROM SETS_ALERT WHERE user_id=? AND alert_message=? LIMIT 1";
        PreparedStatement psC = conMatch.prepareStatement(chk);
        psC.setInt(1, userId);
        psC.setString(2, alertMsg);
        ResultSet rc = psC.executeQuery();

        boolean exists = rc.next();

        rc.close();
        psC.close();

        if (!exists) {
            PreparedStatement ins =
                conMatch.prepareStatement("INSERT INTO SETS_ALERT (user_id, alert_message, is_active) VALUES (?, ?, 1)");
            ins.setInt(1, userId);
            ins.setString(2, alertMsg);
            ins.executeUpdate();
            ins.close();

            newlyCreatedAlerts.add(alertMsg);
        }
    }
}

rsR.close();
psR.close();
conMatch.close();

/* ============================================================
   PART 2 — FETCH ALL ALERT MESSAGES FOR POPUP
   ============================================================ */

String alertSqlPopup =
    "SELECT alert_id, alert_message FROM SETS_ALERT " +
    "WHERE user_id = ? AND alert_message IS NOT NULL AND is_active = 1";

ApplicationDB db2 = new ApplicationDB();
Connection con2 = db2.getConnection();
PreparedStatement psPopup = con2.prepareStatement(alertSqlPopup);
psPopup.setInt(1, userId);
ResultSet rsPopup = psPopup.executeQuery();

List<Integer> popupIds = new ArrayList<>();
List<String> popupMsgs = new ArrayList<>();

while (rsPopup.next()) {
    popupIds.add(rsPopup.getInt("alert_id"));
    popupMsgs.add(rsPopup.getString("alert_message"));
}

rsPopup.close();
psPopup.close();
con2.close();
%>

<!-- Dismiss script -->
<script>
function dismissAlerts() {
    fetch("dismiss_alerts.jsp")
        .then(() => {
            let el = document.getElementById("alertPopup");
            if (el) el.style.display = "none";
        });
}
</script>

<% if (!popupMsgs.isEmpty()) { %>
<div id="alertPopup" style="
    position: fixed;
    top: 20px; right: 20px;
    background: #ffdd57;
    color: #000;
    padding: 15px;
    border-radius: 8px;
    box-shadow: 0 0 10px #000;
    z-index: 9999;
">
    <strong>New Alerts:</strong><br>
    <ul>
        <% for (String m : popupMsgs) { %>
            <li><%= m %></li>
        <% } %>
    </ul>

    <button onclick="dismissAlerts()" 
            style="margin-top:10px; padding:5px 10px;">
        Dismiss All
    </button>
</div>
<% } %>

<br>
<p><a href="logout.jsp">Logout</a></p>

<br><br>

<!-- Delete Account -->
<form action="delete_account_process.jsp" method="post"
      onsubmit="return confirmDelete()" style="display:inline;">
    <input type="submit" value="Delete Account"
           style="background:none;border:none;color:red;
                  text-decoration:underline;cursor:pointer;
                  padding:0;font-size:0.9em;">
</form>

</body>
</html>
