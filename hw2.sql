DROP TABLE IF EXISTS "Order_Items";
DROP TABLE IF EXISTS "Orders";
DROP TABLE IF EXISTS "Products";

-- task 1
CREATE TABLE "Orders" (
	o_id serial PRIMARY KEY,
	order_date date NOT NULL
);

CREATE TABLE "Products" (
	p_name text PRIMARY KEY,
	price money NOT NULL
);

CREATE TABLE "Order_Items" (
	order_id int NOT NULL,
	product_name text NOT NULL,
	amount numeric(7,2) NOT NULL DEFAULT 1 CHECK (amount > 0),

	PRIMARY KEY (order_id, product_name),

	FOREIGN KEY (order_id) REFERENCES "Orders" (o_id)
		ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (product_name) REFERENCES "Products" (p_name)
		ON UPDATE CASCADE ON DELETE RESTRICT
);

-- task 2
INSERT INTO "Orders" (order_date) VALUES
	('2025-11-26'),
	('2025-11-27');

INSERT INTO "Products" (p_name, price) VALUES
	('p1', 10.00),
	('p2', 7.00);

INSERT INTO "Order_Items" (order_id, product_name) VALUES
    (1, 'p1'),
    (1, 'p2');

INSERT INTO "Order_Items" (order_id, product_name, amount) VALUES
    (2, 'p1', 4),
    (2, 'p2', 1);

-- task 3
ALTER TABLE "Products" RENAME COLUMN p_name TO p_name_temp;

ALTER TABLE "Products" ADD COLUMN p_id serial NOT NULL UNIQUE;

ALTER TABLE "Products" DROP CONSTRAINT "Products_pkey";
ALTER TABLE "Products" ADD PRIMARY KEY (p_id);

ALTER TABLE "Products" RENAME COLUMN p_name_temp TO p_name;
ALTER TABLE "Products" ALTER COLUMN p_name SET NOT NULL;
ALTER TABLE "Products" ADD CONSTRAINT unique_p_name UNIQUE (p_name);

ALTER TABLE "Order_Items" ADD COLUMN product_id int;


UPDATE "Order_Items" oi
SET product_id = (SELECT p.p_id FROM "Products" p WHERE p.p_name = oi.product_name);

ALTER TABLE "Order_Items" ALTER COLUMN product_id SET NOT NULL;

ALTER TABLE "Order_Items" ADD COLUMN price money;
ALTER TABLE "Order_Items" ADD COLUMN total money;

UPDATE "Order_Items" oi
SET price = (SELECT p.price FROM "Products" p WHERE p.p_id = oi.product_id);

UPDATE "Order_Items"
SET total = amount * price;

ALTER TABLE "Order_Items" ALTER COLUMN price SET NOT NULL;
ALTER TABLE "Order_Items" ALTER COLUMN total SET NOT NULL;

ALTER TABLE "Order_Items" ADD CONSTRAINT check_total_calculated
    CHECK (total = amount * price);


ALTER TABLE "Order_Items" DROP CONSTRAINT "Order_Items_pkey";
ALTER TABLE "Order_Items" ADD PRIMARY KEY (order_id, product_id);

ALTER TABLE "Order_Items" ADD CONSTRAINT fk_product_id
    FOREIGN KEY (product_id) REFERENCES "Products" (p_id) 
    ON UPDATE CASCADE ON DELETE RESTRICT; 

ALTER TABLE "Order_Items" DROP COLUMN product_name;

-- task 4
UPDATE "Products"
SET p_name = 'product1'
WHERE p_name = 'p1';

DELETE FROM "Order_Items" oi
WHERE oi.order_id = 1
  AND oi.product_id = (SELECT p.p_id FROM "Products" p WHERE p.p_name = 'p2');

DELETE FROM "Orders"
WHERE o_id = 2; 

UPDATE "Products"
SET price = 5.00
WHERE p_name = 'product1';

UPDATE "Order_Items" oi
SET 
    price = 5.00,
    total = amount * 5.00 
WHERE 
    product_id = (SELECT p.p_id FROM "Products" p WHERE p.p_name = 'product1');


INSERT INTO "Orders" (order_date) 
VALUES (CURRENT_DATE); 

INSERT INTO "Order_Items" (order_id, product_id, amount, price, total)
VALUES (
    (SELECT MAX(o_id) FROM "Orders"), 
    (SELECT p_id FROM "Products" WHERE p_name = 'product1'), 
    3.00,
    (SELECT price FROM "Products" WHERE p_name = 'product1'), 
    3.00 * (SELECT price FROM "Products" WHERE p_name = 'product1') 
);