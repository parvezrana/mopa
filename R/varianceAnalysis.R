#' @title Variance analysis of RasterStack objects
#' @description Extract componets of list of objects 
#' (as returned by function \code{\link[mopa]{mopaPredict}}) 
#' and perform variance analysis to obtain raster objects of the 
#' contribution of each component to the observed varaibility.
#' 
#' 
#' @param predictions list of raster objects as returned by \code{\link[mopa]{mopaPredict}}
#' @param component1 Character of the names in \code{predictions} that correspond to the first component in 
#' the variance analysis.
#' @param component2 Character of the names in \code{predictions} that correspond to the second component in 
#' the variance analysis.
#' 
#' @details Rasters are extracted from \code{predictions} using function \code{\link[base]{grep}} with names 
#' in \code{predictions} and characters in \code{componen1} and \code{componen2}.
#' 
#' @return A list of two RasterStack objects, the first containing the global mean and standard deviation and the 
#' second containing the variance correponding to each component in the analysis 
#' (component1, component2 and components 1 & 2)
#' 
#' @author M. Iturbide 
#' 
#' @references San-Martín, D., Manzanas, R., Brands, S., Herrera, S. & Gutiérrez, J.M. (2016) Reassessing 
#' Model Uncertainty for Regional Projections of Precipitation with an Ensemble of Statistical Downscaling Methods. 
#' Journal of Climate 30, 203–223.
#' 
#' @examples
#' \dontrun{
#' data(Oak_phylo2)
#' data(biostack)
#' projection(biostack$baseline) <- CRS("+proj=longlat +init=epsg:4326")
#' r <- biostack$baseline[[1]]
#' 
#' ## Background of the whole study area
#' bg <- backgroundGrid(r)
#' 
#' 
#' ## considering an unique background extent
#' RS_random <-pseudoAbsences(xy = Oak_phylo2, background = bg$xy, 
#' realizations = 10,
#' exclusion.buffer = 0.083*5, prevalence = -0.5, kmeans = FALSE)
#' 
#' fittingRS <- mopaTrain(y = RS_random, x = biostack$baseline, k = 10, 
#' algorithm = "glm", weighting = TRUE)
#' 
#' modsRS <- extractFromModel(models = fittingRS, value = "model")
#' 
#' #MODEL PREDICTION AND ANALYSIS OF THE VARIABILITY IN PROJECTIONS
#' prdRS.fut <- mopaPredict(models = modsRS, varstack = biostack$future)
#' component2 <- names(prdRS.fut$realization01)
#' component1 <- names(prdRS.fut)
#' result <- varianceAnalaysis(prdRS.fut, component1, component2)
#' spplot(result$variance, col.regions = rev(get_col_regions()))
#' }
#' 
#' 
#' @export
#' 

varianceAnalysis <- function(predictions, component1, component2){
  comp2 <- list()
  for(i in 1:length(component2)){
    comp2[[i]] <- extractFromPrediction(predictions, component2[i])
  }
  names(comp2) <- component2
  
  comp1 <- list()
  for(i in 1:length(component1)){
    comp1[[i]] <- extractFromPrediction(comp2, component1[i])
  }
  bothcomp <- stack(unlist(comp1))
  names(bothcomp)
  if(length(component1)*length(component2)!= nlayers(bothcomp)) stop("speciefied components do not completely 
                                                                     match with layer names in predictions")
  datos <- array(NA, dim = c(length(component1)*length(component2), ncell(bothcomp)), dimnames = list(names(bothcomp)))
  for(i in 1:nlayers(bothcomp)){
    datos[i, ] <- bothcomp[[i]]@data@values
  }
  
  mediaGlobal <- apply(datos, FUN = "mean", MARGIN=2, na.rm = TRUE)
  varGlobal <- apply(datos, FUN = "sd", MARGIN=2, na.rm = TRUE)*sqrt((nrow(datos)-1)/nrow(datos))
  
  
  mediacomp1 <- matrix(data = NA, nrow = length(component1), ncol = ncol(datos))
  for(i in 1:length(component1)){
    indcomp1 <- ((i-1)*length(component2)+1):(i*length(component2))
    mediacomp1[i,] <- apply(datos[indcomp1,], FUN = "mean", MARGIN=2, na.rm = TRUE)
  }
  rownames(mediacomp1) <-component1
  
  mediacomp2 <- matrix(data = NA, nrow = length(component2), ncol = ncol(datos))
  for(i in 1:length(component2)){
    mediacomp2[i,] <- apply(datos[seq(i,nrow(datos),length(component2)),], FUN = mean, MARGIN=2, na.rm = TRUE)
  }
  dos <- apply(mediacomp2, FUN = "sd", MARGIN=2, na.rm = TRUE)*sqrt((length(component2)-1)/length(component2))
  uno <- apply(mediacomp1, FUN = "sd", MARGIN=2, na.rm = TRUE)*sqrt((length(component1)-1)/length(component1))
  
  uno.dos <- matrix(data = NA, nrow = nrow(datos), ncol = ncol(datos))
  for(i in 1:length(component1)){
    for(j in 1:length(component2)){
      uno.dos[(i-1)*length(component2)+j,] <- (datos[(i-1)*length(component2)+j,] - mediacomp2[j,] - mediacomp1[i,] + mediaGlobal)^2
    }
  }
  
  uno.dos <- apply(uno.dos, FUN = "mean", MARGIN=2, na.rm = TRUE)
  
  plot(dos^2+uno^2+uno.dos, typ = "l")
  lines(varGlobal^2, col = "red")
  sd(dos^2+uno^2+uno.dos - varGlobal, na.rm = T)
  mean(dos^2+uno^2+uno.dos - varGlobal, na.rm = T)
  
  ########################################################################-----
  
  uno100 <- uno^2 *100 / (uno^2+dos^2+uno.dos)
  dos100 <- dos^2 *100 / (uno^2+dos^2+uno.dos)
  uno.dos100 <- uno.dos *100 / (uno^2+dos^2+uno.dos)
  nan.ind <- which(uno100 == "NaN")
  dos100[nan.ind] <- 0
  uno100[nan.ind] <- 0
  uno.dos100[nan.ind] <- 0
  
  
  bothcomp[[1]]@data@values <- uno100
  bothcomp[[2]]@data@values <- dos100
  bothcomp[[3]]@data@values <- uno.dos100
  bothcomp[[4]]@data@values <- varGlobal
  bothcomp[[5]]@data@values <- mediaGlobal
  l1 <- stack(bothcomp[[5]], bothcomp[[4]])
  l2 <- stack(bothcomp[[1]], bothcomp[[2]], bothcomp[[3]])
  
  names(l1) <- c("mean", "sd")
  names(l2) <- c("component 1", "component 2", "components 1 and 2")
  
  return(list("mean" = l1, "variance" = l2))
}


#end