<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Create Category</title>
<link rel="stylesheet" type="text/css" href="style.css">
<style>
    /* Additional custom styles specific to this page */
    .attribute-row {
        background: rgba(255, 255, 255, 0.05);
        padding: 25px;
        border-radius: 10px;
        margin: 20px 0;
        border: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    .attribute-row h4 {
        margin-top: 0;
        color: #51cf66;
        font-size: 16px;
        letter-spacing: 1px;
    }
    
    .attribute-row label {
        margin: 15px 0 5px 0;
    }
    
    .attribute-row input,
    .attribute-row select {
        margin-bottom: 15px;
    }
    
    .remove-btn {
        background: transparent;
        color: #ff6b6b;
        border: 2px solid #ff6b6b;
        border-radius: 50px;
        padding: 8px 20px;
        cursor: pointer;
        font-size: 12px;
        font-weight: bold;
        letter-spacing: 1px;
        text-transform: uppercase;
        transition: all 0.3s ease;
        margin-top: 10px;
    }
    
    .remove-btn:hover {
        background: #ff6b6b;
        color: #ffffff;
        transform: translateY(-2px);
    }
    
    .add-attribute-btn {
        background: transparent;
        color: #51cf66;
        border: 2px solid #51cf66;
        border-radius: 50px;
        padding: 12px 30px;
        cursor: pointer;
        font-size: 14px;
        font-weight: bold;
        letter-spacing: 1px;
        text-transform: uppercase;
        transition: all 0.3s ease;
        margin: 25px 0;
        display: inline-block;
    }
    
    .add-attribute-btn:hover {
        background: #51cf66;
        color: #2d2d2d;
        transform: translateY(-2px);
    }
    
    #attributesContainer {
        margin: 30px 0;
    }
    
    .info-box {
        background: rgba(81, 207, 102, 0.1);
        border: 1px solid rgba(81, 207, 102, 0.3);
        border-radius: 10px;
        padding: 20px;
        margin: 20px 0;
        color: rgba(255, 255, 255, 0.8);
        font-size: 14px;
        line-height: 1.6;
    }
    
    .info-box strong {
        color: #51cf66;
    }
    
    .info-box code {
        background: rgba(255, 255, 255, 0.1);
        padding: 2px 8px;
        border-radius: 4px;
        font-family: 'Courier New', monospace;
        color: #ffffff;
    }
    
    .description {
        text-align: center;
        color: rgba(255, 255, 255, 0.7);
        margin-bottom: 40px;
        font-size: 15px;
        line-height: 1.6;
        max-width: 700px;
        margin-left: auto;
        margin-right: auto;
    }
    
    .page-title {
        text-align: center;
        font-size: 36px;
        letter-spacing: 3px;
        text-transform: uppercase;
        margin-bottom: 20px;
        background: linear-gradient(135deg, #ffffff 0%, #51cf66 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    
    .section-title {
        margin-top: 50px;
        margin-bottom: 20px;
        color: #51cf66;
        font-size: 22px;
        letter-spacing: 2px;
        text-transform: uppercase;
        padding-bottom: 10px;
        border-bottom: 2px solid rgba(81, 207, 102, 0.3);
    }
</style>
<script>
    let attributeCount = 0;
    const activeAttributes = new Set(); // Track active attributes
    
    function addAttribute() {
        attributeCount++;
        activeAttributes.add(attributeCount);
        
        const container = document.getElementById('attributesContainer');
        const attributeDiv = document.createElement('div');
        attributeDiv.className = 'attribute-row';
        attributeDiv.id = 'attribute-' + attributeCount;
        
        attributeDiv.innerHTML = 
            '<h4>Attribute ' + attributeCount + '</h4>' +
            '<label>Attribute Name:</label>' +
            '<input type="text" name="attr_name_' + attributeCount + '" placeholder="e.g., material, pattern, style" required>' +
            '<label>Data Type:</label>' +
            '<select name="attr_type_' + attributeCount + '" required>' +
                '<option value="">-- Select Type --</option>' +
                '<option value="VARCHAR(20)">Text (Short - up to 20 chars)</option>' +
                '<option value="VARCHAR(50)">Text (Medium - up to 50 chars)</option>' +
                '<option value="VARCHAR(100)">Text (Long - up to 100 chars)</option>' +
                '<option value="INT">Number (Integer)</option>' +
                '<option value="DECIMAL(5,2)">Decimal (e.g., 12.50)</option>' +
                '<option value="DATE">Date</option>' +
            '</select>' +
            '<label>Required Field:</label>' +
            '<select name="attr_required_' + attributeCount + '">' +
                '<option value="NULL">No (Optional)</option>' +
                '<option value="NOT NULL">Yes (Required)</option>' +
            '</select>' +
            '<button type="button" class="remove-btn" onclick="removeAttribute(' + attributeCount + ')">Remove Attribute</button>';
        
        container.appendChild(attributeDiv);
        updateAttributeCount();
    }
    
    function removeAttribute(id) {
        const element = document.getElementById('attribute-' + id);
        if (element) {
            element.remove();
            activeAttributes.delete(id);
        }
        updateAttributeCount();
    }
    
    function updateAttributeCount() {
        // Store both total count and active attribute IDs
        document.getElementById('total_attributes').value = attributeCount;
        document.getElementById('active_attributes').value = Array.from(activeAttributes).join(',');
    }
    
    function validateForm() {
        const categoryName = document.getElementById('category_name').value.trim();
        
        if (!categoryName) {
            alert('Please enter a category name');
            return false;
        }
        
        // Check if category name is alphanumeric
        if (!/^[a-zA-Z_]+$/.test(categoryName)) {
            alert('Category name must contain only letters and underscores (no spaces or special characters)');
            return false;
        }
        
        return confirm('Are you sure you want to create this category? This will create a new table in the database.');
    }
</script>
</head>
<body>

    <%-- Nav bar --%>
    <nav class="navbar">
        <div class="navbar-inner">
            <a href="admin.jsp" class="navbar-brand">Admin Portal</a>
            <div class="navbar-links">
                <a href="admin.jsp">Dashboard</a>
                <a href="create_category.jsp">Create Category</a>
                <a href="logout.jsp">Logout</a>
            </div>
        </div>
    </nav>

    <%
        // Check admin authentication
        Integer adminId = (Integer) session.getAttribute("adminId");
        if (adminId == null) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        String msg = request.getParameter("msg");
        String err = request.getParameter("err");
        if (msg != null) {
            out.println("<p style='color:#51cf66; text-align:center; margin: 20px;'>" + msg + "</p>");
        }
        if (err != null) {
            out.println("<p style='color:#ff6b6b; text-align:center; margin: 20px;'>" + err + "</p>");
        }
    %>

    <div class="container">
        <h2 class="page-title">Create New Category</h2>
        <p class="description">
            Create a new item category for your auction platform. This will generate a new database table 
            with custom attributes specific to that category type.
        </p>

        <div class="info-box">
            <strong>Note:</strong> The new category table will automatically include an <code>item_id</code> 
            primary key that references the ITEM table. You only need to define additional attributes 
            specific to this category (e.g., for "Watch" you might add: movement_type, case_material, water_resistance).
        </div>

        <form action="create_category_process.jsp" method="post" onsubmit="return validateForm()">
            <div class="form-group">
                <label for="category_name">Category Name: <span class="required">*</span></label>
                <input type="text" 
                       id="category_name" 
                       name="category_name" 
                       placeholder="e.g., WATCH, JACKET, ACCESSORY" 
                       pattern="[A-Za-z_]+" 
                       title="Only letters and underscores allowed"
                       required>
            </div>
            
            <div class="info-box">
                Use underscores for multi-word categories (e.g., SPORT_EQUIPMENT).
            </div>
            
            <input type="submit" value="Create Category" class="submit-btn" style="width: 100%; margin-top: 30px;">
        </form>
        
        <a href="admin.jsp" class="back-link" style="display: block; text-align: center; margin-top: 30px;">Back to Dashboard</a>
    </div>

</body>
</html>
