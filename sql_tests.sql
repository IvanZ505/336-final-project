-- ITEM (completed auction)
INSERT INTO ITEM 
(title, starting_price, bid_increment, secret_min_price, auction_start, auction_end, status, current_bid, description, seller_id)
VALUES 
('Vintage Nike Tee', 20.00, 2.00, 25.00, '2024-10-01 12:00:00', '2024-10-02 12:00:00', 'completed', 35.00, 'Classic 90s Nike shirt in great condition.', 1);


SET @item1 = LAST_INSERT_ID();

-- SHIRT subtype row (corrected)
-- INSERT INTO SHIRT (item_id, item_condition, color, size, brand)
-- VALUES (@item1, 'Good', 'Black', 'M', 'Nike');

-- BIDS
INSERT INTO BID (bid_amount, bid_status) VALUES (22.00, 'placed');  SET @bid1 = LAST_INSERT_ID();
INSERT INTO BID (bid_amount, bid_status) VALUES (30.00, 'placed');  SET @bid2 = LAST_INSERT_ID();
INSERT INTO BID (bid_amount, bid_status) VALUES (35.00, 'winning'); SET @bid3 = LAST_INSERT_ID();

-- RECEIVES (item ↔ bids)
INSERT INTO RECEIVES VALUES (@item1, @bid1);
INSERT INTO RECEIVES VALUES (@item1, @bid2);
INSERT INTO RECEIVES VALUES (@item1, @bid3);

-- PLACES (testuser places the winning bid)
INSERT INTO PLACES VALUES (1, @bid1);
INSERT INTO PLACES VALUES (1, @bid2);
INSERT INTO PLACES VALUES (1, @bid3);

select * from item;
select * from shirt;
select * from sets_alert;
select * from end_user;


/* ============================================================
   ACTIVE ITEM #1 — SHIRT
   ============================================================ */

INSERT INTO ITEM (
    title, starting_price, bid_increment, secret_min_price,
    auction_start, auction_end, status, current_bid, description, seller_id
)
VALUES (
    'Adidas Performance Tee',
    15.00,
    1.00,
    NULL,
    NOW() - INTERVAL 1 DAY,      -- started yesterday
    NOW() + INTERVAL 3 DAY,      -- ends in 3 days
    'active',
    NULL,
    'Lightweight athletic tee, perfect for workouts.',
    1
);

SET @shirt_item := LAST_INSERT_ID();

INSERT INTO SHIRT (item_id, item_condition, color, size, brand)
VALUES (@shirt_item, 'Good', 'Blue', 'M', 'Adidas');



/* ============================================================
   ACTIVE ITEM #2 — BAG
   ============================================================ */

INSERT INTO ITEM (
    title, starting_price, bid_increment, secret_min_price,
    auction_start, auction_end, status, current_bid, description, seller_id
)
VALUES (
    'Leather Shoulder Bag',
    40.00,
    2.00,
    NULL,
    NOW() - INTERVAL 2 HOUR,     -- started 2 hours ago
    NOW() + INTERVAL 7 DAY,      -- ends in 7 days
    'active',
    NULL,
    'High-quality brown leather shoulder bag.',
    1
);

SET @bag_item := LAST_INSERT_ID();

INSERT INTO BAG (item_id, item_condition, material, brand, color)
VALUES (@bag_item, 'Like New', 'Leather', 'Coach', 'Brown');



/* ============================================================
   ACTIVE ITEM #3 — SHOE
   ============================================================ */

INSERT INTO ITEM (
    title, starting_price, bid_increment, secret_min_price,
    auction_start, auction_end, status, current_bid, description, seller_id
)
VALUES (
    'Nike Air Max 270',
    50.00,
    3.00,
    NULL,
    NOW() - INTERVAL 3 DAY,      -- started 3 days ago
    NOW() + INTERVAL 4 DAY,      -- ends in 4 days
    'active',
    NULL,
    'Gently used Nike Air Max running shoes.',
    1
);

SET @shoe_item := LAST_INSERT_ID();

INSERT INTO SHOE (item_id, item_condition, brand, size)
VALUES (@shoe_item, 'Used', 'Nike', 9.5);



/* ============================================================
   OPTIONAL: VIEW WHAT WAS INSERTED
   ============================================================ */
SELECT * FROM ITEM ORDER BY item_id DESC LIMIT 10;
SELECT * FROM SHIRT ORDER BY item_id DESC LIMIT 10;
SELECT * FROM BAG ORDER BY item_id DESC LIMIT 10;
SELECT * FROM SHOE ORDER BY item_id DESC LIMIT 10;
