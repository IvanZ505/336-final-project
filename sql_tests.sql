INSERT INTO ITEM 
(title, starting_price, bid_increment, secret_min_price, auction_start, auction_end,
 status, current_bid, description, seller_id)
VALUES
('Retro Adidas Tee', 15.00, 1.00, 10.00,
 '2024-09-28 12:00:00', '2024-10-02 12:00:00',
 'closed', 25.00,
 'Old-school Adidas graphic shirt.', @seller);

SET @itemA := LAST_INSERT_ID();

SET @seller = (SELECT user_id FROM USER WHERE username='testuser');


INSERT INTO SHIRT (item_id, item_condition, color, size, brand)
VALUES (@itemA, 'Good', 'Blue', 'M', 'Adidas');

-- Bids
INSERT INTO BID (bid_amount, bid_status) VALUES (18.00, 'placed'); SET @b1 = LAST_INSERT_ID();
INSERT INTO BID (bid_amount, bid_status) VALUES (22.00, 'placed'); SET @b2 = LAST_INSERT_ID();
INSERT INTO BID (bid_amount, bid_status) VALUES (25.00, 'winning'); SET @b3 = LAST_INSERT_ID();

INSERT INTO RECEIVES VALUES (@itemA, @b1);
INSERT INTO RECEIVES VALUES (@itemA, @b2);
INSERT INTO RECEIVES VALUES (@itemA, @b3);

INSERT INTO PLACES VALUES (@seller, @b1);
INSERT INTO PLACES VALUES (@seller, @b2);
INSERT INTO PLACES VALUES (@seller, @b3);

-- Get users
SET @seller = (SELECT user_id FROM USER WHERE username = 'testuser');
SET @buyer1 = (SELECT user_id FROM USER WHERE username = 'testuser');
SET @buyer2 = (SELECT user_id FROM USER WHERE username = 'testuser2');

-- Create expired auction item
INSERT INTO ITEM
(title, starting_price, bid_increment, secret_min_price, auction_start, auction_end,
 status, current_bid, description, seller_id)
VALUES
('Contested Air Jordans', 100.00, 5.00, 120.00,
 '2024-09-15 10:00:00', '2024-09-16 10:00:00',
 'closed', 185.00,
 'Heavily contested Jordans between two bidders.', @seller);

SET @itemC := LAST_INSERT_ID();

-- Insert shoe subtype
INSERT INTO SHOE (item_id, item_condition, brand, size)
VALUES (@itemC, 'Used', 'Jordan', 11.0);

-- Bids (back and forth)
INSERT INTO BID (bid_amount, bid_status) VALUES (120.00, 'placed');  SET @b1 := LAST_INSERT_ID();
INSERT INTO BID (bid_amount, bid_status) VALUES (145.00, 'placed');  SET @b2 := LAST_INSERT_ID();
INSERT INTO BID (bid_amount, bid_status) VALUES (165.00, 'placed');  SET @b3 := LAST_INSERT_ID();
INSERT INTO BID (bid_amount, bid_status) VALUES (185.00, 'winning'); SET @b4 := LAST_INSERT_ID();

-- Link bids to item
INSERT INTO RECEIVES VALUES (@itemC, @b1);
INSERT INTO RECEIVES VALUES (@itemC, @b2);
INSERT INTO RECEIVES VALUES (@itemC, @b3);
INSERT INTO RECEIVES VALUES (@itemC, @b4);

-- Alternate buyers placing bids
INSERT INTO PLACES VALUES (@buyer1, @b1);  -- testuser bids 120
INSERT INTO PLACES VALUES (@buyer2, @b2);  -- testuser2 bids 145
INSERT INTO PLACES VALUES (@buyer1, @b3);  -- testuser bids 165
INSERT INTO PLACES VALUES (@buyer2, @b4);  -- testuser2 wins at 185


