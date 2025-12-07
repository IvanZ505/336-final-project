<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Create Auction</title>
<script>
    //dynamic form fields depending on category of item chosen
    function showSubtypeFields() {
        // Hide all category field containers
        var containers = document.querySelectorAll('[id$="-fields"]');
        for (var i = 0; i < containers.length; i++) {
            containers[i].style.display = 'none';
        }

        // Get selected category table name
        var categorySelect = document.getElementById('category');
        var selectedOption = categorySelect.options[categorySelect.selectedIndex];
        var tableName = selectedOption.getAttribute('data-table');

        // Show the corresponding div (convert to lowercase and add -fields)
        if (tableName) {
            var fieldId = tableName.toLowerCase() + '-fields';
            var fieldDiv = document.getElementById(fieldId);
            if (fieldDiv) {
                fieldDiv.style.display = 'block';
            }
        }
    }
</script>
<style>
    /* styling stuff for differentiating between fields that are required and optional */
    .required { color: red; }
    .optional { font-size: 0.9em; color: #666; }
    .error-msg { color: red; font-weight: bold; background-color: #ffe6e6; padding: 10px; border: 1px solid red; margin-bottom: 15px; }
	
	* {
	    margin: 0;
	    padding: 0;
	    box-sizing: border-box;
	}
	
	body {
		padding: 2px 10px;
		margin: 5px 10px;
	    font-family: 'Arial', sans-serif;
	    background: linear-gradient(135deg, #1e1e1e 0%, #2d2d2d 100%);
	    min-height: 100vh;
	    color: #ffffff;
	}
	
	input,
	select,
	textarea {
	    padding: 15px 0;
	    background: transparent;
	    border: none;
	    border-bottom: 2px solid rgba(255, 255, 255, 0.3);
	    color: #ffffff;
	    font-size: 16px;
	    outline: none;
	    transition: border-color 0.3s ease;
	}
	
	input::-webkit-outer-spin-button,
	input::-webkit-inner-spin-button {
	  -webkit-appearance: none;
	  margin: 0;
	}
	
	input[type="number"] {
	  -moz-appearance: textfield;
	}
</style>
</head>
<body onload="showSubtypeFields()">

    <%-- make sure user logged in, if not direct to login --%>
    <% if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return; 
    } %>

    <h2>Create a New Auction</h2>

    <%-- see if url has error, if error show a nice error message  --%>
    <% if ("1".equals(request.getParameter("error"))) { %>
        <div class="error-msg">
            Error while trying to create auction. Please check your inputs and then try again. <br>
            Make sure you're a valid seller and the database is running.
        </div>
    <% } %>

    <%-- where the main form is --%>
    <form action="create_auction_process.jsp" method="post">
        <h4>Item Details</h4>
        <label for="title">Title <span class="required">*</span>:</label><br>
        <input type="text" id="title" name="title" required size="50"><br><br>

        <label for="description">Description <span class="optional">(Optional)</span>:</label><br>
        <textarea id="description" name="description" rows="4" cols="50"></textarea><br><br>

        <%-- selection of category, dynamically loaded from database --%>
        <label for="category">Category <span class="required">*</span>:</label>
        <select id="category" name="category" onchange="showSubtypeFields()" required>
            <option value="">--Select a Category--</option>
            <%
                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                
                try {
                    ApplicationDB db = new ApplicationDB();
                    con = db.getConnection();
                    
                    // Get all active categories
                    String categoryQuery = "SELECT category_id, category_name, table_name FROM ITEM_CATEGORIES WHERE is_active = 1 ORDER BY category_name";
                    ps = con.prepareStatement(categoryQuery);
                    rs = ps.executeQuery();
                    
                    while (rs.next()) {
                        int categoryId = rs.getInt("category_id");
                        String categoryName = rs.getString("category_name");
                        String tableName = rs.getString("table_name");
            %>
                        <option value="<%= categoryId %>" data-table="<%= tableName %>"><%= categoryName %></option>
            <%
                    }
                    
                    db.closeConnection(con);
                } catch (Exception e) {
                    out.println("<option value=''>Error loading categories</option>");
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (ps != null) ps.close();
                    } catch (SQLException ignore) {}
                }
            %>
        </select><br><br>

        <%-- the dynamic fields that are usually hidden, shown depending on what selected --%>

        <%-- fields for shirts --%>
        <div id="shirt-fields" style="display: none;">
            <label for="shirt-brand">Brand <span class="optional">(Optional)</span>:</label>
            <input type="text" id="shirt-brand" name="shirt-brand"><br><br>
            
            <label for="shirt-color">Color <span class="optional">(Optional)</span>:</label>
            <select id="shirt-color" name="shirt-color">
                <option value="">Select Color</option>
                <option value="Red">Red</option>
                <option value="Orange">Orange</option>
                <option value="Yellow">Yellow</option>
                <option value="Green">Green</option>
                <option value="Blue">Blue</option>
                <option value="Purple">Purple</option>
                <option value="Black">Black</option>
                <option value="White">White</option>
                <option value="Grey">Grey</option>
                <option value="Beige">Beige</option>
                <option value="Brown">Brown</option>
                <option value="Pink">Pink</option>
                <option value="Gold">Gold</option>
                <option value="Silver">Silver</option>
                <option value="Multicolor">Multicolor</option>
            </select><br><br>
            
            <label for="shirt-size">Size <span class="optional">(Optional)</span>:</label>
            <select id="shirt-size" name="shirt-size">
                <option value="">Select Size</option>
                <option value="XS">XS</option>
                <option value="S">S</option>
                <option value="M">M</option>
                <option value="L">L</option>
                <option value="XL">XL</option>
                <option value="XXL">XXL</option>
            </select><br><br>
            
            <label for="shirt-condition">Condition <span class="optional">(Optional)</span>:</label>
            <select id="shirt-condition" name="shirt-condition">
                <option value="">Select Condition</option>
                <option value="New">New</option>
                <option value="Like New">Like New</option>
                <option value="Good">Good</option>
                <option value="Fair">Fair</option>
                <option value="Poor">Poor</option>
            </select><br><br>
        </div>

        <%-- fields for bags--%>
        <div id="bag-fields" style="display: none;">
            <label for="bag-brand">Brand <span class="optional">(Optional)</span>:</label>
            <input type="text" id="bag-brand" name="bag-brand"><br><br>
            
            <label for="bag-material">Material <span class="optional">(Optional)</span>:</label>
            <input type="text" id="bag-material" name="bag-material"><br><br>
            
            <label for="bag-color">Color <span class="optional">(Optional)</span>:</label>
            <select id="bag-color" name="bag-color">
                <option value="">Select Color</option>
                <option value="Red">Red</option>
                <option value="Orange">Orange</option>
                <option value="Yellow">Yellow</option>
                <option value="Green">Green</option>
                <option value="Blue">Blue</option>
                <option value="Purple">Purple</option>
                <option value="Black">Black</option>
                <option value="White">White</option>
                <option value="Grey">Grey</option>
                <option value="Beige">Beige</option>
                <option value="Brown">Brown</option>
                <option value="Pink">Pink</option>
                <option value="Gold">Gold</option>
                <option value="Silver">Silver</option>
                <option value="Multicolor">Multicolor</option>
            </select><br><br>
            
            <label for="bag-condition">Condition <span class="optional">(Optional)</span>:</label>
            <select id="bag-condition" name="bag-condition">
                <option value="">Select Condition</option>
                <option value="New">New</option>
                <option value="Like New">Like New</option>
                <option value="Good">Good</option>
                <option value="Fair">Fair</option>
                <option value="Poor">Poor</option>
            </select><br><br>
        </div>

        <%-- fields for shoes --%>
        <div id="shoe-fields" style="display: none;">
            <label for="shoe-brand">Brand <span class="optional">(Optional)</span>:</label>
            <input type="text" id="shoe-brand" name="shoe-brand"><br><br>
            
            <label for="shoe-size">Size <span class="optional">(Optional)</span>:</label>
            <select id="shoe-size" name="shoe-size">
                <option value="">Select Size</option>
                <option value="5">5</option>
                <option value="5.5">5.5</option>
                <option value="6">6</option>
                <option value="6.5">6.5</option>
                <option value="7">7</option>
                <option value="7.5">7.5</option>
                <option value="8">8</option>
                <option value="8.5">8.5</option>
                <option value="9">9</option>
                <option value="9.5">9.5</option>
                <option value="10">10</option>
                <option value="10.5">10.5</option>
                <option value="11">11</option>
                <option value="11.5">11.5</option>
                <option value="12">12</option>
                <option value="13">13</option>
            </select><br><br>
            
            <label for="shoe-condition">Condition <span class="optional">(Optional)</span>:</label>
            <select id="shoe-condition" name="shoe-condition">
                <option value="">Select Condition</option>
                <option value="New">New</option>
                <option value="Like New">Like New</option>
                <option value="Good">Good</option>
                <option value="Fair">Fair</option>
                <option value="Poor">Poor</option>
            </select><br><br>
        </div>

        <h4>Auction Settings</h4>
        <label for="starting_price">Starting Price ($) <span class="required">*</span>:</label>
        <input type="number" id="starting_price" name="starting_price" step="0.01" min="0.01" required><br><br>

        <label for="bid_increment">Bid Increment ($) <span class="required">*</span>:</label>
        <input type="number" id="bid_increment" name="bid_increment" step="0.01" min="0.01" required><br><br>

        <label for="secret_min_price">Reserve Price ($) <span class="optional">(Optional)</span>:</label>
        <input type="number" id="secret_min_price" name="secret_min_price" step="0.01" min="0.01"><br><br>

        <label for="auction_end">Auction End (Date and Time) <span class="required">*</span>:</label>
        <input type="datetime-local" id="auction_end" name="auction_end" required><br><br>

        <input type="submit" value="Create Auction" style="display:inline-block; 
        	background:#fff; color:#000; padding:8px 14px; border-radius:6px; text-decoration:none; font-weight:bold;">
    </form>
    
    <br>
	<a href="welcome.jsp" 
	   style="display:inline-block; background:#fff; color:#000; padding:8px 14px; 
	          border-radius:6px; text-decoration:none; font-weight:bold;">
	   Back to Welcome Page
	</a>

</body>
</html>
