library(dplyr)
library(ggplot2)
options(java.parameters = "-Xmx10000m")
library(xlsx)
library(chron)

visits.per.minute.raw <- sqlQuery(.dwMatrix, "select * from a.feng_vt_mn")
visits.per.minute <- dplyr::arrange(visits.per.minute.raw, serverdate, hr, mn)


visits.per.minute.reg.raw <- sqlQuery(.dwMatrix, "select * from a.feng_vt_mn_reg")
visits.per.minute.reg <- dplyr::arrange(visits.per.minute.reg.raw, serverdate, hr, mn)


acomtv2014.full <- read.csv("C:\\Users\\fyi\\Desktop\\2014USMasterSpot.csv", stringsAsFactors=F)
colnames(acomtv2014.full) <- gsub("[_\\.]+", "", colnames(acomtv2014.full))

# remove spots w/o "Date" #
acomtv2014 <- dplyr::filter(acomtv2014.full, Date != "")
acomtv2014$Date <- as.Date(acomtv2014$Date, format="%m/%d/%Y")

acomtv2014$date.string <- as.character(acomtv2014$Date)
acomtv2014$date.string <- gsub("-", "", acomtv2014$date.string)
acomtv2014$time.string <- as.character(acomtv2014$Time)
fill.zero <- function(x) {
  if (nchar(x) < 11) {
    x <- paste("0", x, sep="")
  }
  x
}
acomtv2014$time.string <- sapply(acomtv2014$time.string, fill.zero)
acomtv2014$time.string <- gsub("[:\ ]", "", acomtv2014$time.string)
acomtv2014$time.string <- gsub("^12", "00", acomtv2014$time.string)
hour12to24 <- function(x) {
  if (substr(x, 7, 8) == "AM") {
    x.new <- substr(x, 1, 6)
  } else {
    hour <- as.numeric(substr(x, 1, 2)) + 12
    x.new <- paste(hour, substr(x, 3, 6), sep="")
  }
  x.new
}
acomtv2014$time.string <- sapply(acomtv2014$time.string, hour12to24)
acomtv2014$timestamp <- paste(acomtv2014$date.string, acomtv2014$time.string, sep="")


propertytime <- function(x) {
  x <- gsub("[:\ ]", "", x)
  if (nchar(x) < 6) x <- paste("0", x, sep="")
  x <- gsub("^12", "00", x)
  if (substr(x, 5, 6) == "AM") {
    x <- substr(x, 1, 4)
  } else {
    hour <- as.numeric(substr(x, 1, 2)) + 12
    x <- paste(hour, substr(x, 3, 4), sep="")
  }
  x
}
acomtv2014$prop.start <- sapply(acomtv2014$Start, propertytime)
acomtv2014$prop.start.datetime <- paste(substr(acomtv2014$timestamp, 1, 8), 
                                        acomtv2014$prop.start, sep="")
acomtv2014$prop.end <- sapply(acomtv2014$End, propertytime)
acomtv2014$prop.end.datetime <- ifelse(acomtv2014$prop.end > acomtv2014$prop.start,
                                       paste(substr(acomtv2014$timestamp, 1, 8), 
                                             acomtv2014$prop.end, sep=""),
                                       paste(gsub("-", "", as.character(acomtv2014$Date + 1)), 
                                             acomtv2014$prop.end, sep=""))

#acomtv2014$start.to.time <- ifelse(substr(acomtv2014$time.string, 1, 4) > 
#                                     acomtv2014$prop.start, 1, -1)
#acomtv2014$time.to.end <- ifelse(substr(acomtv2014$time.string, 1, 4) < 
#                                   acomtv2014$prop.end, 1, -1)

acomtv2014$Length <- gsub("\ ", "", acomtv2014$Length)
acomtv2014$BuyType <- gsub("\ ", "", acomtv2014$BuyType)

acomtv2014$Imps000 <- gsub("[-\ ]+", "", acomtv2014$Imps000)
acomtv2014$Imps000 <- gsub(",", "", acomtv2014$Imps000, fixed=TRUE)
acomtv2014$Imps000 <- as.numeric(acomtv2014$Imps000)

acomtv2014 <- dplyr::filter(acomtv2014, Length != "", BuyType != "")

acomtv2014 <- dplyr::select(acomtv2014,
                            Network, timestamp, Property, prop.start.datetime, prop.end.datetime, 
                            BuyType, 
                            Length, Imps000, Date, ISCI, Daypart, CreativeTitle, WDYTYAPremiere)

acomtv2014.bytime <- dplyr::arrange(acomtv2014, timestamp)
acomtv2014.bytime <- dplyr::filter(acomtv2014.bytime, !is.na(Imps000))


####################################################################################################
tvtime <- as.numeric(unique(substr(acomtv2014.bytime$timestamp, 1, 12)))
tmp <- numeric(length(tvtime) * 5)
for (i in 1:length(tvtime)) {
  tmp[((i-1)*5+1):(i*5)] <- seq(tvtime[i], tvtime[i]+4)
}

