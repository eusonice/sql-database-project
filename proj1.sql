-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, p.playerid, yearid
  FROM people p INNER JOIN halloffame hf
  ON p.playerid = hf.playerid
  WHERE inducted = 'Y'
  ORDER BY yearid DESC, p.playerid
;

-- Question 2ii
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

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q2i.playerid, namefirst, namelast, cp.schoolid
  FROM q2i LEFT OUTER JOIN collegeplaying cp
  ON q2i.playerid = cp.playerid
  ORDER BY q2i.playerid DESC, cp.schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT b.playerid, namefirst, namelast, yearid, (h + h2b + 2.0 * h3b + 3.0 * hr) / ab
  FROM batting b LEFT OUTER JOIN people p
  ON b.playerid = p.playerid
  WHERE ab > 50
  ORDER BY (h + h2b + 2.0 * h3b + 3.0 * hr) / ab DESC, yearid, b.playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, namefirst, namelast, (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab)
  FROM people p LEFT OUTER JOIN batting b
  ON p.playerid = b.playerid
  GROUP BY p.playerid
  HAVING SUM(ab) > 50
  ORDER BY (SUM(h) + SUM(h2b) + 2.0 * SUM(h3b) + 3.0 * SUM(hr)) / SUM(ab) DESC, p.playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
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
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM people p INNER JOIN salaries s
  ON p.playerid = s.playerid
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH binids() AS (
    SELECT 
  )
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT yearid, (MIN(salary) - MIN(salary)), (MAX(yearid) - MAX(yearid - 1)), (AVG(yearid) - AVG(yearid - 1))
  FROM people p INNER JOIN salaries s
  ON p.playerid = s.playerid
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
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
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
-- Each team has at least 1 All Star and may have multiple. 
-- For each team in the year 2016, give the teamid and diffAvg 
-- (the difference between the team's highest paid all-star's salary 
-- and the team's lowest paid all-star's salary).
  SELECT s.teamid, MAX(salary) - MIN(salary)
  FROM people p INNER JOIN salaries s
  ON p.playerid = s.playerid
  INNER JOIN allstarfull asf
  ON p.playerid = asf.playerid
  WHERE s.yearid = 2016
  GROUP BY s.teamid
;

