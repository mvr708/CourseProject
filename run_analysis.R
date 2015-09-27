## You should create one R script called run_analysis.R that does the following. 

## Merges the training and the test sets to create one data set.

require(dplyr)
require(plyr)
require(reshape2)

##set working directory to UCI HAR dataset if it exist in current directory else exit
setwd("UCI HAR Dataset")
if(basename(getwd()) != "UCI HAR Dataset"){ 
    message("Please run from directory containing UCI HAR Dataset folder")
    return
}

## read in variable names
varNames <- read.delim("features.txt",header = F,sep = " ")
actNames <- read.delim("activity_labels.txt",header = F,sep = " ")

## read in training data set
## Appropriately labels the data set with descriptive variable names. 
trainData <- read.table("train/X_train.txt",header = F,col.names = varNames$variable,fill = F,strip.white = T)
## read in activity set
trainActs <- read.delim("train/Y_train.txt",header = F,sep = " ")
## change numbers to names
## Uses descriptive activity names to name the activities in the data set
trainActs$activity <- factor(trainActs$index,levels = actNames$index,labels = actNames$activity)
## attach activity column
trainDataN <- mutate(trainData,activity = trainActs$activity)
## read in volunteer set
trainDataNV <- mutate(trainDataN,volunteer_id = volNums$V1)
## attach volunteer column
trainDataNV <- mutate(trainDataN,volunteer_id = volNums$V1)

## read in test data set
testData <- read.table("test/X_test.txt",header = F,col.names = varNames$variable,fill = F,strip.white = T)
## read in activity set
testActs <- read.delim("test/Y_test.txt",header = F,sep = " ")
## change numbers to names
## Uses descriptive activity names to name the activities in the data set
testActs$activity <- factor(testActs$index,levels = actNames$index,labels = actNames$activity)
## attach activity column
testDataN <- mutate(testData,activity = testActs$activity)
## read in volunteer set
volNums2 <- read.delim("test/subject_test.txt",header = F,sep = " ")
## attach volunteer column
testDataNV <- mutate(testDataN,volunteer_id = volNums2$V1)

## join both tables
dfJoined <- rbind.data.frame(testDataNV,trainDataNV,make.row.names = F)

## select columns to keep
## Extracts only the measurements on the mean and standard deviation for 
## each measurement. 
dfFiltered <- select(dfJoined,matches("mean|std"))
dfFiltered<- select(dfFiltered,- starts_with("angle"))
dfFiltered<- select(dfFiltered,- contains("Freq"))

## change variable names ;;this is not pretty
dfFiltered<- select(dfFiltered,- starts_with("angle"))
names(dfFiltered)<- gsub("^t","Time ",names(dfFiltered))
names(dfFiltered)<- gsub("^f","FFT ",names(dfFiltered))
names(dfFiltered)<- gsub("Body","Body ",names(dfFiltered))
names(dfFiltered)<- gsub("Acc\\.","accelerometer ",names(dfFiltered))
names(dfFiltered)<- gsub("AccJerk","accelerometer jerk",names(dfFiltered))
names(dfFiltered)<- gsub("AccMag","accelerometer magnitude",names(dfFiltered))
names(dfFiltered)<- gsub("mean...X$","x-axis mean",names(dfFiltered))
names(dfFiltered)<- gsub("std...X$","x-axis stDev",names(dfFiltered))
names(dfFiltered)<- gsub("std...Y$","y-axis stDev",names(dfFiltered))
names(dfFiltered)<- gsub("std...Z$","z-axis stDev",names(dfFiltered))
names(dfFiltered)<- gsub("mean...Y$","y-axis mean",names(dfFiltered))
names(dfFiltered)<- gsub("mean...Z$","z-axis mean",names(dfFiltered))
names(dfFiltered)<- gsub(".mean..$"," mean",names(dfFiltered))
names(dfFiltered)<- gsub(".std..$"," std",names(dfFiltered))
names(dfFiltered)<- gsub("Gyro","gyroscope ",names(dfFiltered))
names(dfFiltered)<- gsub("Gravity","gravity ",names(dfFiltered))
names(dfFiltered)<- gsub("Body","body",names(dfFiltered))
names(dfFiltered)<- gsub("body\ body","body",names(dfFiltered))
names(dfFiltered)<- gsub("jerk\\.","jerk ",names(dfFiltered))
names(dfFiltered)<- gsub("\ \\."," ",names(dfFiltered))
names(dfFiltered)<- gsub("Jerk\\.","jerk ",names(dfFiltered))
names(dfFiltered)<- gsub("Mag","magnitude ",names(dfFiltered))
names(dfFiltered)<- gsub("km","k m",names(dfFiltered))
names(dfFiltered)<- gsub("std$","stDev",names(dfFiltered))

## add back activity name and volunteer_id
dfFiltered <- mutate(dfFiltered,activity = dfJoined$activity)
dfFiltered <- mutate(dfFiltered,volunteer_id = dfJoined$volunteer_id)

## melt data to make it tidy
dfTidy <- melt(dfFiltered,id=c("activity","volunteer_id"))
## From the data set in step 4, creates a second, independent tidy data set
## with the average of each variable for each activity and each subjec
dfTidy <- ddply(dfTidy,c("volunteer_id","activity","variable"),summarize,average = mean(value))
## write output table to file tidyDataTable




