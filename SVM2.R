require(e1071)
require(rgl)
FeaturesTrainingData <- read.csv("G:/8th sem/BTP Tomato Complete Sample/FinalBTPGUI/FeaturesTrainingData.csv")
View(FeaturesTrainingData)
ftd <- data.frame(R=FeaturesTrainingData$Radius,A=FeaturesTrainingData$Area,V=FeaturesTrainingData$Volume,W=FeaturesTrainingData$Weight,C=FeaturesTrainingData$Class)
View(ftd)
svm_model <- svm(C~., ftd, type='C-classification', kernel='linear',scale=FALSE)
w <- t(svm_model$coefs) %*% svm_model$SV 
detalization <- 100  
grid <- expand.grid(seq(from=min(ftd$R),to=max(ftd$R),length.out=detalization),                                                                                                         
                    seq(from=min(ftd$A),to=max(ftd$A),length.out=detalization)) 
z <- (svm_model$rho- w[1,1]*grid[,1] - w[1,2]*grid[,2]) / w[1,3]
plot3d(grid[,1],grid[,2],z,col = 'pink')  # this will draw plane.
# adding of points to the graphics.
points3d(ftd$R[which(ftd$C=='A')], ftd$A[which(ftd$C=='A')], ftd$V[which(ftd$C=='A')], ftd$W[which(ftd$C=='A')], col='red')
points3d(ftd$R[which(ftd$C=='A')], ftd$A[which(ftd$C=='B')], ftd$V[which(ftd$C=='B')], ftd$W[which(ftd$C=='B')], col='blue')
points3d(ftd$R[which(ftd$C=='A')], ftd$A[which(ftd$C=='C')], ftd$V[which(ftd$C=='C')], ftd$W[which(ftd$C=='C')], col='green')