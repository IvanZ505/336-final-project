<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
</head>
<body>

<%
    // see if user logged in
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
    } else {
        String username = (String) session.getAttribute("username");
%>
    <h2>Welcome, <%= username %>!</h2>
    
    <h3>Actions</h3>
    <ul>
        <li><a href="browse_auctions.jsp">Browse Active Auctions</a></li>
        <li><a href="create_auction.jsp">Sell an Item</a></li>
        <li><a href="my_history.jsp">Bids & Sales History</a></li>
    </ul>
    
    <br>
    <p>
        <a href="logout.jsp">Logout</a>
    </p>
    
    <br><br>
    <!-- link to delete account -->
    <form action="delete_account_process.jsp" method="post" onsubmit="return confirmDelete()" style="display: inline;">
        <input type="submit" value="Delete Account" style="background: none; border: none; color: red; text-decoration: underline; cursor: pointer; padding: 0; font-size: 0.9em;">
    </form>

<%
    }
%>

</body>
</html>
