# MIT License Copyright 
#(c) 2016 Aroon Chande 
#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in
#the Software without restriction, including without limitation the rights to
#use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
#of the Software, and to permit persons to whom the Software is furnished to do
#so, subject to the following conditions: The above copyright notice and this
#permission notice shall be included in all copies or substantial portions of
#the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO 
#EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES 
#OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
#ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
#DEALINGS IN THE SOFTWARE.

##############################################################################
##############################################################################
## Creates a stacked dot histogram from an ANI table


require(ggplot2)
require(extrafont)
ANIdata <-
  as.matrix(
    read.table(
      "ANIm_percentage_identity.tab", header = TRUE, comment.char = "", row.names =
        1, sep = "\t", check.name = FALSE
    )
  )
hflu = c(
  "86-028NP","2019","10810","CGSHiCZ412602","F3031","F3047","KR494","NCTC8143","PittEE","PittGG","R2864","R2866","RdKW20"
)
hhaem = c(
  "M19107","M21127","M21621","M21639","M25342","M11818","M19476","HK386","M16859","M21639","M21501","M16386","M19080"
)
hother = c(
  "H.massiliensis","H.parainfluenzae","H.paraphrohaemolyticus","H.pittmaniae","H.sputum_genomic","HK386","Histophilus_somnus"
)
nthi = c(
  "M03959","M04744","M04827","M04828","M05964","M06436","M07055","M07066","M07572","M08234","M08351","M09394","M10178","M10210","M10230","M10364","M10482","M10540","M10991","M11311","M11363","M11600","M11696","M11840","M11879","M11900","M11908","M11921","M11955","M12066","M12084","M12086","M12178","M12252","M12353","M12373","M12969","M13539","M14002","M14079","M14416","M14444","M14486","M14626","M14700","M15301","M15928","M16180","M16690","M16860","M23816","M24471","M24820","M25147","M25693","M26026","M26032","M26429","M27986","M27987","M28356","M28405","M28687","M28702","M28745","M28770","M28801","M28853","M28888","M29179","M29197","M29202","M29227","M29307","M29323","M29331","M29400","M29658","M29684","M29695","M29697","M36557","M36564","M36580","M36582","M36605","M36606","M37248","M37982","M3825","M3835","M3844","M6399"
)
M26354 = c("M25364")
HfGaT = c("M19501","H.sp._C1")
column = colnames(ANIdata)
classes = ANIdata
for (i in 1:length(column)){
  for (j in 1:length(column)){
    if(column[i] %in% hflu && column[j] %in% hflu){
      classes[i,j] = "Hflu (self)"
    } else if(column[i] %in% hhaem && column[j] %in% hhaem){
      classes[i,j] = "Hhaem (self)"
    }else if(column[i] %in% nthi && column[j] %in% nthi){
      classes[i,j] = "NTHi (self)"
    }else if(column[i] %in% hother && column[j] %in% hother){
      classes[i,j] = "Other Haem (self)"
    }else if((column[i] %in% hflu || column[i] %in% hhaem) && (column[j] %in% hhaem || column[j] %in% hflu)){
      classes[i,j] = "Hflu v Hhaem"
    } else if((column[i] %in% hflu || column[i] %in% hother) && (column[j] %in% hother || column[j] %in% hflu)){
      classes[i,j] = "Hflu v Other"
    } else if((column[i] %in% hflu || column[i] %in% nthi) && (column[j] %in% nthi || column[j] %in% hflu)){
      classes[i,j] = "Hflu v NTHi"
    }else if((column[i] %in% nthi || column[i] %in% hhaem) && (column[j] %in% hhaem || column[j] %in% nthi)){
      classes[i,j] = "NTHi v Hhaem"
    }else if((column[i] %in% hother || column[i] %in% hhaem) && (column[j] %in% hhaem || column[j] %in% hother)){
      classes[i,j] = "Other v Hhaem"
    }else if((column[i] %in% nthi || column[i] %in% hother) && (column[j] %in% hother || column[j] %in% nthi)){
      classes[i,j] = "NTHi v Other"
    }else if((column[i] %in% M26354 || column[i] %in% HfGaT) && (column[j] %in% HfGaT || column[j] %in% M26354)){
      classes[i,j] = "M25364 v HfGat"
    } else if((column[i] %in% HfGaT || column[i] %in% hflu) &&( column[j] %in% hflu || column[j] %in% HfGaT)){
      classes[i,j] = "HfGaT v Hflu"
    }else if((column[i] %in% HfGaT || column[i] %in% nthi) && (column[j] %in% nthi || column[j] %in% HfGaT)){
      classes[i,j] = "HfGaT v Hflu"
    }else if((column[j] %in% HfGaT || column[j] %in% hhaem) && (column[j] %in% hhaem || column[j] %in% HfGaT)){
      classes[i,j] = "HfGaT v Hhaem"
    } else if((column[i] %in% M26354 || column[i] %in% hflu) && (column[j] %in% hflu || column[j] %in% M26354)){
      classes[i,j] = "M25364 v Hflu"
    }else if((column[i] %in% M26354 || column[i] %in% nthi) &&( column[j] %in% nthi || column[j] %in% M26354)){
      classes[i,j] = "M25364 v Hflu"
    }else if((column[i] %in% M26354 || column[i] %in% hhaem) && (column[j] %in% hhaem || column[j] %in% M26354)){
      classes[i,j] = "M25364 v Hhaem"
    }else {
      classes[i,j] = "NTHi v Other"
    }
  }
}
# Cast as vector, dotplot needs a dataframe not matrix
x = as.vector(ANIdata)
## Plot through var
# Set color pallete for use in scale_colour_manual and scale_fill_manual
colpal =c("orange","red","gold","lightblue","gold","black","grey35","green","magenta","black","grey55","lightblue","black","black","black")
# Cast as vector, dotplot needs a dataframe not matrix
Comparison = as.vector(classes)
# Dataframe for dotplot
pdata = data.frame(x,Comparison)
# Remove dupes, makes plot cleaner and easier
pdata <- pdata[!duplicated(pdata[1:2]),]
p <- (ggplot(pdata, aes(x=x, pch="16")) 
      # Prepare to kill yourself
      + geom_dotplot(aes(color=Comparison, 
        fill=Comparison, pch="16"),
        # Change binwidth for better smoothing. Set to at minimum the 3 digit (e.g. 0.001 for 1-scaled values or 0.1 for 100 scaled values)
        binwidth=0.0005, 
        method='histodot', 
        dotsize = 1 , 
        stackgroups = TRUE,
        binpositions = "dotdensity"
        ) 
     + labs(x="ANI Values", y="Pairwise Comparisons", title = "ANI stacked dot plot")
     # Remove Y ticks + scale
     + (scale_y_continuous(breaks=NULL))
     # Set bg white, all markings black
     + theme_bw() 
     # outer ring
     + scale_colour_manual(values = colpal)
     # Inside fill
     + scale_fill_manual(values = colpal)
     # Vertical line at species cutouff, add label
     + geom_vline(xintercept = .96, col="grey")
     + geom_text(aes(x=.96, label="ANIm species cutoff", y=.5), family = "Source Code Pro ExtraLight", color="black", nudge_x=.002, angle=90)
     )
pdf("stackedPoints.pdf", useDingbat=FALSE, height=11, width=8.5, family = "Source Code Pro ExtraLight")
plot(p)
dev.off()
embed_fonts("stackedPoints.pdf")
