library(dplyr)
library(ggplot2)

visits.per.minute.raw <- sqlQuery(.dwMatrix, "select * from a.feng_vt_mn")
visits.per.minute <- dplyr::arrange(visits.per.minute.raw, serverdate, hr, mn)


visits.per.minute.reg.raw <- sqlQuery(.dwMatrix, "select * from a.feng_vt_mn_reg")
visits.per.minute.reg <- dplyr::arrange(visits.per.minute.reg.raw, serverdate, hr, mn)


tv2014 <- read.csv("\\\\prfile1\\Analytics\\Feng\\AttrTV\\data\\TV_US_2014.csv",
                   stringsAsFactors=FALSE)
