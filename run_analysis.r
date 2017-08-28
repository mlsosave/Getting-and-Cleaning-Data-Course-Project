##run_analysis.R 
 
#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names. 
#5. From the data set in step 4, creates a second, independent tidy data set 
#   with the average of each variable for each activity and each subject.

require("reshape2")

## 1. Merges the training and the test sets to create one data set.

setwd("C:\\DataScientist\\Getting and Cleaning Data\\week4")

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl,destfile="./Dataset.zip",mode="wb")
unzip(zipfile="./Dataset.zip",exdir=".")

# Load activity labels + features
# Reading activity labels:
activityLabels  <-  read.table(file.path(getwd(),"UCI HAR Dataset","activity_labels.txt"))
activityLabels[,2] <- as.character(activityLabels[,2])

# Reading feature vector:
features <- read.table(file.path(getwd(),"UCI HAR Dataset","features.txt"))
features[,2] <- as.character(features[,2])

#2. Extracts only the measurements on the mean and standard deviation for each measurement.

mean_std_features <- grep(".*mean.*|.*std.*", features[,2])
mean_std_features.names <- features[mean_std_features,2]
mean_std_features.names = gsub('-mean', 'Mean', mean_std_features.names)
mean_std_features.names = gsub('-std', 'Std', mean_std_features.names)
mean_std_features.names <- gsub('[-()]', '', mean_std_features.names)


# Load the datasets

##Read the training files

train <- read.table(file.path(getwd(),"UCI HAR Dataset","train","X_train.txt"))[mean_std_features]
trainActivities <- read.table(file.path(getwd(),"UCI HAR Dataset","train","y_train.txt"))
trainSubjects <- read.table(file.path(getwd(),"UCI HAR Dataset","train","subject_train.txt"))
train <- cbind(trainSubjects, trainActivities, train)

## Read the testing files

test <- read.table(file.path(getwd(),"UCI HAR Dataset","test","X_test.txt"))[mean_std_features]
testActivities <- read.table(file.path(getwd(),"UCI HAR Dataset","test","y_test.txt"))
testSubjects <- read.table(file.path(getwd(),"UCI HAR Dataset","test","subject_test.txt"))
test <- cbind(testSubjects, testActivities, test)

#3. Uses descriptive activity names to name the activities in the data set


# merge datasets and add labels
train_test_data <- rbind(train, test)

#4. Appropriately labels the data set with descriptive variable names

colnames(train_test_data) <- c("subject", "activity", mean_std_features.names)

# turn activities & subjects into factors
train_test_data$activity <- factor(train_test_data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
train_test_data$subject <- as.factor(train_test_data$subject)

train_test_data.melted <- melt(train_test_data, id = c("subject", "activity"))

#5. From the data set in step 4, creates a second, independent tidy data set 
#   with the average of each variable for each activity and each subject.

train_test_data.mean <- dcast(train_test_data.melted, subject + activity ~ variable, mean)

write.table(train_test_data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

