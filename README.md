# SQL Project

Practicing SQL using SQLite, working with Lahman baseball database: https://www.seanlahman.com/baseball-archive/statistics/

```sql
-- 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast
;

-- 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, p.playerid, yearid
  FROM people p INNER JOIN halloffame hf
  ON p.playerid = hf.playerid
  WHERE inducted = 'Y'
  ORDER BY yearid DESC, p.playerid
;

-- 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q2i.playerid, cp.schoolid, yearid
  FROM q2i INNER JOIN collegeplaying cp
  ON q2i.playerid = cp.playerid
  INNER JOIN schools s
  ON cp.schoolid = s.schoolid
  WHERE schoolstate = 'CA'
  ORDER BY yearid DESC, cp.schoolid, q2i.playerid
;

-- 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q2i.playerid, namefirst, namelast, cp.schoolid
  FROM q2i LEFT OUTER JOIN collegeplaying cp
  ON q2i.playerid = cp.playerid
  ORDER BY q2i.playerid DESC, cp.schoolid
;

-- 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT b.playerid, namefirst, namelast, yearid, (h + h2b + 2.0 * h3b + 3.0 * hr) / ab
  FROM batting b LEFT OUTER JOIN people p
  ON b.playerid = p.playerid
  WHERE ab > 50
  ORDER BY (h + h2b + 2.0 * h3b + 3.0 * hr) / ab DESC, yearid, b.playerid
  LIMIT 10
;

-- 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  WITH topT(playerid, lslg) AS (
    SELECT b.playerid AS playerid, (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab) AS lslg
    FROM batting b
    GROUP BY b.playerid
    HAVING SUM(ab) > 50
  )
  SELECT p.playerid, namefirst, namelast, lslg
  FROM people p INNER JOIN topT
  ON p.playerid = topT.playerid
  ORDER BY lslg DESC, p.playerid
  LIMIT 10
  /*
  SELECT p.playerid, namefirst, namelast, (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab)
  FROM people p LEFT OUTER JOIN batting b
  ON p.playerid = b.playerid
  GROUP BY p.playerid
  HAVING SUM(ab) > 50
  ORDER BY (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab) DESC, p.playerid
  LIMIT 10
  */
;

-- 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH lstP(playerid, lslg) AS (
    SELECT b.playerid AS playerid, (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab) AS lslg
    FROM batting b
    GROUP BY b.playerid
    HAVING SUM(ab) > 50 AND ((SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab)) > (
      SELECT (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab)
      FROM people p LEFT OUTER JOIN batting b
      ON p.playerid = b.playerid
      WHERE p.playerid = 'mayswi01'
    )
  )
  SELECT namefirst, namelast, lslg
  FROM people p INNER JOIN lstP
  ON p.playerid = lstP.playerid
  ORDER BY lslg DESC, p.playerid
  /*
  SELECT namefirst, namelast, (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab)
  FROM people p LEFT OUTER JOIN batting b
  ON p.playerid = b.playerid
  GROUP BY p.playerid
  HAVING SUM(ab) > 50 AND ((SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab)) > (
    SELECT (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab)
    FROM people p LEFT OUTER JOIN batting b
    ON p.playerid = b.playerid
    WHERE p.playerid = 'mayswi01'
  )
  ORDER BY (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab) DESC, p.playerid
  */
;

-- 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM people p INNER JOIN salaries s
  ON p.playerid = s.playerid
  GROUP BY yearid
  ORDER BY yearid
;

-- 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH size(width, minS, maxS) AS (
    SELECT (MAX(salary) - MIN(salary)) / 10.0, MIN(salary), MAX(salary)
    FROM salaries
    WHERE yearid = 2016
  ), boundaries(binid, low, high, width, minS, maxS) AS (
    SELECT binid, minS + binid * width, minS + (binid + 1) * width, width, minS, maxS
    FROM binids, size
  ), counting(binid, total) AS (
    SELECT boundaries.binid AS joinid, count(instance) AS total
    FROM boundaries LEFT OUTER JOIN (
      SELECT binid AS binN, salary AS instance
      FROM boundaries LEFT OUTER JOIN salaries
      ON binid = CAST((salary - minS) / width AS INT)
      WHERE yearid = 2016
      UNION ALL 
      SELECT binid AS binN, salary AS instance
      FROM boundaries LEFT OUTER JOIN salaries
      ON binid = CAST(((salary - minS) / width) - 1 AS INT)
      WHERE yearid = 2016 AND salary = maxS
    ) AS countS
    ON boundaries.binid = binN
    GROUP BY boundaries.binid
    ORDER BY boundaries.binid
  )
  SELECT boundaries.binid, low, high, total
  FROM boundaries LEFT OUTER JOIN counting
  ON boundaries.binid = counting.binid
  /*
  SELECT binid, minS + binid * binW, minS + (binid + 1) * binW, COUNT(*)
  FROM binids LEFT OUTER JOIN (
    SELECT salary, minS, CAST((salary - minS) / binW AS INT) AS binN, binW
    FROM salaries, (
      SELECT (MAX(salary) - MIN(salary)) / 10.0 AS binW, MAX(salary) AS maxS, MIN(salary) AS minS
      FROM salaries
      WHERE yearid = 2016
    )
    WHERE yearid = 2016
    UNION ALL
    SELECT salary, minS, CAST((salary - minS) / binW AS INT) - 1 AS binN, binW
    FROM salaries, (
      SELECT (MAX(salary) - MIN(salary)) / 10.0 AS binW, MAX(salary) AS maxS, MIN(salary) AS minS
      FROM salaries
      WHERE yearid = 2016
    )
    WHERE yearid = 2016 AND salary = maxS
  )
  ON binid = binN
  GROUP BY binid
  */
;

-- 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s1.yearid, s1.minS - s2.minS, s1.maxS - s2.maxS, s1.avgS - s2.avgS
  FROM (
    SELECT yearid, MIN(salary) AS minS, MAX(salary) AS maxS, AVG(salary) AS avgS
    FROM salaries
    GROUP BY yearid
  ) s1 INNER JOIN (
    SELECT yearid, MIN(salary) AS minS, MAX(salary) AS maxS, AVG(salary) AS avgS
    FROM salaries
    GROUP BY yearid
  ) s2
  ON s1.yearid = s2.yearid + 1
  ORDER BY s1.yearid
  /*
  SELECT s1.yearid, MIN(s1.salary) - MIN(s2.salary), MAX(s1.salary) - MAX(s2.salary), AVG(s1.salary) - AVG(s2.salary)
  FROM salaries s1 INNER JOIN salaries s2
  ON s1.yearid = s2.yearid + 1
  GROUP BY s1.yearid
  ORDER BY s1.yearid
  */
;

-- 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH maxS(yearid, salary) AS (
    SELECT yearid, MAX(salary)
    FROM salaries s
    WHERE yearid = 2000 OR yearid = 2001
    GROUP BY yearid
  ), maxP(playerid, yearid, salary) AS (
    SELECT s.playerid, maxS.yearid, s.salary
    FROM maxS INNER JOIN salaries s
    ON maxS.salary = s.salary AND maxS.yearid = s.yearid
  )
  SELECT maxP.playerid, namefirst, namelast, salary, yearid
  FROM maxP INNER JOIN people p
  ON maxP.playerid = p.playerid
  /*
  SELECT playerid, namefirst, namelast, salary, yearid
  FROM (
    SELECT p.playerid AS playerid, namefirst, namelast, MAX(salary) AS salary, yearid
    FROM people p INNER JOIN salaries s
    ON p.playerid = s.playerid
    WHERE yearid = 2000 AND salary >= (
      SELECT MAX(salary)
      FROM people p INNER JOIN salaries s
      ON p.playerid = s.playerid
      WHERE yearid = 2000
    )
    UNION ALL
    SELECT p.playerid, namefirst, namelast, MAX(salary), yearid
    FROM people p INNER JOIN salaries s
    ON p.playerid = s.playerid
    WHERE yearid = 2001 AND salary >= (
      SELECT MAX(salary)
      FROM people p INNER JOIN salaries s
      ON p.playerid = s.playerid
      WHERE yearid = 2001
    )
  ) AS twoY
  */
  /*
  SELECT p.playerid, namefirst, namelast, MAX(salary), yearid
  FROM people p INNER JOIN salaries s
  ON p.playerid = s.playerid
  WHERE yearid = 2000 OR yearid = 2001
  GROUP BY yearid
  HAVING salary >= (
    SELECT MAX(salary)
    FROM people p INNER JOIN salaries s
    ON p.playerid = s.playerid
    WHERE yearid = 2000 OR yearid = 2001
    GROUP BY yearid
  )
  */
;

-- 4v
CREATE VIEW q4v(team, diffAvg) 
AS
  SELECT teamid, maxS - minS
  FROM (
    SELECT asf.teamid AS teamid, MAX(salary) AS maxS, MIN(salary) AS minS
    FROM allstarfull asf INNER JOIN salaries s
    ON asf.playerid = s.playerid
    AND asf.yearid = s.yearid
    WHERE asf.yearid = 2016
    GROUP BY asf.teamid
  )
;
```
