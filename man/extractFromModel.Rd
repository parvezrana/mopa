% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extractFromModel.R
\name{extractFromModel}
\alias{extractFromModel}
\title{Extrac objects from lists returned by function \code{\link[mopa]{mopaTrain}}}
\usage{
extractFromModel(models, value = c("model", "auc", "kappa", "tss",
  "fold.models", "ObsPred"))
}
\arguments{
\item{models}{Object returned by \code{\link[mopa]{mopaTrain}}.}

\item{value}{Any character of the following: "model", "auc", "kappa", "tss", "fold.models", "ObsPred"}
}
\value{
Depending on the specified value:
 \item{model }{fitted model using all data for training}
 \item{auc }{AUC statistic in the cross validation}
 \item{kappa }{kappa statistic in the cross validation}
 \item{tss }{true skill statistic in the cross validation }
 \item{fold.models }{fitted model with partitioned data}
 \item{ObsPred }{Observed and prediced (cross model prediction) values}
}
\description{
Extract values returned by function \code{\link[mopa]{mopaTrain}}
}
\details{
\code{ObsPred} allows to calculate further accuracy measures.
}
\examples{
\donttest{
data(Oak_phylo2)

destfile <- tempfile()
data.url <- "https://raw.githubusercontent.com/SantanderMetGroup/mopa/master/data/biostack.rda"
download.file(data.url, destfile)
load(destfile, verbose = TRUE)

r <- biostack$baseline[[1]]
## Create background grid
bg <- backgroundGrid(r)
## Generate pseudo-absences
RS_random <-pseudoAbsences(xy = Oak_phylo2, background = bg$xy, 
                           exclusion.buffer = 0.083*5, prevalence = -0.5, kmeans = FALSE)
## Model training
fittedRS <- mopaTrain(y = RS_random, x = biostack$baseline, 
                      k = 10, algorithm = "glm", weighting = TRUE)
## Extract fitted models
mods <- extractFromModel(models = fittedRS, value = "model")
## Extract observed and predicted values
ObsPred <- extractFromModel(models = fittedRS, value = "ObsPred")
}

}
\author{
M. Iturbide
}
