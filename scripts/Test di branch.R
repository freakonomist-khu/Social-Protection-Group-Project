library(tidyr)
library(ggplot2)

a<-1+1
print(a)

df <- read.csv("D:/0x. Master of Infrastructure Development Policy/03. Spring Semester 2026/Field Data Analysis/Group Project/Social-Protection-Group-Project/data/PER-Table1-Key-Indicators.csv")

head(df)
ggplot(df, aes(x=, y=Indicator.Value)) + 
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title="Indicator Value by Country", x="Country", y="Indicator Value")
