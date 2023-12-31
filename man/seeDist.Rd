% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seeDist.R
\name{seeDist}
\alias{seeDist}
\title{seeDist}
\usage{
seeDist(meanList, cnv, sample, plotly = FALSE, colourCNV = "red", size = 2)
}
\arguments{
\item{meanList}{List of dataframes which show the ranked mean scores for each CNV. Stored in metadata after SARC::setDPlot.}

\item{cnv}{List of CNVs in a dataframe containing CNVs from detection algorithms/ pipelines. It is recommended that the most recently created cnv file is used. Check print(RE) to see more cnv files created by SARC.}

\item{sample}{Which CNV/ row from the cnv file should be checked. Default is 1.}

\item{plotly}{Should plotly be used - this could be useful when interested in seeing the samples at each point.}

\item{colourCNV}{Colour of the sample which had the CNV detected. Default is red.}

\item{size}{Size if the dots. Default is 2.}
}
\value{
A scatter graph which shows the mean score of read-depths for a particular region of DNA where a CNV was detected. The sample which had the CNV detected is coloured as red/ used selected colour.
}
\description{
Displays the distribution of mean scores from read depths from all the samples. This is a quick method of checking why some detected CNVs might be false positives. We expect true duplications to have very high read-depths and true deletions to have very low read-depths.
}
\examples{
data("test_cnv")
data("test_cov")
SARC <- regionSet(cnv = test_cnv, cov = test_cov)
SARC <- regionSplit(RE = SARC, cnv = metadata(SARC)[[1]][[1]],
                    startlist = metadata(SARC)[[2]],
                    endlist = metadata(SARC)[[3]])
SARC <- regionMean(RE = SARC, cnv = metadata(SARC)[[1]][[1]],
                   splitcov = metadata(SARC)[[4]])
SARC <- setQDplot(RE = SARC, meancov = metadata(SARC)[[5]])
p <- seeDist(meanList = metadata(SARC)[[6]], cnv = metadata(SARC)[[1]][[2]],
 plotly=FALSE, sample=1)
}
