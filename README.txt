CS336 FINAL PROJECT – BUYME CLOTHING AUCTION SITE
=================================================

PROJECT DESCRIPTION
-------------------
This is a database-driven web application for an online clothing auction 
system ("BuyMe"). It allows users to browse items, place bids, set up 
alerts, and manage their own auctions. Administrative interfaces allow 
Customer Representatives and System Administrators to manage users, 
auctions, and system reports.

MAIN FEATURES
-------------
USER ACCOUNTS
- Registration, login, and profile management.

AUCTIONS
- Create and manage auctions for clothing items (Shirts, Bags, Shoes).
- Place bids on active auctions.
- Automatic bidding (proxy bidding).
- View bid history and similar items.

SEARCH & ALERTS
- Search by category, price, color, brand, etc.
- Create alerts for specific criteria.

CUSTOMER SUPPORT
- Q&A forum where users post questions and Customer Reps answer.
- Help request system.

ADMINISTRATION
- Admin Dashboard: sales reports, staff account management, system stats.
- Customer Rep Dashboard: manage user accounts, remove auctions, answer questions.

TECHNOLOGY STACK
----------------
Frontend: JSP, HTML, CSS  
Backend: Java Servlets, JDBC  
Database: MySQL  
Server: Apache Tomcat (v7.0 or higher recommended)

SETUP & INSTALLATION
---------------------

1. DATABASE SETUP
   - Ensure MySQL is installed and running.
   - Locate the "clothing_store.sql" file.
   - Import it using:
       mysql -u root -p < clothing_store.sql
   - This creates the "clothing_store" database and tables.
   - Update the database credentials in:
       src/main/java/com/cs336/pkg/ApplicationDB.java

2. DEPLOYMENT
   - Import the project into your IDE (Eclipse/IntelliJ).
   - Ensure the MySQL JDBC driver 
     ("mysql-connector-java-5.1.49-bin.jar") 
     is placed in:
       src/main/webapp/WEB-INF/lib/
   - Run the application on Apache Tomcat.
   - Access it at:
       http://localhost:8080/cs336_final_project/

ACCESS CREDENTIALS
-------------------

ADMIN
- Username: 1
- Password: 12345
- Role: Full system access and report generation.

CUSTOMER REPRESENTATIVE
- Created by Admin within the Admin Dashboard.
- Login using generated rep_id.

REGULAR USER
- Create an account through the signup page.
- Example test user:
    Username: testuser
    Password: password123

TROUBLESHOOTING
---------------
- Database connection errors:
  Check JDBC URL, username, and password in ApplicationDB.java.

- "Class not found" for MySQL:
  Ensure the connector JAR is in WEB-INF/lib.
