#compare olivia to peter

#davids WD
setwd("/data/Dropbox/PostDoc/Manuscripts/HipHeight")

#chris WD
.libPaths("D:/R code")
setwd("I:/olivia hip height")

#not run
#comparing peters to olivias data.
#data2<-read.csv("mass_eff_3.csv")
plot(eff~eff2,data2)
#these two are disturbingly different....
#Not sure, actually, there is a fair bit of variation, but in general they seem to scale reasonably well.
lm(eff~eff2+0,data2)
abline(0,1)
with(data2, mean(eff/eff2, na.rm=T))#average agreement is within 1%
with(data2, sd(eff/eff2, na.rm=T))

library(ape)
library(geiger)
library(nlme)
library(phytools)
#library(picante)
#library(MASS)



#### hindlimb ####

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
#plot(pruned, cex = 0.5)
# order the data in mydata to be in the same sequence as in the tree
trait_order<-data.frame(mydata[pruned$tip.label,])
rownames(trait_order)<-pruned$tip.label
head(trait_order) # check that this worked
head(pruned$tip.label) # by comparing it to this

################
################
#Instead of using RMA, a phylogenetic generalised least-squares with ML optimization of Pagel's lambda is appropriate
DF.Tree<-data.frame(Mass=log10(trait_order$mass2),eff=log10(trait_order$eff2)
                    ,row.names=pruned$tip.label)
#Without phylogenetic correction
gls<-gls(eff~Mass
         ,data=DF.Tree
         ,method="ML")

#With correction
bm.gls<-gls(eff~Mass
            ,data=DF.Tree
            ,correlation=corPagel(1,pruned)
            ,method="ML")
#The slope is reduced by ~30%
#CIs
intervals(gls)
intervals(bm.gls)

#Visualise
plot(log10(eff)~log10(mass2),mydata, pch=19, font.lab = 2, col=mydata$diet, las = 1, ylab = expression(bold(paste("Effective hindlimb length"))), xlab = expression(bold(paste("Log10(body mass)"))))
abline(gls$coefficients[1],gls$coefficients[2], col='red')
abline(bm.gls, lty="dashed")


##%%%%%%%%%%%%%%%%%%%%%%%%%
##%%%%%%%%%%%%%%%%%%%%%%%%%
##%%%%%%%%%%%%%%%%%%%%%%%%%
##Idea 2: Node age vs slope
##%%%%%%%%%%%%%%%%%%%%%%%%%
##%%%%%%%%%%%%%%%%%%%%%%%%%
##%%%%%%%%%%%%%%%%%%%%%%%%%
#Get node-numbers
node.nr <- as.numeric(names(branching.times(pruned)))
#Get node age
node.age <- branching.times(pruned)

#Set-up data frame
Results_GLS = data.frame(Intercept=rep(NA, 1),Slope=rep(NA, 1), Node=rep(NA, 1), Age=rep(NA, 1)
                         , Taxa=rep(NA, 1)#this is the number of taxa included in the tree
                         , WeightFactor = rep(NA,1)#this is the ratio between maximum and minimum weight in the tree
                         , Rsquared=rep(NA,1))

#dude, this code is awesome!! 
#perform regression per node
for(i in 1:length(node.nr)){
  node <- node.nr[i]
  #This function reduces the phylogenetic tree to those taxa included in node X
  prune_updated <- drop.tip(pruned,pruned$tip.label[-match(tips(pruned, node), pruned$tip.label)])
  #This selects the corresponding data from the data frame
  DF.Tree.updated <-DF.Tree[match(tips(pruned, node), rownames(DF.Tree)),]
  #Regression
  bm.gls<-lm(eff~Mass,data=DF.Tree.updated)
  
  Results_GLS[i,1] <-bm.gls$coefficients[1]
  Results_GLS[i,2] <-bm.gls$coefficients[2]
  Results_GLS[i,3] <-node
  Results_GLS[i,4] <-node.age[i]
  Results_GLS[i,5] <- length(DF.Tree.updated$eff)
  Results_GLS[i,6] <- max(10^DF.Tree.updated$Mass)/min(10^DF.Tree.updated$Mass)
  Results_GLS[i,7] <- summary(bm.gls)$r.squared
}

#Only include nodes which contain more than 30 taxa to increase robustness
Results_GLS_restricted <- subset(Results_GLS, Taxa>10 & WeightFactor > 20 & Rsquared > 0.3)
plot(Results_GLS_restricted$Age, Results_GLS_restricted$Slope, log="x")#not sure why this is logged...
#Indeed, positive correlation between slope ang node age
with(Results_GLS_restricted, cor.test(Age, Slope))
summary(fit<-lm(Slope~Age,Results_GLS_restricted))
plot(Slope~Age,Results_GLS_restricted)
abline(fit)


#identify node with high scaling
head(Results_GLS)
ind<-subset(Results_GLS, Slope>0.05 & Taxa>10 & WeightFactor > 20 & Rsquared > 0.3)

node <- ind$Node[4]
#This function reduces the phylogenetic tree to those taxa included in node X
prune_updated <- drop.tip(pruned,pruned$tip.label[-match(tips(pruned, node), pruned$tip.label)])
plot(prune_updated)
#This selects the corresponding data from the data frame
DF.Tree.updated <-DF.Tree[match(tips(pruned, node), rownames(DF.Tree)),]
#Regression
bm.gls<-lm(eff~Mass,data=DF.Tree.updated)
plot(eff~Mass,data=DF.Tree.updated)

#example of third idea
#ancestral states. 
aa <- fastAnc(prune_updated, DF.Tree.updated$Mass)
aa1 <- fastAnc(prune_updated, DF.Tree.updated$eff)
node.nr <- as.numeric(names(branching.times(prune_updated)))
#check to make sure the oder is the same
#Get node age
node.age <- branching.times(prune_updated)
DF.trim<-data.frame(Age=node.age,Nnum=node.nr,Mass=as.matrix(aa),eff=as.matrix(aa1))

par(mfrow=c(1,2))
plot(Mass~Age,DF.trim,col="blue", pch=20)
#mass is increasing over time
plot(eff~Age,DF.trim,col="red", pch=20)
#mass is increasing over time


