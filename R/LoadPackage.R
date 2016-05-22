# Load a number of packages, install them first if not already installed
LoadPackage <- function(packages, reinstall=FALSE, 
                        list.source='https://raw.githubusercontent.com/zhezhangsh/RoCA/master/document/packages.txt') {
  # packages    Packages to be loaded
  # reinstall   Whether to re-install packages already installed
  # list.source List of known packages and their URL, a tab-delimited file with 3 fields: package source, package name, and package source URL.
  
  require(devtools); 
  require(RCurl); 
  
  # Packages to be installed
  if (!reinstall) {
    installed <- installed.packages(); 
    pkgs <- packages[!(packages %in% rownames(installed))];
  } else pkgs <- packages;
  
  # Install known packages
  if (length(pkgs) > 0) {
    known <- read.table(list.source, stringsAsFactors = FALSE); # known packages
    pkgs <- pkgs[!sapply(pkgs, function(p) {
      ind <- which(known[, 2] == p)[1]; 
      if (is.na(ind)) FALSE else {
        cat('Installing package: ', p, '\n'); 
        if (known[ind, 1] == 'github') install_github(known[ind, 3], quiet=TRUE) else install_url(known[ind, 3], quite=TRUE);
        TRUE;
      }
    })]; 
  }
  
  # Try to install unknown packages
  if (length(pkgs) > 0) {
    try(install.packages(pkgs)); # try Cran
    pkgs <- pkgs[!(pkgs %in% rownames(installed.packages()))]; 
    if (length(pkgs) > 0) { # then bioconductor
      source("http://bioconductor.org/biocLite.R"); 
      biocLite(pkgs, type="source", suppressUpdates = TRUE); 
      pkgs <- pkgs[!(pkgs %in% rownames(installed.packages()))]; 
      if (length(pkgs) > 0) { # try GitHub at last
         i <- try(sapply(pkgs, function(p) install_github(paste('https://github.com', p, sep='/'))));
      }
    }
  }
  
  # Load packages
  loaded <- sapply(packages, function(p) require(p, character.only = TRUE)); 
  
  loaded; 
}