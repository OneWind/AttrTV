select dropif('a', 'feng_us_tv')
go

create table a.feng_us_tv (
    tvnetwork varchar(200),
    uniformnetwork varchar(200),
    tvnetworksize varchar(200),
    tvtimestamp timestamp,
    daypart varchar(200),
    property varchar(200),
    propertystarttime timestamp,
    propertyendtime timestamp,
    proptimeflag int4,
    tvlength varchar(200),
    fullrate varchar(200),
    rate varchar(200),
    imps000 varchar(200),
    isci varchar(200),
    isciadj varchar(200),
    creativetitle varchar(200),
    wdytyapremiere varchar(200),
    celebrity varchar(200),
    spotid int4
)
go

copy a.feng_us_tv from '/mnt/matrix/load/US_TV_Spotlog.csv' delimiter ',' removequotes ignoreheader 1 timeformat 'yyyy-mm-dd hh24:mi:ss'
