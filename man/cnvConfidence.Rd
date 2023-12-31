% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cnvConfidence.R
\name{cnvConfidence}
\alias{cnvConfidence}
\title{cnvConfidence}
\usage{
cnvConfidence(
  RE,
  cnv,
  ph = FALSE,
  m1 = 0.2,
  m2 = 0.8,
  m3 = 1.2,
  m4 = 1.8,
  nameofnewdf = "CNVrank"
)
}
\arguments{
\item{RE}{RaggedExperiment object used to store all information.}

\item{cnv}{List of CNVs in a dataframe containing CNVs from detection algorithms/ pipelines. Must use one which contains at least MeanScore, Qlow, Qhigh and anova p-values. If Post-hoc tests have also been performed, these results can also be used by this function.}

\item{ph}{If Dunnet tests was  performed, the p-value from the tests can be taken into account. Default is FALSE.}

\item{m1}{Value used to cut-off the highest mean score allowed for HOMOZYGOUS DELECTIONS, and lowest cut-off for HETEROZYGOUS DELETIONS. Default is 0.2.}

\item{m2}{Value used to cut-off the highest mean score allowed for HETEROZYGOUS DELETINS. Default is 0.8.}

\item{m3}{Value used to cut-off the lowest mean score allowed for HETEROZYGOUS DUPLICATIONS. Default is 1.2.}

\item{m4}{Value used to cut-off the lowest mean score allowed for HETEROZYGOUS DUPLICATIONS. Default is 1.8.}

\item{nameofnewdf}{Name of new dataframe to be saved in metadata(RE)[['CNVlist']]. Default is CNVrank.}
}
\value{
A new cnv file with additional columns which describe our level of confidence of the detected CNV being a true CNV.
}
\description{
Flags the confidence of the CNV being a true CNV. The flags range from Very Unconfident - Very Confident. Our clinicians preferred variants to be flagged rather than filtered out - so we simply do this. Confidence scores will be added to the cnv file given. The cnv file should be one which contains all the statistical results from other functions of the SARC package.
}
\examples{
data("test_cnv")
test_cnv <- test_cnv[c(1:3),]
data("test_cov")
SARC <- regionSet(cnv = test_cnv, cov = test_cov)
SARC <- regionSplit(RE = SARC, cnv = metadata(SARC)[['CNVlist']][[1]],
                     startlist = metadata(SARC)[[2]],
                      endlist = metadata(SARC)[[3]])
SARC <- regionMean(RE = SARC, cnv = metadata(SARC)[['CNVlist']][[1]],
                  splitcov = metadata(SARC)[[4]])
SARC <- regionQuantiles(RE = SARC, cnv = metadata(SARC)[['CNVlist']][[2]],
                        meancov = metadata(SARC)[[3]], q1 =.1, q2 = .9)
SARC <- prepAnova(RE = SARC, cnv = metadata(SARC)[['CNVlist']][[3]],
                 start = metadata(SARC)[[2]], end=metadata(SARC)[[3]])
SARC <- anovaOnCNV(RE = SARC, cnv = metadata(SARC)[['CNVlist']][[3]],
                  anovacov = metadata(SARC)[[8]])
SARC <- cnvConfidence(RE = SARC, cnv = metadata(SARC)[['CNVlist']][[4]])
}
