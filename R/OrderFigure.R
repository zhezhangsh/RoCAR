# Automatically generate figure order for RoCA reports
OrderFigure <- function(reset=FALSE) {
  if (!exists('figure.count', -1) | reset==TRUE) figure.count <<- 0;
  figure.count <<- figure.count + 1;
  figure.count;
}; 

# Automatically generate table order for RoCA reports
OrderTable <- function(reset==FALSE) {
  if (!exists('table.count', -1) | reset==TRUE) table.count <<- 0;
  table.count <<- table.count + 1;
  table.count;
}; 