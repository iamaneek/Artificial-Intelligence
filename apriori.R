
install.packages("arules")
install.packages("arulesViz")
install.packages("tidyverse")
install.packages("readxml")
install.packages("knitr")
install.packages("lubridate")
install.packages("plyr")
install.packages("rCBA")


library(arules)
library(arulesViz)
library(tidyverse)
library(readxl)
library(knitr)
library(ggplot2)
library(lubridate)
library(plyr)
library(dplyr)
library("rCBA")

retail <- read_excel('online_retail.xlsx')
#complete.cases(data) will return a logical vector indicating which rows have no missing values. Then use the vector to get only rows that are complete using retail[,].
retail <- retail[complete.cases(retail), ]

str(retail)

#mutate function where Description column and Country are being converted to factor column. 
retail %>% mutate(Description = as.factor(Description))
retail %>% mutate(Country = as.factor(Country))


#Converts character data to date. Store InvoiceDate as date in new variable
retail$Date <- as.Date(retail$InvoiceDate)

#Extract time from InvoiceDate and store in another variable
TransTime<- format(retail$InvoiceDate,"%H:%M:%S")

#Convert and edit InvoiceNo into numeric
InvoiceNo <- as.numeric(as.character(retail$InvoiceNo))

retail_and_time=cbind(retail,TransTime)

retail_and_time=cbind(retail_and_time,InvoiceNo)

glimpse(retail)



#ddply(dataframe, variables_to_be_used_to_split_data_frame, function_to_be_applied)
transactionData <- ddply(retail,c("InvoiceNo","Date"),
                         function(df1)paste(df1$Description,
                                            collapse = ","))
#The R function paste() concatenates vectors to character and separated results using collapse=[any optional charcater string ]. Here ',' is used

#Invoice and Date wont be used. So set column InvoiceNo of dataframe transactionData  

transactionData$InvoiceNo <- NULL
transactionData$Date <- NULL
#Rename column to items
colnames(transactionData) <- c("items")
#Show Dataframe transactionData
transactionData

write.csv(transactionData,"E:/AI/apriori/market_basket_transactions.csv", quote = FALSE, row.names = FALSE)

tr <- read.transactions('E:/AI/apriori/market_basket_transactions.csv', format = 'basket', sep=',')
#sep tell how items are separated. In this case you have separated using ','


summary(tr)


if (!require("RColorBrewer")) {
  # install color package of R
  install.packages("RColorBrewer")
  #include library RColorBrewer
  library(RColorBrewer)
}
itemFrequencyPlot(tr,topN=20,type="absolute",col=brewer.pal(8,'Pastel2'), main="Absolute Item Frequency Plot")
itemFrequencyPlot(tr,topN=20,type="relative",col=brewer.pal(8,'Pastel2'), main="Relative Item Frequency Plot")

association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8,maxlen=10))

inspect(association.rules[1:10])


fp_rules = rCBA::fpgrowth(tr, support=0.03, confidence=0.03, maxLength=2, 
                       parallel=FALSE)



shorter.association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8,maxlen=3))

subset.rules <- which(colSums(is.subset(association.rules, association.rules)) > 1) # get subset rules in vector
length(subset.rules)  #> 3913

subset.association.rules. <- association.rules[-subset.rules] # remove subset rules.

#For example, to find what customers buy before buying 'METAL' run the following line of code:
metal.association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8),appearance = list(default="lhs",rhs="METAL"))


inspect(head(metal.association.rules))

metal.association.rules <- apriori(tr, parameter = list(supp=0.001, conf=0.8),appearance = list(lhs="METAL",default="rhs"))

inspect(head(metal.association.rules))

# Filter rules with confidence greater than 0.4 or 40%
subRules<-association.rules[quality(association.rules)$confidence>0.4]
#Plot SubRules
plot(subRules)


plot(subRules,method="two-key plot")

plotly_arules(subRules)
top10subRules <- head(subRules, n = 10, by = "confidence")

plot(top10subRules, method = "graph",  engine = "htmlwidget")


subRules2<-head(subRules, n=20, by="lift")
plot(subRules2, method="paracoord")
