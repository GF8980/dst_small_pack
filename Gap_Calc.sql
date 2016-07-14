IF OBJECT_ID('tempdb.dbo.#Events', 'U') IS NOT NULL
DROP TABLE #Events;
 
CREATE TABLE #Events
(
    ID BIGINT                      IDENTITY PRIMARY KEY
    ,UserID                        INT
    ,EventTime                     DATETIME
    ,[Event]                       TINYINT -- 0=Login, 1=Logout
);
 
INSERT INTO #Events
SELECT 1, '2013-09-01 15:33', 0
UNION ALL SELECT 2, '2013-09-01 16:15', 0
UNION ALL SELECT 2, '2013-09-01 17:00', 1
UNION ALL SELECT 3, '2013-09-01 17:10', 0
UNION ALL SELECT 1, '2013-09-01 18:20', 1
UNION ALL SELECT 3, '2013-09-01 19:10', 1
UNION ALL SELECT 1, '2013-09-02 11:05', 0
UNION ALL SELECT 1, '2013-09-02 11:45', 1
UNION ALL SELECT 1, '2013-09-01 18:00', 0
UNION ALL SELECT 2,  '2013-09-01 18:01', 0;
 
SELECT UserID, LoginTime=a.EventTime, LogoutTime=b.EventTime
FROM #Events a
-- Use an OUTER APPLY to retain outer query rows when inner query returns NULL
OUTER APPLY
(
    -- find the first of any events for this user after the login. If a logout
    -- then use its EventTime. If a login return NULL
    -- For logout events (Event=1) pick up the EventTime as the time of logout
    SELECT TOP 1 EventTime=CASE WHEN [Event] = 1 THEN EventTime END
    FROM #Events b
    WHERE a.UserID = b.UserID AND b.EventTime > a.EventTime
    ORDER BY b.EventTime
) b
-- Filter on only login events
WHERE [Event] = 0
ORDER BY UserID, LoginTime;