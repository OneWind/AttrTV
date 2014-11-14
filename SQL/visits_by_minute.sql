-- aggregate visits data by minute --
SELECT dropif('a', 'feng_vt_mn')
GO
SELECT trunc(servertime) as serverdate, 
       datepart(hour, servertime) as hr, 
       datepart(minute, servertime) as mn, 
       count(*) as visits
INTO a.feng_vt_mn
FROM p.fact_visits
WHERE trunc(servertime) >= '2014-05-01'
  and trunc(servertime) <= '2014-05-31'
GROUP BY trunc(servertime), 
         datepart(hour, servertime), 
         datepart(minute, servertime)
ORDER BY trunc(servertime), 
         datepart(hour, servertime), 
         datepart(minute, servertime)
GO

-- aggregate visits data by minute for each device --
SELECT dropif('a', 'feng_vt_mn_device')
GO
SELECT trunc(servertime) as serverdate, 
       datepart(hour, servertime) as hr, 
       datepart(minute, servertime) as mn, 
       devicetypeid,
       count(*) as visits
INTO a.feng_vt_mn_device
FROM p.fact_visits
WHERE trunc(servertime) >= '2014-05-01'
  and trunc(servertime) <= '2014-05-31'
GROUP BY trunc(servertime), 
         datepart(hour, servertime), 
         datepart(minute, servertime),
         devicetypeid
ORDER BY trunc(servertime), 
         datepart(hour, servertime), 
         datepart(minute, servertime),
         devicetypeid
GO


-- aggregate visits data by minute with non-zero ucdmid --
SELECT dropif('a', 'feng_vt_mn_reg')
GO
SELECT trunc(servertime) as serverdate, 
       datepart(hour, servertime) as hr, 
       datepart(minute, servertime) as mn, 
       count(*) as visits
INTO a.feng_vt_mn_reg
FROM p.fact_visits
WHERE trunc(servertime) >= '2014-05-01'
  and trunc(servertime) <= '2014-05-31'
  and ucdmid != '00000000-0000-0000-0000-000000000000'
GROUP BY trunc(servertime), datepart(hour, servertime), datepart(minute, servertime)
ORDER BY trunc(servertime), datepart(hour, servertime), datepart(minute, servertime)
GO


-- aggregate visits data by minute for each device --
SELECT dropif('a', 'feng_vt_mn_reg_device')
GO
SELECT trunc(servertime) as serverdate, 
       datepart(hour, servertime) as hr, 
       datepart(minute, servertime) as mn, 
       devicetypeid,
       count(*) as visits
INTO a.feng_vt_mn_reg_device
FROM p.fact_visits
WHERE trunc(servertime) >= '2014-05-01'
  and trunc(servertime) <= '2014-05-31'
  and ucdmid != '00000000-0000-0000-0000-000000000000'
GROUP BY trunc(servertime), 
         datepart(hour, servertime), 
         datepart(minute, servertime),
         devicetypeid
ORDER BY trunc(servertime), 
         datepart(hour, servertime), 
         datepart(minute, servertime),
         devicetypeid
GO
