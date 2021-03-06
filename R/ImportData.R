# Import a table-like data object saved within a file in one of various supported formats:
# .txt, .tab, .tsv, .csv, .bed, .xlsx, .xls, .html, .rdata, .rda, .rds
# The format of the data will be determined based on the file name extension
ImportTable <- function(fn, rownames=TRUE, colnames=TRUE, sep=NA, ind=1, warn=TRUE) {
  # fn          Name of the file to be imported
  # rownames    For text file to be imported, whether the first column has the row names
  # colnames    For text file to be imported, whether the first row has the column names
  # sep         For text file to be imported, what's separator. Use function defaul if NA
  # ind         For file formats such as Excel and HTML, the index of table to be imported
  # warn        Print a warning message if file format not recognaize; stop with error otherwise
  
  ext <- tolower(rev(strsplit(fn, '\\.')[[1]])[1]);
  
  if (ext == 'rds' | ext == 'rdata' | ext == 'rda') {
    
    if (ext == 'rds') d <- readRDS(fn) else d <- eval(parse(text = load(fn)));
    
    if (class(d) != 'data.frame' & class(d) != 'matrix') {
      if (class(d) == 'GRanges') {
        # Convert to BED-like format
        e <- elementMetadata(d);
        d <- data.frame(seqname = as.vector(seqnames(d)), start=start(d), end=end(d), strand = as.vector(strand(d)), 
                        row.names = names(d), stringsAsFactors = FALSE); 
        rownames(d) <- names(e); 
        if (ncol(e) > 0) d <- cbind(d, as.data.frame(e)); 
        
      } else stop('Loaded R object is in a class not convertible to a table: ', class(d), '\n');
    }
  } else if (ext == 'txt' | ext == 'tab' | ext == 'bed') {
    
    if (is.na(sep[1])) sep <- '\t' else sep <- sep[1];
    if (rownames) {
      d <- read.table(fn, sep=sep, header=colnames, row.names=1, stringsAsFactors=FALSE);
      colnames(d)[ncol(d):1] <- rev(strsplit(readLines(fn, n=1), sep)[[1]])[1:ncol(d)]; 
    } else  d <- read.table(fn, sep=sep, header=colnames, stringsAsFactors=FALSE); 
    
  } else if (ext == 'tsv') {
    if (is.na(sep[1])) sep <- '\t';
    if (rownames) d <- read.delim(fn, sep=sep, header=colnames, row.names = 1) else d <- read.delim(fn, sep=sep, header=colnames); 
  } else if (ext == 'csv') {
    
    if (is.na(sep[1])) sep <- ',' else sep <- sep[1];
    if (rownames) {
      d <- read.csv(fn, sep=sep, header=colnames, row.names=1, stringsAsFactors=FALSE);
      colnames(d)[ncol(d):1] <- rev(strsplit(readLines(fn, n=1), sep)[[1]])[1:ncol(d)]; 
      colnames(d) <- gsub('"', '', colnames(d));
    } else d <- read.csv(fn, sep=sep, header=colnames, stringsAsFactors=FALSE); 
    
  } else if (ext == 'xlsx' | ext == 'xls') {
    
    require('readxl');
    d <- as.data.frame(read_excel(fn, col_names=colnames, sheet=ind));
    if (rownames) {
      rownames(d) <- d[[1]];
      d <- d[, -1];
    }

  } else if (ext == 'html' | ext == 'htm') {
    
    require(XML); 
    d0 <- readHTMLTable(fn, header=colnames, which=ind); 
    fn.tmp <- 'html_import_tmp.txt';  # for reading numeric columns properly
    write.table(d0, fn.tmp, sep='\t', row.names = FALSE, col.names = colnames, quote = FALSE); 
    d <- ImportTable(fn.tmp, rownames = rownames, colnames = colnames); 
    file.remove(fn.tmp); 
    
  } else {
    
    if (warn) {
      warning('Unknown data format: ', ext, '\n');
      d <- NA;
    } else stop('Error: file extension of "', fn, '" not recognized\n');

  }

  d; 
}

