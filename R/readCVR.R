#' Extract tabular data from Dominion CVR
#'
#'
#' @param path The path to data as a vector of strings, typically with a `".json"` file extension.
#' If the file is within an unzipped zip file, also specify `zipdir`.
#' @param zipdir if the json files are in a zipped file and you do not want to
#'  unzip the whole thing, you can list a `zipdir` so that the path `{zipdir}/{path}`
#'  corresponds to a file. Then the function will extract the file internally.
#' @param future Whether to attempt to parallelize across files. Defaults to FALSE.
#' @param .max_marks Maximum number of marks found in any counting session.
#'   If a file contains more marks than this amount, it will throw a long segfault error.
#' @return A dataframe where each row is a record. Does not turn into a tibble
#' @useDynLib dominionCVR
#'
#' @importFrom RcppSimdJson fparse
#' @importFrom purrr map map_dfr map
#' @importFrom furrr future_map_dfr future_map
#' @importFrom fs path_file
#' @importFrom tibble tibble
#' @importFrom magrittr %>%
#' @importFrom tictoc tic toc
#' @importFrom readr read_file_raw
#' @importFrom progressr progressor with_progress
#' @importFrom Rcpp evalCpp
#' @importFrom dplyr mutate bind_rows
#'
#' @examples
#'  js_files <- c("data-raw/json/CvrExport_42.json", "data-raw/json/CvrExport_24940.json")
#'  library(furrr)
#'  extract_cvr(path = js_files)
#'
#'  plan("multicore")
#'  extract_cvr(js_files, future = TRUE)
#' @export
extract_cvr <-
  function(path = NULL,
           zipdir = NULL,
           future = FALSE,
           verbose = TRUE,
           .max_marks = 1e5) {
    if (future) {
      my_map_dfr <- function(.x, .f) {
        future_map_dfr(.x,
                       .f,
                       .options = furrr_options(seed = TRUE))
      }
    }
    else {
      my_map_dfr <- map_dfr
    }
    tic()
    if (is.null(path))
      stop("Must have a path in `path`")

    with_progress({
      p <- progressor(steps = length(path))
      out <- my_map_dfr(path,
                        function(fn, zip = zipdir) {
                          p()
                          if (!is.null(zip))
                            the_json <- read_file_raw(unz(zip, fn))
                          else
                            the_json <- read_file_raw(fn)
                          fparse(the_json, max_simplify_lvl = "list") %>%
                            .$Sessions %>%
                            extract_marks(max_marks = .max_marks) %>%
                            mutate(file = fs::path_file(fn))
                        }) %>%
                # Unpack isAmbiguous and mdens fields
                mutate(isAmbiguous = isAmbiguous_mdens > 100,
                       mdens = isAmbiguous_mdens -
                               1000*(isAmbiguous_mdens > 100)) %>%
                select(-isAmbiguous_mdens)
    })

    # output
    toc()
    return(out)
  }
