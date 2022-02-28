library(dplyr)
library(ggplot2)

r_no=1
load(paste0("/scratch/project_2000994/PREBASruns/finRuns/outSample/r_no",r_no,".rdata"))

datAllScenNorm <- datAllScen
datAllScenNormProtect <- datAllScenProtect
setkey(areas,segID)
setkey(datAllScenNorm,segID)
setkey(areasProtect,segID)
setkey(datAllScenNormProtect,segID)
datAllScenNorm <- merge(datAllScenNorm,areas)
datAllScenNormProtect <- merge(datAllScenNormProtect,areasProtect)
vars <- colnames(datAllScenNorm)[!colnames(datAllScenNorm) %in% c("segID","area","year","maakID","harScen")]
# datAllScenNorm[,normFact:=area*length(areas$area)/sum(areas$area)]
datAllScenNorm[, vars] <- 
  datAllScenNorm[ ,lapply(.SD, `*`, area*length(areas$area)/sum(areas$area)), .SDcols = vars]

datAllScenNormProtect[, vars] <- 
  datAllScenNormProtect[ ,lapply(.SD, `*`, area*length(areasProtect$area)/sum(areasProtect$area)), .SDcols = vars]

plot.list <- list()
i=0
for(varX in vars){
  i=i+1
  sumryX <- datAllScenNorm %>%   
    group_by(year, harScen) %>%
    summarise(medi = median(get(varX),na.rm=T),
              q0.25 = quantile(get(varX),probs=0.25,na.rm=T),
              q0.75 = quantile(get(varX),probs=0.75,na.rm=T))

  sumryXProtect <- datAllScenNormProtect %>%   
    group_by(year, harScen) %>%
    summarise(medi = median(get(varX),na.rm=T),
              q0.25 = quantile(get(varX),probs=0.25,na.rm=T),
              q0.75 = quantile(get(varX),probs=0.75,na.rm=T))

  sumryX <- rbind(sumryX,sumryXProtect)
  plot.list[[i]] <- ggplot(sumryX)+
    geom_ribbon(aes(x = year + 2016, ymin = q0.25, ymax = q0.75,fill= harScen), alpha = 0.3)+
    geom_line(aes(x = year+ 2016, y = medi, color = harScen)) +
    xlab("year") + ylab(varX)
  
  i=i+1

  plot.list[[i]] <- ggplot(sumryX)+
    # geom_ribbon(aes(x = year + 2016, ymin = q0.25, ymax = q0.75,fill= harScen), alpha = 0.3)+
    geom_line(aes(x = year+ 2016, y = medi, color = harScen)) + 
    xlab("year") + ylab(varX)
}

pdf(paste0("outSample/plots",r_no,".pdf"))
for(i in 1:length(plot.list)) print(plot.list[[i]])
dev.off()

