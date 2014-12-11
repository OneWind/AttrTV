acomtv2014 <- read.csv("C:/Users/fyi/Desktop/US_TV_Spot.csv", stringsAsFactors=F)
colnames(acomtv2014) <- c("Network", "Uniform Network", "Size", "Date", "Time", 
													"Daypart", "Property", "Start", "End", "Length", "Full Rate",
													"Rate", "Imps000", "ISCI", "ISCIAdjusted", "Creative Title",
													"WDYTYA Premiere", "Celebrity")

acomtv2014$date.string <- as.character(as.Date(acomtv2014$Date, "%m/%d/%Y"))

acomtv2014$time.string <- as.character(acomtv2014$Time)
fill.zero <- function(x) {
  if (nchar(x) < 11) {
    x <- paste("0", x, sep="")
  }
  x
}
acomtv2014$time.string <- sapply(acomtv2014$time.string, fill.zero)
acomtv2014$time.string <- gsub("^12", "00", acomtv2014$time.string)
hour12to24 <- function(x) {
  if (substr(x, 10, 11) == "AM") {
    x.new <- substr(x, 1, 8)
  } else {
    hour <- as.numeric(substr(x, 1, 2)) + 12
    x.new <- paste(hour, substr(x, 3, 8), sep="")
  }
  x.new
}
acomtv2014$time.string <- sapply(acomtv2014$time.string, hour12to24)
acomtv2014$timestamp <- paste(acomtv2014$date.string, acomtv2014$time.string)


propertytime <- function(x) {
	x <- gsub("[\ ]", "", x)
	x <- gsub("000", "00", x)
  if (nchar(x) < 7) x <- paste("0", x, sep="")
  x <- gsub("^12", "00", x)
  if (substr(x, 6, 7) == "AM") {
    x <- substr(x, 1, 5)
  } else {
    hour <- as.numeric(substr(x, 1, 2)) + 12
    x <- paste(hour, substr(x, 3, 5), sep="")
  }
  x <- paste(x, ":00", sep="")
	x
}
acomtv2014$prop.start <- sapply(acomtv2014$Start, propertytime)
acomtv2014$prop.start.datetime <- paste(acomtv2014$date.string, acomtv2014$prop.start)
for (i in 1:nrow(acomtv2014)) {
  if (acomtv2014$prop.start[i] > acomtv2014$time.string[i]) {
    acomtv2014$prop.start.datetime[i] <- paste(as.character(as.Date(acomtv2014$Date[i], "%m/%d/%Y") - 1),
                                               acomtv2014$prop.start[i])
  }
}

acomtv2014$prop.end <- sapply(acomtv2014$End, propertytime)
acomtv2014$prop.end.datetime <- paste(acomtv2014$date.string, acomtv2014$prop.end)
for (i in 1:nrow(acomtv2014)) {
  if (acomtv2014$prop.end[i] < acomtv2014$time.string[i]) {
    acomtv2014$prop.end.datetime[i] <- paste(as.character(as.Date(acomtv2014$Date[i], "%m/%d/%Y") + 1),
                                             acomtv2014$prop.end[i])
  }
}

acomtv2014$proptimeflag <- 0
for (i in 1:nrow(acomtv2014)) {
	if (as.character(substr(acomtv2014$prop.end.datetime[i], 1, 10)) > 
        as.character(substr(acomtv2014$prop.start.datetime[i], 1, 10)) &
        as.character(substr(acomtv2014$prop.end.datetime[i], 12, 19)) >
        as.character(substr(acomtv2014$prop.start.datetime[i], 12, 19))) {
    acomtv2014$proptimeflag[i] <- 1
	}
}

acomtv <- acomtv2014[, c("Network", "Uniform Network", "Size", "timestamp", "Daypart", 
                         "Property", "prop.start.datetime", "prop.end.datetime", "proptimeflag",
                         "Length", "Full Rate", "Rate", "Imps000", 
                         "ISCI", "ISCIAdjusted", "Creative Title",
												 "WDYTYA Premiere", "Celebrity")]
acomtv$spotid <- 1:nrow(acomtv)

write.csv(acomtv, "US_TV_Spotlog.csv", row.names=F)
