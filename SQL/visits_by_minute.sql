SELECT dropif('a', 'feng_visits_by_minute')
GO

SELECT floor(extract(epoch from servertime) / 60 / 5) as serverminute, count(*) as visits
INTO a.feng_visits_by_minute
FROM p.fact_visits
WHERE trunc(servertime) >= '2014-07-01' and 
    trunc(servertime) <= '2014-07-31'
GROUP BY floor(extract(epoch from servertime) / 60 / 5)
GO
