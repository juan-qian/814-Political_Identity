# Load packages, reserve a core for OS and other programs
library(parallel)
library(doParallel)
library(tidyverse)
library(rvest)
library("jiebaR")
cl <- makeCluster(detectCores() - 1) # convention to leave 1 core for OS
registerDoParallel(cl)

#Scrap data
content<-sapply(PDWebpageList, function(url){
  tryCatch(
    url %>%
      as.character() %>% 
      read_html() %>% 
      html_nodes(xpath='//*[contains(concat( " ", @class, " " ), concat( " ", "c_c", " " ))]') %>% 
      html_text(),
      print(url),
    error = function(e){NA}    # a function that returns NA regardless of what it's passed
  )
})


#Clean scrapped data#
content <- gsub(".* \t\t\t\t　　", "", content)
content <- gsub("\r\n\r\n", "", content)
content <- trimws(content)
content<-filter(content, is.na(content)==FALSE)

#Graph Li Wenliang time trend data
liSearch<-read.csv("liwenliang_hits.csv")
liSearch <- filter(liSearch, is.na(search)==FALSE)
liSearch$date <- as.Date(liSearch$date, "%m/%d/%Y")
liSearch <- mutate(liSearch, logSearch = log(search))
ggplot(liSearch, aes(date, logSearch))+geom_line()+labs(x="Date since December 1, 2019", y="log(Number of Baidu Searches for Li Wenliang)")