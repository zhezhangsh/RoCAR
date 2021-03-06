# Download a file via URL to a given directory and return the path to the downloade file
# When the file is local, copy it to the given path
DownloadFile<-function(url, path, check.existence=TRUE) {
  # url               The URL to the file to be downloaded
  # path              The path where to save the downloaded file
  # check.existence   Check if the URL exists before downloading. If the URL not exists, return the URL without any effect.
  
  require(RCurl);
  require(awsomics);
  require(RoCA);
  
  if (file.exists(url)) { # actually a local file
    fn <- paste(path, TrimPath(url), sep='/')
    fn.tmp <- paste(fn, '.tmp', sep=''); 
    if (file.exists(fn.tmp)) file.remove(fn.tmp); 
    file.copy(url, fn.tmp, overwrite = TRUE); 
    file.rename(fn.tmp, fn); 
    fn; 
  } else {
    if (check.existence & !url.exists(url)) url else {
      if (!dir.exists(path)) dir.create(path, recursive = TRUE);
      fn <- paste(path, TrimPath(url), sep='/'); 
      
      done <- FALSE;
      tryCatch({
        download.file(url, fn); 
        done <- TRUE;
      }, error = function(err) {
        cat('Downloading failed, trying different method ...\n')
      }, finally = {}); 
      
      if (!done) {
        tryCatch({
          download.file(url, fn, method='wget'); 
          done <- TRUE;
        }, error = function(err) {
          cat('Downloading failed, trying different method ...\n')
        }, finally = {}); 
      }
      
      if (!done) {
        tryCatch({
          download.file(url, fn, method='curl'); 
          done <- TRUE;
        }, error = function(err) {
          cat('Downloading failed, trying different method ...\n')
        }, finally = {}); 
      }
      
      fn; 
    }
  }
}
