/*
SELECT    count(*), created_by 
FROM      events 
WHERE     title = "marker" AND video_id > 0 
GROUP BY  created_by, video_id 
ORDER BY  created_by, video_id;


SELECT    count(*), 
          e.created_by, 
          v.recorded_at 
FROM      events AS e 
JOIN      videos AS v ON v.id = e.video_id 
WHERE     e.title = "marker" AND e.video_id > 0 
GROUP BY  e.video_id, e.created_by 
ORDER BY  v.recorded_at, e.created_by;


SELECT    count(*) AS total, 
          count(DISTINCT video_id) AS sessions, 
          count(*)/count(DISTINCT video_id) AS average, 
          created_by AS user 
FROM      events AS e JOIN videos AS v ON v.id = e.video_id  
WHERE     e.title = "marker"  
GROUP BY  created_by  
ORDER BY  e.created_by;


SELECT    count(*) AS total, 
          count(DISTINCT created_by) AS users, 
          count(*)/count(DISTINCT created_by) AS average, 
          video_id AS session
FROM      events 
WHERE     title = "marker" AND video_id > 0 
GROUP BY  video_id;


SELECT    count(*), 
          count(DISTINCT CONCAT(created_by, video_id)) AS users_session, 
          count(*)/count(DISTINCT CONCAT(created_by, video_id)) AS average 
FROM      events 
WHERE     title = "marker" AND video_id > 0;
*/
