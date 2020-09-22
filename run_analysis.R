test <- read.table("UCI HAR Dataset/test/X_test.txt")
train <- read.table("UCI HAR Dataset/train/X_train.txt")
testlabel <- read.table("UCI HAR Dataset/test/y_test.txt")
trainlabel <- read.table("UCI HAR Dataset/train/y_train.txt")
testsubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
trainsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

## 1. Merge training and test sets
data <- rbind(test, train)

## 2. Extract mean and sd for each measurement
means <- sapply(data, mean)
sds <- sapply(data, sd)


## 4. Descriptive variable names
collabels <- as.character(read.table("UCI HAR Dataset/features.txt")[,2])
table(table(collabels)) # there are 42 instances where there triplicates
# add _1/2/3 to the triplicated names
replicates <- unique(collabels[duplicated(collabels)])
for (i in replicates){
  indices <- which(collabels == i)
  collabels[indices[1]] <- paste(i, "_1", sep="")
  collabels[indices[2]] <- paste(i, "_2", sep="")
  collabels[indices[3]] <- paste(i, "_3", sep="")
}
table(table(collabels)) # no replicates
names(data) <- collabels

## 3. Descriptive activity names
library(plyr)
library(dplyr)
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



