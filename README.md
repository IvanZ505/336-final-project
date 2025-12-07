# CS336 Final Project - BuyMe Clothing Auction Site

## Project Description
This is a database-driven web application for an online clothing auction system ("BuyMe"). It allows users to browse items, place bids, set up alerts for specific criteria, and manage their own auctions. It also includes administrative interfaces for Customer Representatives and System Administrators to manage users, auctions, and view system reports.

## Features
- **User Accounts**: Registration, login, and profile management.
- **Auctions**:
  - Create and manage auctions for clothing items (Shirts, Bags, Shoes).
  - Place bids on active auctions.
  - Automatic bidding (proxy bidding) support.
  - View bid history and similar items.
- **Search & Alerts**:
  - Advanced search by category, price, color, brand, etc.
  - Create alerts to get notified when desired items become available.
- **Customer Support**:
  - Q&A forum where users can ask questions and Customer Reps can answer.
  - Help request system.
- **Administration**:
  - **Admin Dashboard**: View sales reports, manage staff accounts, and system statistics.
  - **Customer Rep Dashboard**: Manage user accounts, remove auctions, and answer user questions.

## Technology Stack
- **Frontend**: JSP (JavaServer Pages), HTML, CSS.
- **Backend**: Java Servlets, JDBC.
- **Database**: MySQL.
- **Server**: Apache Tomcat (v7.0 or higher recommended).

## Setup & Installation

### 1. Database Setup
1. Ensure you have MySQL installed and running.
2. Locate the `clothing_store.sql` file in the project root.
3. Import the SQL file to initialize the schema and default data:
```bash
   mysql -u root -p < clothing_store.sql
```
   *(Note: This creates the `clothing_store` database and tables.)*
4. Verify the database connection settings in `src/main/java/com/cs336/pkg/ApplicationDB.java` if you changed your MySQL root password (default assumed).

### 2. Deployment
1. Import the project into your IDE (Eclipse/IntelliJ).
2. Ensure the MySQL JDBC driver (`mysql-connector-java-5.1.49-bin.jar`) is in `src/main/webapp/WEB-INF/lib/` and added to the build path.
3. Run the project on an Apache Tomcat server.
4. Access the application at: `http://localhost:8080/cs336_final_project/` (path may vary based on your server configuration).

## Access Credentials

### Admin
- **Role**: Full system access, generate reports, create Customer Reps.
- **Username (Admin ID)**: `1`
- **Password**: `12345`

### Customer Representative
- **Role**: Moderation, answering questions, managing users/auctions.
- **Creation**: Accounts are created by the Admin via the Admin Dashboard.
- **Login**: Use the `rep_id` generated upon creation as the username.
- **Test Account**: (If created manually)
  - Create one by logging in as Admin -> "Create Customer Representative Account".

### Regular User (Customer)
- **Role**: Buy and sell items.
- **Creation**: Sign up via the "Don't have an account?" link on the login page.
- **Test Account**:
  - You can register a new user anytime.
  - Example:
    - **Username**: `testuser`
    - **Password**: `password123`
    - **Note**: The SQL file includes a commented-out section to create this user. You can uncomment those lines in `clothing_store.sql` to seed this user automatically, or register a new user manually.

## Troubleshooting
- **Connection Failed**: If you see a database connection error, check `ApplicationDB.java` to ensure the JDBC URL, username, and password match your local MySQL configuration.
- **Class Not Found**: Ensure the MySQL connector JAR is properly deployed to `WEB-INF/lib`.
