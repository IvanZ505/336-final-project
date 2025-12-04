<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.ApplicationDB" %>

<%
    // Get form parameters
    String logIdStr = request.getParameter("log_id");
    String answer = request.getParameter("answer");
    
    // Get rep ID from session
    Integer repId = (Integer) session.getAttribute("repId");
    
    if (repId == null) {
        response.sendRedirect("login.jsp?error=1");
        return;
    }
    
    if (logIdStr == null || answer == null || answer.trim().isEmpty()) {
        response.sendRedirect("answer_questions.jsp?err=Missing+answer+or+log+ID");
        return;
    }
    
    int logId = Integer.parseInt(logIdStr);
    
    Connection con = null;
    PreparedStatement ps = null;
    
    try {
        ApplicationDB db = new ApplicationDB();
        con = db.getConnection();
        
        if (con == null) {
            response.sendRedirect("answer_questions.jsp?err=Database+connection+failed");
            return;
        }
        
        // Update the SUPPORTS record with the answer and assign this rep
        String sql = "UPDATE SUPPORTS SET answer = ?, rep_id = ? WHERE log_id = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, answer);
        ps.setInt(2, repId);
        ps.setInt(3, logId);
        
        int rowsUpdated = ps.executeUpdate();
        
        if (rowsUpdated > 0) {
            response.sendRedirect("answer_questions.jsp?msg=Answer+submitted+successfully");
        } else {
            response.sendRedirect("answer_questions.jsp?err=Failed+to+submit+answer");
        }
        
        db.closeConnection(con);
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("answer_questions.jsp?err=Error:+" + e.getMessage());
    } finally {
        try {
            if (ps != null) ps.close();
        } catch (SQLException ignore) {}
    }
%>
