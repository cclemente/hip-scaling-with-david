#compare olivia to peter

setwd("G:/olivia hip height")

data2<-read.csv("mass_eff_3.csv")

plot(eff~eff2,data2)
#these two are disturbingly different....


library(ape)
library(geiger)
#library(nlme)
library(phytools)
#library(picante)
#library(MASS)

#### hindlimb ####

setwd("J:/olivia hip height") # set working directory
# load data
mydata<-read.csv("mass_eff_3.csv", row.names="name")
#remove NA values from peters data
mydata<-mydata[complete.cases(mydata),]
  
# load tree
myo<-read.nexus("nature05634-s2.txt")
myo1<-myo[[1]]
# prune tree by the species in mydata
matches<-name.check(myo1,mydata)
pruned<-drop.tip(myo1,matches$tree_not_data)

# Plot the pruned tree
plot(pruned, cex = 0.5)
# order the data in mydata to be in the same sequence as in the tree
trait_order<-data.frame(mydata[pruned$tip.label,])
rownames(trait_order)<-pruned$tip.label
head(trait_order) # check that this worked
head(pruned$tip.label) # by comparing it to this
# make a colour palette
palette(c("#2c7fb8", "#238b45", "#feb24c", "#de2d26", "#88419d")) 
#### Question 1: IS there a relationship betweenn mass and eff?? ####
# Scatterplot- same as the one we looked at previously, but coloured by diet
summary(fit<-lm(eff2~log10(mass2),mydata)) # create a linear model, save the intercept and slope to 'fit'
plot(eff~log10(mass2),mydata, pch=19, font.lab = 2, col=mydata$diet, las = 1, ylab = expression(bold(paste("Effective hindlimb length"))), xlab = expression(bold(paste("Log10(body mass)"))))
mydata$diet1 = factor(mydata$diet, levels = c('1','2', '3'),labels = c("Carnivore", "Herbivore", "Omnivore"))
legend("topleft", legend=levels(mydata$diet1), pch = 19, bty = "n", col = c(1:3))
abline(fit, col="red", lwd=2)

#RMA slope, similar to lm 
#library(smatr)
summary(fit<-ma(eff~log10(mass),mydata))
abline(fit$coef[[1]][1,1],fit$coef[[1]][2,1],col="blue", lwd =2)




# is there an effect of phylogeny on effective limb length? 
eff<-as.matrix(trait_order$eff2) # head(eff), Make a matrix of the 3rd column of trait_order (the eff column)
rownames(eff)<-rownames(trait_order) # Add the species names to the eff matrix as row names
effV <- eff[,1] # need this step.... turn 'eff' into a vector instead of dataframe
colnames(eff)<-"eff" # make the column name for the eff data 'eff'
head(eff) # make sure it worked by checking the original eff dataframe
head(effV) # against the massV dataframe

# phylosig randomises the massV data throughout the phylogenetic tree 10000 times to work out how likely
# it is that the effective limb length is in this order
phylosig(pruned, effV, method="lambda", test=TRUE, nsim=10000)
# very unlikely that effective limb length is in this order by chance- the p-value is ...

# is there an effect of phylogeny on mass? 
mass<-log10(as.matrix(trait_order$mass2)) # head(mass), log10 the mass values in 'trait_order'
rownames(mass)<-rownames(trait_order) # Add the species names to the log10(mass) as row names
massV <- mass[,1] # need this step.... turn 'mass' into a vector instead of dataframe
colnames(mass)<-"mass" # make the column name for the mass data 'mass'
head(mass) # make sure it worked by checking the original mass dataframe
head(massV) # against the massV dataframe

# phylosig randomises the massV data throughout the phylogenetic tree 10000 times to work out how likely
# it is that the mass is in this order
phylosig(pruned, massV, method="lambda", test=TRUE, nsim=10000)
# very unlikely that mass is in this order by chance- the p-value is 9.54835e-95



# Performs phylogenetic RMA regression.
# Phyl.RMA accounts for the effect of phylogeny on effective hip height as a function of mass. 
output<-phyl.RMA(massV, effV, pruned) 
# The intercept is now 0.6894501 (lower than before accounting for phylogeny)
# and the slope is 0.1012439 (steeper than before accounting for phylogeny) meaning that phylogeny
# lessens the effect of mass on effective hip height. p-value is significant: 2.611441e-52
# add the new line to the original plot
abline(output$RMA.beta[1],output$RMA.beta[2],col="purple", lwd =2)


