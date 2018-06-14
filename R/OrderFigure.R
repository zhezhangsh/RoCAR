# Automatically generate figure order for RoCA reports
OrderFigure <- function(format=TRUE, reset=FALSE) {
  if (!exists('figure.count', -1) | reset==TRUE) figure.count <<- 0 else {
    figure.count <<- figure.count + 1;
    if (!format) figure.count else paste('**Figure ', figure.count, '.**', sep='');
  };
};

# Automatically generate table order for RoCA reports
OrderTable <- function(format=TRUE, reset=FALSE) {
  if (!exists('table.count', -1) | reset==TRUE) table.count <<- 0 else {
    table.count <<- table.count + 1;
    if (!format) table.count else paste('**Table ', table.count, '.**', sep='');
  }
};
