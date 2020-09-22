library(plyr)
library(dplyr)

test <- read.table("UCI HAR Dataset/test/X_test.txt")
train <- read.table("UCI HAR Dataset/train/X_train.txt")
testlabel <- read.table("UCI HAR Dataset/test/y_test.txt")
trainlabel <- read.table("UCI HAR Dataset/train/y_train.txt")
testsubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
trainsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

## Merge training and test sets
fulldata <- rbind(test, train)


## Change column labels to descriptive variable names
collabels <- as.character(read.table("UCI HAR Dataset/features.txt")[,2])
names(fulldata) <- collabels


## Extract mean and sd for each measurement
meansd <- grep("[Mm]ean\\(|std\\(", names(fulldata)) ## 66 obs which is right
data <- select(fulldata, names(fulldata)[meansd])
table(table(names(data))) # each variable name is unique


## Add the activity names
labels <- rbind(testlabel, trainlabel)
labels <- as.factor(labels[,1])
labels <- revalue(labels, c("1"="walking","2"="walking_upstars","3"="walking_downstairs",
                            "4"="sitting","5"="standing","6"="laying"))
data <- cbind("activity" = labels, data)


## 5. 2nd data set with average of each variable for each activity and each subject
subjects <- rbind(testsubjects, trainsubjects)
data <- cbind("subjectid" = subjects, data)
names(data)[1] <- "subjectid" # rename column

detach("package:plyr", unload=TRUE) # without unloading plyr package, there seems to be problems
newdata <- data %>% group_by(activity,subjectid) %>% summarise(across(everything(), mean))

write.table(newdata, file = "tidydata.txt", row.names = FALSE) 



