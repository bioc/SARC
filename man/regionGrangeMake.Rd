% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/regionGrangeMake.R
\name{regionGrangeMake}
\alias{regionGrangeMake}
\title{regionGrangeMake}
\usage{
regionGrangeMake(RE, covprepped, range = 10, gap = 10)
}
\arguments{
\item{RE}{RaggedExperiment object used to store all information.}

\item{covprepped}{List of dataframes, each dataframe is small cov file which ranges the detected CNV. This should be the padded cov file created with SARC::plotCovPrep and will be in the matadata.}

\item{range}{Number of rows (genomic ranges) to group together as one entry for grange. As some WES platforms will have very short genomic start-end coordinates, this is useful to extract the exon/ gene data. Default is 10.}

\item{gap}{The gap between the start of one grange entry to the next entry. Default is 10.}
}
\value{
List of Grange Objects, one for each CNV detected.
}
\description{
Makes Grange objects for each region with a detected CNV.
}
\examples{
data("test_cnv")
test_cnv <- test_cnv[c(1:3),]
data("test_cov")
SARC <- regionSet(cnv = test_cnv, cov = test_cov)
SARC <- regionSplit(RE = SARC, cnv =  metadata(SARC)[['CNVlist']][[1]],
                    startlist = metadata(SARC)[[2]],
                    endlist = metadata(SARC)[[3]])
SARC <- plotCovPrep(RE = SARC, cnv = metadata(SARC)[['CNVlist']][[1]],
                    startlist = metadata(SARC)[[2]],
                    endlist = metadata(SARC)[[3]])
SARC <- regionGrangeMake(RE = SARC, covprepped = metadata(SARC)[[4]])
}
