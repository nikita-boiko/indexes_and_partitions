CREATE TABLE events (
	id int, 
	user_id int, 
	event_type text, 
	created_at timestamptz 
);

INSERT INTO events 
SELECT
	num,
	floor(random() * 1000 + 1)::int, 
	(ARRAY[
		'event_1', 
		'event_2', 
		'event_3', 
		'event_4',
		'event_5',
		'event_6',
		'event_7',
		'event_8',
		'event_9',
		'event_10'
		])[floor(random() * 10) + 1], 
		'2025-01-01 00:00:00'::timestamptz + random() * (INTERVAL '1 year')
FROM generate_series(1, 100000) AS num;

EXPLAIN ANALYZE 
SELECT * FROM events 
WHERE user_id = 123;

CREATE INDEX user_id_idx ON events(user_id);

EXPLAIN ANALYZE 
SELECT * FROM events 
WHERE user_id = 123;

CREATE INDEX user_id_comp_idx ON events(event_type, created_at);

EXPLAIN ANALYZE 
SELECT * FROM events 
WHERE created_at > '2025-08-15';

 CREATE TABLE events_part (
	id int, 
	user_id int, 
	event_type text, 
	created_at timestamptz 
) PARTITION BY RANGE (created_at);

CREATE TABLE events_2025_01 PARTITION OF events_part
	FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE events_2025_02 PARTITION OF events_part
	FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE events_2025_03 PARTITION OF events_part
	FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

INSERT INTO events_part  
SELECT * FROM events
WHERE created_at BETWEEN '2025-01-01' AND '2025-04-01'; 

EXPLAIN 
SELECT * FROM events_part
WHERE created_at BETWEEN '2025-01-01' AND '2025-01-15';

INSERT INTO events_part (created_at)
VALUES ('2025-05-01 00:00:00'::timestamptz);


ALTER TABLE events 
ADD COLUMN metadata jsonb;

UPDATE events
SET metadata = '{"status": "active", "priority": 1}'::jsonb;

INSERT INTO events (metadata)
VALUES 
(
	'{"status": "active"}'::jsonb
),
(
	'{"priority": 1}'::jsonb
), 
(
	'{"info": "default", "priority": 1}'::jsonb
);

CREATE INDEX idx_gin_events ON events USING gin (metadata);

EXPLAIN 
SELECT * FROM events
WHERE metadata->>'status' = 'active';