library(dplyr)

if (!file.exists("final_project.zip")){
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                "final_project.zip", 
                method="curl")
}  

if (!file.exists("UCI HAR Dataset")) { 
  unzip("final_project.zip") 
}

setwd("UCI HAR Dataset")

#base dataframes

names_features <- c("id_function","name_function")
features_data <- read.table("features.txt", col.names = names_features)
names_activities <- c("id_activity", "name_activity")
activities_data <- read.table("activity_labels.txt", col.names = names_activities)
features_functions <- features_data$name_function
x_train_data <- read.table("train/X_train.txt", col.names = features_functions)
x_test_data <- read.table("test/X_test.txt", col.names = features_functions)
x_merged <- rbind(x_train_data, x_test_data)


y_train_data <- read.table("train/y_train.txt", col.names = "id_activity")
y_test_data <- read.table("test/y_test.txt", col.names = "id_activity")
y_merged <- rbind(y_train_data, y_test_data)

subject_test_data <- read.table("test/subject_test.txt", col.names = "subject")
subject_train <- read.table("train/subject_train.txt", col.names = "subject")
subject_merged <- rbind(subject_train, subject_test_data)



#merging relevant dataframes

complete <- cbind(subject_merged, x_merged, y_merged)


filtered <- select(complete, subject, id_activity, matches("mean|std"))
filtered$id_activity <- activities_data[filtered$id_activity, 2]
names(filtered)<-gsub("BodyBody", "body", names(filtered))
names(filtered)<-gsub("^t", "time", names(filtered))
names(filtered)<-gsub("^f", "frequency", names(filtered))
names(filtered)<-gsub("tBody", "time_body", names(filtered))
names(filtered)<-gsub("-mean()", "mean", names(filtered), ignore.case = TRUE)
names(filtered)<-gsub("-std()", "std", names(filtered), ignore.case = TRUE)
names(filtered)<-gsub("-freq()", "frequency", names(filtered), ignore.case = TRUE)
names(filtered)[2] <-  "activity"


#new dataset

summary_data <- filtered %>%  group_by(subject, activity) %>% summarise_all(list(mean = mean))
summary_data
