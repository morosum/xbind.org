options(stringsAsFactors = FALSE)
cargs = commandArgs(TRUE)
local = cargs[1] == 'TRUE'

build_one = function(io)  {
  # if output is not older than input, skip the compilation
  if (!blogdown:::require_rebuild(io[2], io[1])) return()

  if (local) message('* knitting ', io[1])
  if (blogdown:::Rscript(shQuote(c('R/build_one.R', io))) != 0) {
    unlink(io[2])
    stop('Failed to compile ', io[1], ' to ', io[2])
  }
}

# Rmd files under the content directory
rmds = list.files('content', '[.]Rmd$', recursive = TRUE, full.names = TRUE)
if (length(rmds)) {
  files = cbind(rmds, gsub('.Rmd$', '.md', rmds))
  for (i in seq_len(nrow(files))) {
    build_one(unlist(files[i, ]))
  }
}

# add https://xliu.updog.co/static to image/video URLs /figures/...
# "sed.exe" in "%ProgramFiles%/Git/usr/bin/", add to PATH first
#if (!local && Sys.which('sed') != '') for (i in files[, 2]) {
#  Sys.chmod(i, '644')  # unlock .md
#  system2('sed', paste(
#    "-i '' -e 's@\\([(\"]\\)\\(/figures/\\)@\\1https://xliu.updog.co/static\\2@g'", i
#  ))
#  Sys.chmod(i, '444')  # lock .md again
#}

if (TRUE) {
  message('Optimizing PNG files under static/')
  for (i in list.files('static', '[.]png$', full.names = TRUE, recursive = TRUE)) {
    system2('optipng', shQuote(i), stderr = FALSE)
  }
}
