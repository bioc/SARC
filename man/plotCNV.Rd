% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotCNV.R
\name{plotCNV}
\alias{plotCNV}
\title{plotCNV}
\usage{
plotCNV(
  cnv,
  setup,
  FilteredCNV = 1,
  batch = NULL,
  nSamples = NULL,
  gene = NULL,
  log = NULL,
  logbase = 2
)
}
\arguments{
\item{cnv}{List of CNVs in a dataframe containing CNVs from detection algorithms/ pipelines. It is recommended to use the most recently generated cnv file. Check print(RE) to see if cnv files from other analyses have been generated.}

\item{setup}{ist of dataframes which have been processed for plotting. This will be stored as metadata in the RE object after SARC::setupCNVPlot.}

\item{FilteredCNV}{Which CNV from the list of dataframes (setup) should be plotted. Can be automated within a for-loop. Default is 1.}

\item{batch}{If WES/ WGS was performed in batches, users may wish to plot samples from different batches separately. In this case, a column called 'BATCH' should be found in the cnv file. Different batches should be labelled with differentiating strings, and this string should be added to the batch parameter. Default is NULL.}

\item{nSamples}{Numbers of samples to be printed in the plots. Default is 10. Add an integer to represent how many subplots should be made. The higher the number, the more difficult the plot will be for viewing.}

\item{gene}{String of a gene of interest. Only this gene will be printed. It must match standard gene symbols e.g. FCGR3A, P53. Only one string should be inputted at a time. The default is null.}

\item{log}{Applies log normalisation to reads. This can be helpful in WES data, where reads can be quite disperse across a short region of DNA. Recommended is 2, and default is NULL.}

\item{logbase}{Base to log read depth by - default is 2.}
}
\value{
A grid plot showing the read-depths for a specific regions of the the genome. This region will contain one samples which will have had a CNV detected. Heat-plot like colouring will be used to visually show if the sample has a significant change at this region, in contrast to several other samples.
}
\description{
Plots of the region of the DNA from several samples where a CNV is detected. The sample with the detected CNV, from the cnv file, will be highlighted in purple. Additional specificity such as gene of interest, or batch of WES/ WGS can be specified. This function is made to be easily looped for multiple CNVs. It is also made as a quick and more visually preferable alternative to looking for true CNVs visually.
}
\examples{
if (requireNamespace("TxDb.Hsapiens.UCSC.hg38.knownGene", quietly = TRUE)) {
require("TxDb.Hsapiens.UCSC.hg38.knownGene")
} else {}

if (requireNamespace("Homo.sapiens", quietly = TRUE)) {
require("Homo.sapiens")
} else {}

data("test_cnv")
test_cnv <- test_cnv[c(1),]
data("test_cov")
SARC <- regionSet(cnv = test_cnv, cov = test_cov)
SARC <- regionSplit(RE = SARC, cnv =  metadata(SARC)[['CNVlist']][[1]],
                    startlist = metadata(SARC)[[2]],
                    endlist = metadata(SARC)[[3]])
SARC <- plotCovPrep(RE = SARC, cnv = metadata(SARC)[['CNVlist']][[1]],
                    startlist = metadata(SARC)[[2]],
                    endlist = metadata(SARC)[[3]])
SARC <- regionGrangeMake(RE = SARC, covprepped = metadata(SARC)[[4]])

TxDb(Homo.sapiens) <- TxDb.Hsapiens.UCSC.hg38.knownGene
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
tx <- transcriptsBy(Homo.sapiens, columns = "SYMBOL")
txgene <- tx@unlistData

SARC <- addExonsGenes(RE = SARC, covgranges = metadata(SARC)[[6]],
                      txdb = txdb, txgene = txgene)

SARC <- setupCNVplot(RE = SARC, namedgranges =  metadata(SARC)[[7]],
                  covprepped = metadata(SARC)[[4]])
p <- plotCNV(cnv =  metadata(SARC)[['CNVlist']][[1]],
             setup = metadata(SARC)[[8]], FilteredCNV=1)
}
