##make sure plyr package is active
library(dplyr)

##DOWNLOAD THE FILE
##set the URL from which to download the file
##check if there is a folder 'data'. if not create one
##get a value for f, the file.path: the folder in which you are working now+/data+nameOftheFile
##download the file from the URL and save it at the location referred to by f
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./data")){dir.create("./data")}
f <- file.path(getwd(),"/data", "Dataset.zip")
download.file(fileURL, f)

##UNZIP THE FILE; The file will generate a folder named "UCI HAR Dataset"
##Get the list of files in that folder
unzip(zipfile="./data/Dataset.zip", exdir="./data/unzipped")

##GET THE FILENAMES AND READ THE RELEVANT FILES
##README.txt gives information on the files that we need:
##traininginformation is in the file: train/X_train.txt
##testinformation is in the file: test/X_test.txt 
##labels for both sets are in: train/y_train.txt and test/y_test.txt
##train/subject_train.txt' and test/subject_test.txt: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.
##all the names of the variables are in features.txt
##opening in txt yields weird signs so let's see what happens if we read them via R and make them into a table
##Read the relevant files and first set a variable for the path
train <- "./data/unzipped/UCI HAR Dataset/train"
test <- "./data/unzipped/UCI HAR Dataset/test"
subjectTraining <- read.table(file.path(train, "subject_train.txt"))
subjectTest <- read.table(file.path(test, "subject_test.txt"))
activityTest <- read.table(file.path(test, "Y_test.txt"))
activityTraining <- read.table(file.path(train, "Y_train.txt"))
labelsTest  <- read.table(file.path(test, "X_test.txt" ),header = FALSE)
labelsTraining <- read.table(file.path(train, "X_train.txt"),header = FALSE)
features <- read.table(file.path("./data/unzipped/UCI HAR Dataset","features.txt"))

##INSPECT THE RELEVANT FILES
str(labelsTest)
str(labelsTraining)
str(features)
str(subjectTraining)
str(subjectTest)
str(activityTest)
str(activityTraining)

##COMBINE THE RELEVANT FILES
##subjectTest and subjectTraining have the same columns
##activityTest en activityTraining have the same columns
##featuresTest en featuresTraining havve the same columns
##so we can combine them by rbind
activityTotal <- rbind (activityTest, activityTraining)
subjectTotal <-rbind(subjectTest, subjectTraining)
labelsTotal <- rbind(labelsTest, labelsTraining)
##and give headings to the columns to make it more readable
names(subjectTotal) <- c("subject")
names(activityTotal)<- c("activity")
names(labelsTotal) <- features$V2

##now combine the columns
nearlyDone <-cbind(labelsTotal,cbind(subjectTotal, activityTotal))
##and find the columns that are about mean or std
##(I used a sourece for this bit: https://rstudio-pubs-static.s3.amazonaws.com/37290_8e5a126a3a044b95881ae8df530da583.html); would have had no idea how to think of that myself
subSetNames<-features$V2[grep("mean\\(\\)|std\\(\\)", features$V2)]
##and downsize the finalSet to just those columns
desiredColumnNames<-c(as.character(subSetNames), "subject", "activity" )
FinalSet<-subset(nearlyDone,select=desiredColumnNames)

##get the mean for every subject and every activity and make it into a tidy data set
FinalSetfinally<-aggregate(. ~subject + activity, FinalSet, mean)
FinalSetfinally<-FinalSetfinally[order(FinalSetfinally$subject,FinalSetfinally$activity),]
write.table(FinalSetfinally, file = "thisisthetidydata.txt",row.name=FALSE)