# Import a list-like data object saved within a file in one of various supported formats
# The format of the data will be determined based on the file name extension
ImportList <- function(fn, rownames=TRUE, sep=NA, ind=1, warn=TRUE) {
  # fn          Name of the file to be imported
  # rownames    For text file to be imported, whether each row starts with the row name
  # sep         For text file to be imported, what's separator. Use function defaul if NA
  # ind         For Excel file, the index of table to be imported
  # warn        Print a warning message if file format not recognaize; stop with error otherwise
  
  ext <- tolower(rev(strsplit(fn, '\\.')[[1]])[1]);
  
  if (ext == 'rds') {
    
    d <- readRDS(fn); 
    
  } else if (ext == 'rdata' | ext == 'rda') {
    
    d <- eval(parse(text = load(fn)));
    
  } else if (ext == 'txt' | ext == 'tab' | ext == 'csv') {
    
    if (is.na(sep[1])) if (ext == 'csv') sep <- ',' else sep <- '\t' else sep <- sep[1];
    lns <- scan(fn, flush=TRUE, sep='\n', what='');
    d   <- strsplit(lns, sep);
    if (rownames) {
      names(d) <- sapply(d, function(d) d[1]); 
      d <- lapply(d, function(d) d[-1]); 
    }

  } else if (ext == 'xlsx' | ext == 'xls') {
    
    require('readxl');
    d <- as.data.frame(read_excel(fn, col_names=FALSE, sheet=ind));
    if (rownames) {
      rnm <- d[[1]];
      d <- d[, -1];
    } else rnm <- rep('', nrow(d));
    d <- as.matrix(d); 
    d <- lapply(1:nrow(d), function(i) as.vector(d[i, ]));
    d <- lapply(d, function(d) d[!is.na(d)]); 
    names(d) <- rnm;
    
  } else if (ext == 'html' | ext == 'htm') {
  
    require(XML); 
    d <- readHTMLList(fn, header=colnames, which=ind); 

  } else if (ext == 'yaml' | ext == 'yml') {
    
    require(yaml); 
    d <- yaml.load_file(fn);
    
  } else if (ext == 'json') {
    
    require(rjson);
    d <- fromJSON(fn);
    
  } else {
    
    if (warn) {
      warning('Unknown data format: ', ext, '\n');
      d <- NA;
    } else stop('Error: file extension of "', fn, '" not recognized\n');
    
  }
  
  d; 
}

# Import a vector-like data object saved within a file in one of various supported formats
# The format of the data will be determined based on the file name extension
ImportVector <- function(fn, rownames=TRUE, sep=NA, ind=1, warn=TRUE) {
  # fn          Name of the file to be imported
  # sep         For text file to be imported, what's separator. Use function defaul if NA
  # ind         For Excel file, the index of table to be imported
  # warn        Print a warning message if file format not recognaize; stop with error otherwise
  
  ext <- tolower(rev(strsplit(fn, '\\.')[[1]])[1]);
  
  if (ext == 'rds') {
    
    d <- readRDS(fn); 
    
  } else if (ext == 'rdata' | ext == 'rda') {
    
    d <- eval(parse(text = load(fn)));
    
  }  else if (ext == 'txt' | ext == 'tab') {
    
    if (is.na(sep[1])) sep <- '\t' else sep <- sep[1];
    t <- read.table(fn, header=FALSE, sep = sep, stringsAsFactors = FALSE); 
    if (nrow(t) == 1) d <- as.vector(as.matrix(t)[1, ]) else {
      if (ncol(t) < 2) d <- t[[1]] else {
        d <- t[[2]]; 
        names(d) <- t[[1]]; 
      }
    }
   
  } else if (ext == 'csv') {
    
    if (is.na(sep[1])) sep <- ',' else sep <- sep[1];
    t <- read.csv(fn, header=FALSE, sep = sep, stringsAsFactors = FALSE);
    if (nrow(t) == 1) d <- as.vector(as.matrix(t)[1, ]) else {
      if (ncol(t) < 2) d <- t[[1]] else {
        d <- t[[2]]; 
        names(d) <- t[[1]]; 
      }
    }
    
  } else if (ext == 'xlsx' | ext == 'xls') {
    
    require('readxl');
    t <- as.data.frame(read_excel(fn, col_names=FALSE, sheet=ind));
    if (nrow(t) == 1) d <- as.vector(as.matrix(t)[1, ]) else {
      if (ncol(t) < 2) d <- t[[1]] else {
        d <- t[[2]]; 
        names(d) <- t[[1]]; 
      }
    }
    
  } else {
    
    if (warn) {
      warning('Unknown data format: ', ext, '\n');
      d <- NA;
    } else stop('Error: file extension of "', fn, '" not recognized\n');
    
  }
  
  d; 
}

# Import R object from a file with one of these file extension: .rda, .rdata, and rds
ImportR <- function(fn, warn=TRUE) {
  # fn          Name of the file to be imported
  # warn        Print a warning message if file format not recognaize; stop with error otherwise

  ext <- tolower(rev(strsplit(fn, '\\.')[[1]])[1]);
  
  if (ext == 'rds') {
    
    d <- readRDS(fn); 
    
  } else if (ext == 'rdata' | ext == 'rda') {
    
    d <- eval(parse(text = load(fn)));
    
  } else {
    
    if (warn) {
      warning('Unknown data format: ', ext, '\n');
      d <- NA;
    } else stop('Error: file extension of "', fn, '" not recognized\n');
    
  }
  
  d; 
}
