file_names = list.files(".", pattern="*.Rmd")
file_names = substr(file_names, 1, nchar(file_names)-4)
is_dashboard = grepl("dashboard", file_names, fixed=TRUE)
has_failures = FALSE

for (file_name in file_names[is_dashboard]) {
  cat(sprintf("Rendering %s ... ", file_name))
  t0 = proc.time()
  tryCatch(
    suppressWarnings(suppressMessages(
      rmarkdown::render(
        paste0(file_name, ".Rmd"),
        output_format = "html_document",
        output_file = paste0(file_name, ".html"),
        envir = new.env(),
        quiet = TRUE
      )
    )),
    error = function(e) {
      cat(e$message)
      has_failures <<- TRUE
    }
  )
  t1 = proc.time()
  cat(sprintf("%0.2f s\n", (t1 - t0)[3]))
}

# Failures do not prevent other dashboards from running, but should result in an
# error status being set.
if (has_failures) {
  quit(status = 1)
}
