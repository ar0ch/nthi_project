library('shiny')
library('genoPlotR')

shinyServer(function(input, output, session) {

observe({
    # switch tab
    if ( (!is.null(input$genome) | ( !is.null(input$genome) | !is.null(input$gffFile))) & input$submit != 0L ) {
      updateTabsetPanel(session, "vchot6ss", selected = "T6SS Predictions")
    }
  })

  # return computed descriptors
  annotPlot = reactive({
    

    predCond = input$predict

    if ( predCond == 'pred' & input$submit != 0L & !is.null(input$genome) ) {
      outdir = substr(input$genome$datapath,1,nchar(input$genome$datapath)-1)
      annotate <- paste('/home/blast/prediction_server/server/predict_t6.pl -predict yes -fasta ',input$genome$datapath)
      #system('echo "',input$genome$datapath,'\n$(date) >> ~/vibrio_project/webtest.txt"', intern = TRUE)
      system(annotate)
      genplotdata <- paste('/home/blast/prediction_server/server/gff.pl -fasta ',input$genome$datapath)
      system(genplotdata)
      filelist = dir(outdir, pattern = "*.ptt")
      dna <- list()
      annot <- list()
      for (i in 1:length(filelist)){
        file = paste(outdir,filelist[i], sep="")
        dna[[i]] <- read_dna_seg_from_ptt(file)
        mid_pos <- middle(dna[[i]])
        annot[[i]] <- annotation(x1=mid_pos, text=dna[[i]]$name, rot = "45")
      }
      
      plot_gene_map(dna_segs=dna, annotations=annot)
    }
    if ( predCond == 'nopred' & input$submit != 0L & !is.null(input$genome) & !is.null(input$gffFile)) {
      outdir = substr(input$genome$datapath,1,nchar(input$genome$datapath)-1)
      annotate <- paste('/home/blast/prediction_server/server/predict_t6.pl -predict no -fasta ',input$genome$datapath,' -gff ',input$gffFile$datapath)
      #system('echo "',input$genome$datapath,'\n$(date) >> ~/vibrio_project/webtest.txt"', intern = TRUE)
      system(annotate)
      genplotdata <- paste('/home/blast/prediction_server/server/gff.pl -fasta ',input$genome$datapath,' -gff ',input$gffFile$datapath)
      system(genplotdata)
      filelist = dir(outdir, pattern = "*.ptt")
      dna <- list()
      annot <- list()
      for (i in 1:length(filelist)){
        file = paste(outdir,filelist[i], sep="")
        dna[[i]] <- read_dna_seg_from_ptt(file)
        mid_pos <- middle(dna[[i]])
        annot[[i]] <- annotation(x1=mid_pos, text=dna[[i]]$name, rot = "45")
      }
      
      plot_gene_map(dna_segs=dna, annotations=annot)
    }
    else {
      return(NULL)
    }
  })

  output$plot = renderPlot({
    annotPlot() })
  output$dlFasta = downloadHandler(
    filename = function() { paste("proteins", paste(collapse = '-'),
                                  '-', gsub(' ', '-', gsub(':', '-', Sys.time())),
                                  '.faa', sep = '') },
    content = function(file) {
      outdir = substr(input$genome$datapath,1,nchar(input$genome$datapath)-1)
      copyFile = paste(outdir,"prots.faa", sep="")
      file.copy(copyFile, file)}
  )
output$dlPreds = downloadHandler(
    filename = function() { paste("predictions", paste(collapse = '-'),
                                  '-', gsub(' ', '-', gsub(':', '-', Sys.time())),
                                  '.faa', sep = '') },
    content = function(file) {
      outdir = substr(input$genome$datapath,1,nchar(input$genome$datapath)-1)
      copyFile = paste(outdir,"predictions.faa", sep="")
      file.copy(copyFile, file)}
  )

})
