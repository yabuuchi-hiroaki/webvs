library("word2vec") # word embedding
library("e1071")    # SVM 
source("src/plot_enrichment_curve.R")  # enrichment curve

##### Data #####

f <- read.table("data/plant_sen")
fl <- read.table("data/label", sep="\t", header=T)

##### Word embedding #####

w2v <- word2vec(f[,1], type="cbow", dim = 100)
mat <- as.matrix(w2v)
# write.word2vec(w2v, "table/plant.prf", "txt")

##### Machine learning of bioactivity of chemical compounds #####

label <- rep(0, length=nrow(mat))
for( i in 1: nrow(mat) ){
  if( ! is.na( fl[ rownames(mat)[i], 1] ) ){
    label[i] <- fl[ rownames(mat)[i], 1]
  }else if( length( grep("mesh(c|d)", rownames(mat)[i]) ) == 1){
    label[i] <- 2
  }
}
dat <- data.frame(mat, label)
i1 <- which(dat$label == 1)
i2 <- sample(which(dat$label == 2), length(i1) )
m <- dat[c(i1, i2),]
cv_model <- svm(label ~ ., data=m,
           kernel = "radial", type="C-classification",
           gamma = 2^(-8), cost = 1, cross = 5)
summary(cv_model)

model <- svm(label ~ ., data=m,
           kernel = "radial", type="C-classification",
           gamma = 2^(-8), cost = 1, probability=T)

##### Virtual screening of antimicrobial plants #####

i34 <- which(dat$label == 3 | dat$label == 4 )
mp <- dat[i34,]
pred <- predict(model, mp, probability=T)
r <- cbind(attr(pred, "probabilities")[,1], mp$label - 3)

plot_enrichment_curve(r[,1], r[,2])
legend(60, 30, legend=c("WEBVS","ideal", "random"),
  col=c("black","black","gray"), lty=c(1,2,3), lwd=c(1.5,1.5,1.5))
