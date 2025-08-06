# Headblocker

Purpose of this article

This article describes how to identify headblocker SPID and how to shutdown or kill SPID.

This article can be referred to when there is a need to shutdown or kill SPID

## Process Overview

- Identify the headblocker SPID
- Run this script:

~~~sql

SET NOCOUNT ON
GO
SELECT SPID, BLOCKED, REPLACE (REPLACE (T.TEXT, CHAR(10), ' '), CHAR (13), ' ' ) AS BATCH
INTO #T
FROM sys.sysprocesses R CROSS APPLY sys.dm_exec_sql_text(R.SQL_HANDLE) T
GO
WITH BLOCKERS (SPID, BLOCKED, LEVEL, BATCH)
AS
(SELECT SPID,
BLOCKED,
CAST (REPLICATE ('0', 4-LEN (CAST (SPID AS VARCHAR))) + CAST (SPID AS VARCHAR) AS VARCHAR (1000)) AS LEVEL,
BATCH FROM #T R
WHERE (BLOCKED = 0 OR BLOCKED = SPID)
AND EXISTS (SELECT * FROM #T R2 WHERE R2.BLOCKED = R.SPID AND R2.BLOCKED <> R2.SPID)
UNION ALL
SELECT R.SPID,
R.BLOCKED,
CAST (BLOCKERS.LEVEL + RIGHT (CAST ((1000 + R.SPID) AS VARCHAR (100)), 4) AS VARCHAR (1000)) AS LEVEL,
R.BATCH FROM #T AS R
INNER JOIN BLOCKERS ON R.BLOCKED = BLOCKERS.SPID WHERE R.BLOCKED > 0 AND R.BLOCKED <> R.SPID)
SELECT N'    ' + REPLICATE (N'|         ', LEN (LEVEL)/4 - 1) +
CASE WHEN (LEN(LEVEL)/4 - 1) = 0
THEN 'HEAD -  '
ELSE '|------  ' END
+ CAST (SPID AS NVARCHAR (10)) + N' ' + BATCH AS BLOCKING_TREE
FROM BLOCKERS ORDER BY LEVEL ASC
GO
DROP TABLE #T
GO
~~~

- Open new query and enter:

~~~sql
KILL <insert SPID>
~~~

### Additional Information

If you are killing a SPID, it should be in agreement with someone on the application side, while killing the SPID will most likely have a negative impact on the application.

For further information on a SPID before killing it, you can run the following queries:

~~~sql
sp_who <insert SPID>

dbcc inputbuffer <insert SPID>
~~~

Like in this example, where our SPID is 52

![example01](/docs/internal/assets/infowhoandbuffer.png)

> If its a hanging/stuck SPID, you might also be able to see it by running: dbcc opentran
