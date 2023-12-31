#' plotCNV
#'
#' @description Plots of the region of the DNA from several samples where a CNV is detected. The sample with the detected CNV, from the cnv file, will be highlighted in purple. Additional specificity such as gene of interest, or batch of WES/ WGS can be specified. This function is made to be easily looped for multiple CNVs. It is also made as a quick and more visually preferable alternative to looking for true CNVs visually.
#'
#'
#' @param cnv List of CNVs in a dataframe containing CNVs from detection algorithms/ pipelines. It is recommended to use the most recently generated cnv file. Check print(RE) to see if cnv files from other analyses have been generated.
#' @param setup ist of dataframes which have been processed for plotting. This will be stored as metadata in the RE object after SARC::setupCNVPlot.
#' @param FilteredCNV Which CNV from the list of dataframes (setup) should be plotted. Can be automated within a for-loop. Default is 1.
#' @param batch If WES/ WGS was performed in batches, users may wish to plot samples from different batches separately. In this case, a column called 'BATCH' should be found in the cnv file. Different batches should be labelled with differentiating strings, and this string should be added to the batch parameter. Default is NULL.
#' @param nSamples Numbers of samples to be printed in the plots. Default is 10. Add an integer to represent how many subplots should be made. The higher the number, the more difficult the plot will be for viewing.
#' @param gene String of a gene of interest. Only this gene will be printed. It must match standard gene symbols e.g. FCGR3A, P53. Only one string should be inputted at a time. The default is null.
#' @param log Applies log normalisation to reads. This can be helpful in WES data, where reads can be quite disperse across a short region of DNA. Recommended is 2, and default is NULL.
#' @param logbase Base to log read depth by - default is 2.
#'
#' @return A grid plot showing the read-depths for a specific regions of the the genome. This region will contain one samples which will have had a CNV detected. Heat-plot like colouring will be used to visually show if the sample has a significant change at this region, in contrast to several other samples.
#' @export
#' @import ggplot2 RColorBrewer grid gridExtra gtable scales
#'
#' @examples
#' if (requireNamespace("TxDb.Hsapiens.UCSC.hg38.knownGene", quietly = TRUE)) {
#' require("TxDb.Hsapiens.UCSC.hg38.knownGene")
#' } else {}
#'
#' if (requireNamespace("Homo.sapiens", quietly = TRUE)) {
#' require("Homo.sapiens")
#' } else {}
#'
#' data("test_cnv")
#' test_cnv <- test_cnv[c(1),]
#' data("test_cov")
#' SARC <- regionSet(cnv = test_cnv, cov = test_cov)
#' SARC <- regionSplit(RE = SARC, cnv =  metadata(SARC)[['CNVlist']][[1]],
#'                     startlist = metadata(SARC)[[2]],
#'                     endlist = metadata(SARC)[[3]])
#' SARC <- plotCovPrep(RE = SARC, cnv = metadata(SARC)[['CNVlist']][[1]],
#'                     startlist = metadata(SARC)[[2]],
#'                     endlist = metadata(SARC)[[3]])
#' SARC <- regionGrangeMake(RE = SARC, covprepped = metadata(SARC)[[4]])
#'
#' TxDb(Homo.sapiens) <- TxDb.Hsapiens.UCSC.hg38.knownGene
#' txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
#' tx <- transcriptsBy(Homo.sapiens, columns = "SYMBOL")
#' txgene <- tx@unlistData
#'
#' SARC <- addExonsGenes(RE = SARC, covgranges = metadata(SARC)[[6]],
#'                       txdb = txdb, txgene = txgene)
#'
#' SARC <- setupCNVplot(RE = SARC, namedgranges =  metadata(SARC)[[7]],
#'                   covprepped = metadata(SARC)[[4]])
#' p <- plotCNV(cnv =  metadata(SARC)[['CNVlist']][[1]],
#'              setup = metadata(SARC)[[8]], FilteredCNV=1)
plotCNV <- function(cnv, setup, FilteredCNV=1, batch=NULL,
                    nSamples=NULL, gene=NULL, log=NULL, logbase=2){

  if (missing(cnv)) stop('cnv is missing. Add cnv dataframe. Ideally the most recently created cnv file should be used.')

  if (missing(setup)) stop('setup is missing. Should be stored as metadata after SARC::setupCNVPlot.')

  EXON <- GENE <- START <- READ <- SAMPLE <- NULL

  b <- cnv

  #extract specific sample
  sb <- b[FilteredCNV,]

  ml <- setup[[FilteredCNV]]

  #select batch of data to use in plot

  if (is.null(batch)==TRUE) {

    samples <- as.vector(unique(b$SAMPLE))

  } else if (is.null(batch)==FALSE) {

    b2 <- b[which(b$BATCH == batch),]

    samples <- as.vector(unique(b2$SAMPLE))

  }


  #remove sample with detected CNV in region

  samples <- samples[!samples == sb$SAMPLE]

  #add several other samples to the sample with the detected sample

  if (is.null(nSamples)==TRUE) {

    if (isTRUE(length(samples) > 10)) {

      samples <- c(sample(samples, 10), sb$SAMPLE)

    } else if (isFALSE(length(samples) > 10)){


      samples <- c(sample(samples, length(samples)), sb$SAMPLE)
    }

  } else if (is.null(nSamples)==FALSE) {

    if (isTRUE(length(samples) > nSamples)) {

      samples <- c(sample(samples, nSamples), sb$SAMPLE)

    } else if (isFALSE(length(samples) > nSamples)){

      samples <- c(sample(samples, length(samples)), sb$SAMPLE)

    }
  }


  #get a df with the samples selected above

  df <- ml[which(ml$SAMPLE %in% samples),]

  #select a specific Gene to investigate

  if (is.null(gene) == TRUE) {

    df <- df

  } else if(is.null(gene) == FALSE){

    df <- df[which(df$GENE == gene),]

  }

  #apply log if the plot requires it

  if (is.null(log) == TRUE){
    df <- df
  } else if(is.null(log) == FALSE) {
    df$READ <- ifelse(df$READ==0, 1, df$READ)
    df$READ <- log(df$READ, logbase)
    df$READ <- round(df$READ, 1)
  }

  #make more columns for the plots

  df$FEATURE <- paste0(df$START, ":", df$EXON)

  df$FEATURE2 <- paste0(df$GENE, ":", df$EXON)

  #order the x-axis based on nucleotide positions

  df <- df[order(df$START, decreasing = FALSE),]

  #specify sample which had the CNV detected

  samp <- df[which(df$SAMPLE == sb$SAMPLE),]

  #create plot

  p <- ggplot(data = df, aes(x = interaction(START, GENE, EXON), y = READ,

                        group = 1, fill=READ)) +

    geom_rect(data = subset(df, SAMPLE %in% sb$SAMPLE),

              fill = "purple", colour = "black", xmin = -Inf,xmax = Inf,

              ymin = -Inf,ymax = Inf, linewidth=1)+

    geom_col(width = 1, position = "identity") +

    theme_classic()+

    labs(title=paste0(sb$CHROM, ":", sb$START, ":", sb$END),

         subtitle = paste0(sb$SAMPLE,":",sb$TYPE, "-", sb$VALUE),

         x=paste("Genomic Features"),y=paste(""))+

    facet_wrap(SAMPLE ~., ncol= 1, strip.position="left")+

    scale_fill_distiller(palette = "Spectral")+

    scale_x_discrete(label=samp$FEATURE2)+

    theme_dark()+

    theme(axis.text.x=element_text(size=10, angle = 45,

                                   vjust = 1, hjust = 1),

          axis.text.y=element_blank(),

          axis.ticks.y = element_blank(),

          legend.title =element_text(size=12, face="bold"),

          legend.text=element_text(size=10, face="bold"),

          axis.title.x=element_text(size=16, face="bold"),

          axis.title.y=element_blank(),

          strip.text.y.left = element_text(size = 10, angle = 0),

          panel.grid.major = element_blank(),

          panel.grid.minor = element_blank(),

          panel.spacing.y = unit(0, 'lines'),

          plot.title = element_text(size=18, face="bold",

                                    vjust = -1),

          plot.subtitle = element_text(size=12, face="bold",

                                       vjust = 6, hjust = 1))

  #return plot

  return(p)
}
