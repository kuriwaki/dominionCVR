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
#' @useDynLib dominionCVR
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
#' @examples
#'
#'  js_files <- c("data-raw/json/CvrExport_42.json", "data-raw/json/CvrExport_24940.json")
#'  library(furrr)
#'  extract_cvr(path = js_files)
#'
#'  plan("multicore")
#'  extract_cvr(js_files, future = TRUE)
#'
#' @export
#'
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
                        })
    })

    # output
    toc()
    return(out)
  }

#
# Vestigial code from the days of mapping to parse the JSON
#

#' @keywords internal
.extract_from_file <- function(file) {
  map_dfr(file, ~ .extract_from_session(.x))
}

#' @keywords internal
.extract_from_session <- function(sess) {
  # Get "original" marks
  map_dfr(sess$Original$Cards, ~ .extract_from_card(.x)) %>%
    mutate(
      originalModified = "O",
      precinct = sess$Original$PrecinctPortionId,
      ballotType = sess$Original$BallotTypeId,
      isCurrent = sess$Original$IsCurrent
    ) %>%
    # Add "modified" marks
    bind_rows(
      map_dfr(sess$Modified$Cards, ~ .extract_from_card(.x)) %>%
        mutate(
          originalModified = "M",
          precinct = sess$Modified$PrecinctPortionId,
          ballotType = sess$Modified$BallotTypeId,
          isCurrent = sess$Modified$IsCurrent
        )
    ) %>%
    mutate(
      tabulator = sess$TabulatorId,
      batch = sess$BatchId,
      recordId = sess$RecordId,
      countyGroupId = sess$CountingGroupId,
      sessionType = sess$SessionType,
      votingSessionId = sess$VotingSessionIdentifier,
      uniqueVotingIdentifer = sess$UniqueVotingIdentifier
    )
}

#' @keywords internal
.extract_from_card <- function(card) {
  map(card$Contests, ~ .extract_from_contest(.x, card)) %>%
    unlist(recursive = FALSE)
}

#' @keywords internal
.extract_from_contest <- function(cont, card) {
  map(cont$Marks, ~ .extract_from_mark(.x, card, cont))
}


#' @keywords internal
.extract_from_mark <- function(mark, card, cont) {
  list(
    cardId = card$Id,
    paperIndex = card$PaperIndex,
    contestId = cont$Id,
    overvotes = cont$Overvotes,
    undervotes = cont$Undervotes,
    candidateId = mark$CandidateId,
    rank = mark$Rank,
    mdens = mark$MarkDensity,
    isAmbig = mark$IsAmbiguous,
    isVote = mark$IsVote
  )
}
