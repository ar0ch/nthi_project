set terminal svg
set output 'stats_20.svg'
set title "Allele clusters, ID-0.20"
binwidth = 1
set boxwidth binwidth
set xrange [0:18]
set style fill solid 1.0 border -1
bin(x,width)=width*floor(x/width)
plot '20.stats.txt' using (bin($1,binwidth)):(1.0) smooth freq with boxes notitle
