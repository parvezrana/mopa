% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kfold.R
\name{kfold}
\alias{kfold}
\title{Stratified random partitioning into subsets}
\usage{
kfold(k = 10, df)
}
\arguments{
\item{k}{Integer. Number of subsets. Default is 10}

\item{df}{Data frame with the variable for stratification in the first column}
}
\value{
List with k data frames
}
\description{
Internal function for stratified random partitioning into subsets of presence/absence
}
\author{
M. Iturbide
}
\keyword{internal}
