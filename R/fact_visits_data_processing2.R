library(dplyr)

all.date <- as.character(seq(from=as.Date("2012-12-31"), to=as.Date("2014-11-02"), by=1))
all.date <- gsub("-", "", all.date)

all.hour <- as.character(seq(0, 23))
for (i in 1:24) {
  if (nchar(all.hour[i]) == 1)
    all.hour[i] <- paste("0", all.hour[i], sep="")
}

all.minute <- as.character(seq(0, 59))
for (i in 1:60) {
  if (nchar(all.minute[i]) == 1)
    all.minute[i] <- paste("0", all.minute[i], sep="")
}

all.time <- expand.grid(all.date, all.hour, all.minute, stringsAsFactors=FALSE)
colnames(all.time) <- c("date", "hour", "minute")
all.time$time <- paste(all.time$date, all.time$hour, all.time$minute, sep="")
all.time <- dplyr::select(all.time, time)
all.time <- dplyr::arrange(all.time, time)

####################################################################################################
vt.by.mn <- sqlQuery(.dwMatrix,
                     "select * from a.feng_vt_mn")

vt.by.mn$date <- as.character(vt.by.mn$serverdate)
vt.by.mn$date <- gsub("-", "", vt.by.mn$date)

vt.by.mn$hour <- as.character(vt.by.mn$hr)
hour1d <- which(nchar(vt.by.mn$hour) == 1)
vt.by.mn$hour[hour1d] <- paste("0", vt.by.mn$hour[hour1d], sep="")

vt.by.mn$minute <- as.character(vt.by.mn$mn)
minute1d <- which(nchar(vt.by.mn$minute) == 1)
vt.by.mn$minute[minute1d] <- paste("0", vt.by.mn$minute[minute1d], sep="")

vt.by.mn$time <- paste(vt.by.mn$date, vt.by.mn$hour, vt.by.mn$minute, sep="")

visits <- merge(all.time, vt.by.mn[, c("visits", "time")], all.x=T, all.y=T)
visits[is.na(visits)] <- 0

####################################################################################################
vt.by.mn.dv <- sqlQuery(.dwMatrix,
                        "select * from a.feng_vt_mn_device")

vt.by.mn.dv$date <- as.character(vt.by.mn.dv$serverdate)
vt.by.mn.dv$date <- gsub("-", "", vt.by.mn.dv$date)

vt.by.mn.dv$hour <- as.character(vt.by.mn.dv$hr)
hour1d <- which(nchar(vt.by.mn.dv$hour) == 1)
vt.by.mn.dv$hour[hour1d] <- paste("0", vt.by.mn.dv$hour[hour1d], sep="")

vt.by.mn.dv$minute <- as.character(vt.by.mn.dv$mn)
minute1d <- which(nchar(vt.by.mn.dv$minute) == 1)
vt.by.mn.dv$minute[minute1d] <- paste("0", vt.by.mn.dv$minute[minute1d], sep="")

vt.by.mn.dv$time <- paste(vt.by.mn.dv$date, vt.by.mn.dv$hour, vt.by.mn.dv$minute, sep="")

visits <- merge(all.time, vt.by.mn.dv[, c("visits", "devicetypeid", "time")], all.x=T, all.y=T)
visits[is.na(visits)] <- 0
visits.device <- reshape(visits, v.names="visits", idvar="time", timevar="devicetypeid",
                         direction="wide")
visits.device["visits.0"] <- NULL
visits.device[is.na(visits.device)] <- 0
# devicetype: 20 - tablet; 26 - media player
#             47 - other;  61 - mobile phone

# operation system: 19 - Android; 29 - iOS
#                   41 - Windows; 46 - Linux
#                   0 - unknown;  96 - oth0er
#                   126 - None;   151 - other

