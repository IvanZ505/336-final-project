<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Representative Account Creation</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
        }
        table {
            padding: 20px;
        }
        th {
            text-align: left;
            padding: 10px;
        }
        td {
            padding: 10px;
        }
        input[type="text"], input[type="number"] {
            width: 200px;
            padding: 5px;
        }
        input[type="submit"] {
            padding: 8px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <h2>Create Customer Representative Account</h2>
    
    <form action="create_account.jsp" method="post">
        <table>
            <tr>
                <th>Representative Name:</th>
                <td><input type="text" name="rep_name" required></td>
            </tr>
            <tr>
                <th>Password:</th>
                <td><input type="password" name="password" required></td>
            </tr>
            <tr>
                <th></th>
                <td><input type="submit" value="Create Account"></td>
            </tr>
        </table>
    </form>
</html>