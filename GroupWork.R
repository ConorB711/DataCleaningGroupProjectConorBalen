if (!require("dplyr")) install.packages("dplyr", repos = "https://cloud.r-project.org")
library(dplyr)

features <- read.table("features.txt", col.names = c("index", "feature_name"))
activities <- read.table("activity_labels.txt", col.names = c("code", "activity"))

subject_train <- read.table("train/subject_train.txt", col.names = "subject")
x_train <- read.table("train/X_train.txt", col.names = features$feature_name)
y_train <- read.table("train/y_train.txt", col.names = "code")

subject_test <- read.table("test/subject_test.txt", col.names = "subject")
x_test <- read.table("test/X_test.txt", col.names = features$feature_name)
y_test <- read.table("test/y_test.txt", col.names = "code")

X_merged <- rbind(x_train, x_test)
Y_merged <- rbind(y_train, y_test)
Subject_merged <- rbind(subject_train, subject_test)
Merged_Data <- cbind(Subject_merged, Y_merged, X_merged)

Tidy_Data <- Merged_Data %>%
  select(subject, code, contains(".mean."), contains(".std."))

Tidy_Data$code <- activities[Tidy_Data$code, 2]

Tidy_Data <- Tidy_Data %>% rename(activity = code)
names(Tidy_Data) <- gsub("^t", "Time", names(Tidy_Data))
names(Tidy_Data) <- gsub("^f", "Frequency", names(Tidy_Data))
names(Tidy_Data) <- gsub("Acc", "Accelerometer", names(Tidy_Data))
names(Tidy_Data) <- gsub("Gyro", "Gyroscope", names(Tidy_Data))
names(Tidy_Data) <- gsub("Mag", "Magnitude", names(Tidy_Data))
names(Tidy_Data) <- gsub("BodyBody", "Body", names(Tidy_Data))
names(Tidy_Data) <- gsub("\\.mean\\.\\.\\.", "Mean", names(Tidy_Data))
names(Tidy_Data) <- gsub("\\.mean\\.\\.", "Mean", names(Tidy_Data))
names(Tidy_Data) <- gsub("\\.std\\.\\.\\.", "StdDev", names(Tidy_Data))
names(Tidy_Data) <- gsub("\\.std\\.\\.", "StdDev", names(Tidy_Data))
names(Tidy_Data) <- gsub("\\.", "", names(Tidy_Data))

Final_Tidy_Data <- Tidy_Data %>%
  group_by(subject, activity) %>%
  summarise(across(everything(), mean), .groups = "drop")

write.table(Final_Tidy_Data, "tidy_dataset.txt", row.name = FALSE)
print("SUCCESS: tidy_dataset.txt created!")
