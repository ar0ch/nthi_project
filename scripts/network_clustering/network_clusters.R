## Aroon Chande 2016
## Jordan Lab, Georgia Tech
## Use ANI data to cluster strains by leading eigenvector
library(igraph)
library(ggplot2)
data = read.table('ANIm_percentage_identity.tab', header=T, sep='\t', row.names=1)
max <- apply(data, 2, max)
min <- apply(data, 2, min)
data <- scale(data, center = min, scale = max - min)
labels = as.data.frame(read.table('labels.csv', row.names = 1, header = T, fill = TRUE, sep = ","))
colnames(labels) <- c("class")
lablist <- sort(unique(labels[,"class"]))
colourlist =c("deepskyblue2","red", "black","darkorange1","darkgoldenrod1","darkorchid4","darkslategray4","gray80","darkolivegreen2")
label_colours = data.frame(row.names=sort(lablist),colourlist)
labels$colours = label_colours[labels$class,]
g <- graph_from_adjacency_matrix(as.matrix(data), mode = "undirected", 
                                 weighted = T, diag = F, add.rownames = T
                                 )
cle <- cluster_leading_eigen(g, steps = -1, start= NULL, options=arpack_defaults)
cluster = as.vector(cle$membership)
names= as.vector(row.names(data))
groups <- data.frame(names,cluster)
rownames(groups) <- groups[,1]
membership <- merge(labels,groups, by=0)
clustnum <- tail(sort(unique(groups[,"cluster"])),1)
for (i in 1:clustnum) {
outfile <- sprintf("cluster_%i.pdf", i)
pdf(outfile)
subcluster <- subset(membership, cluster  < i+1 & cluster > i-1)
g2 <- induced.subgraph(graph=g, as.vector(subcluster$Row.names))
leg <- subcluster[ ! duplicated( subcluster[ c("class" , "colours") ] ) , ]
plot.igraph(g2, vertex.color=as.vector(subcluster$colours), vertex.size = 15,
              add = FALSE, vertex.label=NA,
              edge.color="lightgrey")
legend(x=0, y=-1.1, leg$class, pch=21,
       col="#777777", pt.bg=as.vector(leg$colours), pt.cex=2, cex=.8, bty="n", ncol=1)
dev.off()
}

