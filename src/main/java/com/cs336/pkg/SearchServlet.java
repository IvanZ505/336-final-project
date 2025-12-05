package com.cs336.pkg;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handleSearch(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handleSearch(req, resp);
    }

    private void handleSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword   = trimOrNull(request.getParameter("keyword"));
        String category  = trimOrNull(request.getParameter("category"));
        String size      = trimOrNull(request.getParameter("size"));
        String brand     = trimOrNull(request.getParameter("brand"));
        String condition = trimOrNull(request.getParameter("condition"));
        String color     = trimOrNull(request.getParameter("color"));
        String minP      = trimOrNull(request.getParameter("minPrice"));
        String maxP      = trimOrNull(request.getParameter("maxPrice"));
        String sort      = trimOrNull(request.getParameter("sort"));

        int page = 1;
        try {
            if (request.getParameter("page") != null)
                page = Math.max(1, Integer.parseInt(request.getParameter("page")));
        } catch (Exception ignored) {}

        Connection con = null;
        PreparedStatement ps = null, psCount = null;
        ResultSet rs = null, rsCount = null;

        try {
            ApplicationDB db = new ApplicationDB();
            con = db.getConnection();

            // Base query with LEFT JOIN on each subtype
            String base =
                " FROM ITEM i " +
                " LEFT JOIN SHIRT s ON i.item_id = s.item_id " +
                " LEFT JOIN BAG b ON i.item_id = b.item_id " +
                " LEFT JOIN SHOE sh ON i.item_id = sh.item_id " +
                " JOIN USER u ON u.user_id = i.seller_id " +
                " WHERE i.auction_start <= NOW() AND i.auction_end >= NOW() ";

            List<String> conds = new ArrayList<>();
            List<Object> params = new ArrayList<>();

            // keyword
            if (keyword != null) {
                conds.add("(i.title LIKE ? OR i.description LIKE ?)");
                params.add("%" + keyword + "%");
                params.add("%" + keyword + "%");
            }

            // category
            if (category != null) {
                String c = category.toLowerCase();
                if (c.equals("shirt")) conds.add("s.item_id IS NOT NULL");
                if (c.equals("bag"))   conds.add("b.item_id IS NOT NULL");
                if (c.equals("shoe"))  conds.add("sh.item_id IS NOT NULL");
            }

            // size (shirt: varchar, shoe: decimal)
            if (size != null) {
                conds.add("(s.size = ? OR sh.size = ?)");
                params.add(size);
                params.add(size);
            }

            // brand
            if (brand != null) {
                conds.add("(s.brand = ? OR b.brand = ? OR sh.brand = ?)");
                params.add(brand);
                params.add(brand);
                params.add(brand);
            }

            // item_condition
            if (condition != null) {
                conds.add("(s.item_condition = ? OR b.item_condition = ? OR sh.item_condition = ?)");
                params.add(condition);
                params.add(condition);
                params.add(condition);
            }

            // color (bags + shirts)
            if (color != null) {
                conds.add("(s.color = ? OR b.color = ?)");
                params.add(color);
                params.add(color);
            }

            // price
            String priceExpr = "COALESCE(i.current_bid, i.starting_price)";
            if (minP != null) {
                conds.add(priceExpr + " >= ?");
                params.add(new BigDecimal(minP));
            }
            if (maxP != null) {
                conds.add(priceExpr + " <= ?");
                params.add(new BigDecimal(maxP));
            }

            StringBuilder where = new StringBuilder(base);
            for (String c : conds)
                where.append(" AND ").append(c);

            // order by
            String orderBy;
            if ("price_asc".equals(sort))
                orderBy = " ORDER BY " + priceExpr + " ASC ";
            else if ("price_desc".equals(sort))
                orderBy = " ORDER BY " + priceExpr + " DESC ";
            else if ("ending_soon".equals(sort))
                orderBy = " ORDER BY i.auction_end ASC ";
            else
                orderBy = " ORDER BY i.auction_start DESC ";

            // count
            String countSql = "SELECT COUNT(*) " + where;
            psCount = con.prepareStatement(countSql);
            bindParams(psCount, params);
            rsCount = psCount.executeQuery();
            int total = 0;
            if (rsCount.next()) total = rsCount.getInt(1);

            int offset = (page - 1) * PAGE_SIZE;

            String sql =
                "SELECT i.item_id, i.title, i.current_bid, i.auction_end, " +
                " u.username AS seller_username, " +
                " CASE " +
                "   WHEN s.item_id IS NOT NULL THEN 'shirt' " +
                "   WHEN b.item_id IS NOT NULL THEN 'bag' " +
                "   WHEN sh.item_id IS NOT NULL THEN 'shoe' " +
                "   ELSE 'other' END AS category " +
                where + orderBy +
                " LIMIT ? OFFSET ?";

            ps = con.prepareStatement(sql);
            int idx = bindParams(ps, params);
            ps.setInt(idx++, PAGE_SIZE);
            ps.setInt(idx, offset);

            rs = ps.executeQuery();
            List<Map<String,Object>> results = new ArrayList<>();

            while (rs.next()) {
                Map<String,Object> r = new HashMap<>();
                r.put("item_id", rs.getInt("item_id"));
                r.put("title", rs.getString("title"));
                r.put("category", rs.getString("category"));
                r.put("current_bid", rs.getBigDecimal("current_bid"));
                r.put("auction_end", rs.getTimestamp("auction_end"));
                r.put("seller_username", rs.getString("seller_username"));
                results.add(r);
            }

            request.setAttribute("results", results);
            request.setAttribute("page", page);
            request.setAttribute("totalResults", total);

            request.getRequestDispatcher("search_results.jsp")
                   .forward(request, response);

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("error", "Search error: " + ex.getMessage());
            request.getRequestDispatcher("search_results.jsp")
                   .forward(request, response);
        }
    }

    private static String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private static int bindParams(PreparedStatement ps, List<Object> params)
            throws SQLException {
        int i = 1;
        for (Object p : params) {
            if (p instanceof BigDecimal) ps.setBigDecimal(i++, (BigDecimal)p);
            else ps.setObject(i++, p);
        }
        return i;
    }
}
