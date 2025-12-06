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