timestamp.update <- function(x) {
  if (substr(x, 11, 12) > 59) {
    mn <- as.numeric(substr(x, 11, 12)) - 60
    mn <- paste("0", mn, sep="")
    mn <- substr(mn, nchar(mn)-1, nchar(mn))
    hr <- as.numeric(substr(x, 9, 10)) + 1
    dt <- as.Date(substr(x, 1, 8), "%Y%m%d")
    if (hr > 23) {
      hr <- "00"
      dt <- as.character(dt + 1)
      dt <- gsub("-", "", dt)
    } else {
      hr <- paste("0", hr, sep="")
      hr <- substr(hr, nchar(hr)-1, nchar(hr))
      dt <- gsub("-", "", as.character(dt))
    }
    x <- paste(dt, hr, mn, sep="")
  }
  x
}
for (i in 1:length(tmp)) {
  tmp[i] <- timestamp.update(tmp[i])
}


tvtime.5min.ext <- sort(tmp)
tvtime.5min.ext.uniq <- unique(tvtime.5min.ext)

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

time.compare <- merge(all.time, data.frame(time=tvtime.5min.ext.uniq, tv=1), all.x=T, all.y=T)
time.compare[is.na(time.compare)] <- 0
(tv.coverage <- sum(time.compare$tv) / nrow(time.compare))
time.compare$time.POSIX <- strptime(paste(substr(time.compare$time, 1, 4),
                                            "-",
                                            substr(time.compare$time, 5, 6),
                                            "-",
                                            substr(time.compare$time, 7, 8),
                                            " ",
                                            substr(time.compare$time, 9, 10),
                                            ":",
                                            substr(time.compare$time, 11, 12),
                                            ":00",
                                            sep=""),
                                    "%Y-%m-%d %H:%M:%S")

with(time.compare[1:(24*60), ], {
  plot(time.POSIX, tv, pch=19, cex=0.01, ylim=c(-1, 2),
       xlab="time", ylab="TV indicator", main=c("TV coverage for last day of 2012"))
})

tvtime.group <- dplyr::group_by(data.frame(time=tvtime.5min.ext), time)
tvtime.group.count <- dplyr::summarise(tvtime.group, count=n())
(sum(tvtime.group.count$count > 1) / nrow(tvtime.group.count))

tvtime.group.count$time <- as.character(tvtime.group.count$time)
fulltime <- merge(tvtime.group.count, all.time, all.x=T, all.y=T)
fulltime <- dplyr::arrange(fulltime, time)
fulltime$time.POSIX <- strptime(paste(substr(fulltime$time, 1, 4),
                                                "-",
                                                substr(fulltime$time, 5, 6),
                                                "-",
                                                substr(fulltime$time, 7, 8),
                                                " ",
                                                substr(fulltime$time, 9, 10),
                                                ":",
                                                substr(fulltime$time, 11, 12),
                                                ":00",
                                                sep=""),
                                          "%Y-%m-%d %H:%M:%S")
fulltime$count[is.na(fulltime$count)] <- 0
write.csv(fulltime, file="C:/Users/fyi/Desktop/tvcoverage.csv", row.names=F)






####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
no.tv.time <- time.compare$time[is.na(time.compare$tv)]
no.tv.minute <- data.frame(min=substr(no.tv.time, 9, 12))
no.tv.minute <- dplyr::group_by(no.tv.minute, min)
no.tv.minute.table <- dplyr::summarise(no.tv.minute, count=n())
no.tv.minute.table$time <- times(paste(substr(no.tv.minute.table$min, 1, 2), ":", 
                                       substr(no.tv.minute.table$min, 3, 4), ":00", sep=""))
no.tv.minute.table$todaytime <- as.POSIXct(no.tv.minute.table$min, format="%H%M")

library(ggplot2)
library(scales)
p <- ggplot(aes(x=todaytime, y=count), data=no.tv.minute.table) +
  geom_line() + ylim(0, 700)
p


time.compare <- merge(all.time, data.frame(time=tvtime, tv=1), all.x=T, all.y=T)
no.tv.time <- time.compare$time[is.na(time.compare$tv)]
no.tv.minute <- data.frame(min=substr(no.tv.time, 9, 12))
no.tv.minute <- dplyr::group_by(no.tv.minute, min)
no.tv.minute.table <- dplyr::summarise(no.tv.minute, count=n())
no.tv.minute.table$time <- times(paste(substr(no.tv.minute.table$min, 1, 2), ":", 
                                       substr(no.tv.minute.table$min, 3, 4), ":00", sep=""))
no.tv.minute.table$todaytime <- as.POSIXct(no.tv.minute.table$min, format="%H%M")

library(ggplot2)
library(scales)
p <- ggplot(aes(x=todaytime, y=count), data=no.tv.minute.table) +
  geom_line() + ylim(0, 700)
p
