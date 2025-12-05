<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Set Alert</title>
<link rel="stylesheet" type="text/css" href="style.css">
<style>
    label { color:white; display:block; margin-top:8px; }
    input, select { margin:4px 0; }
</style>
</head>
<body>

    <div class="navbar">
        <a href="welcome.jsp">Home</a> | 
        <a href="create_auction.jsp">Sell Item</a> | 
        <a href="browse_auctions.jsp">Browse Auctions</a> | 
        <a href="help.jsp">Help</a> |
        <a href="search.jsp">Search</a> |
        <a href="alerts.jsp">Alerts</a> |
        <a href="logout.jsp">Logout</a> |
    </div>

<h2>Create Alert</h2>

<form action="set_alert_process.jsp" method="post">

    <label>Keyword:</label>
    <input type="text" name="keyword">

    <label>Size:</label>
    <input type="text" name="size" placeholder="e.g. M or 9.5">

    <label>Brand:</label>
    <input type="text" name="brand">

    <label>Condition:</label>
    <input type="text" name="item_condition" placeholder="e.g. new, used">

    <label>Color:</label>
    <input type="text" name="color">

    <label>Min Price:</label>
    <input type="number" step="0.01" name="minPrice">

    <label>Max Price:</label>
    <input type="number" step="0.01" name="maxPrice">

    <br><br>
    <input type="submit" value="Create Alert">
</form>

</body>
</html>
