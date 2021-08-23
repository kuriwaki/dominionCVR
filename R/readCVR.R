#' Extract tabular data from Dominion CVR
#'
#'
#' @param cvr,path The data. Use `cvr` for a list output from `jsonlite::fromJSON`,
#'  or use `path` to give the `fromJSON` path directly.
#' @param zipdir if the json files are in a zipped file and you do not want to
#'  unzip the whole thing, you can list a `zipdir` so that the path `{zipdir}/{path}`
#'  corresponds to a file. Then the function will extract the file internally.
#' @param future Whether to attempt to parallelize across files. Defaults to FALSE.
#'
#' @importFrom jsonlite fromJSON
#' @importFrom purrr map map_dfr
#' @importFrom furrr future_map_dfr
#' @importFrom fs path_file
#' @importFrom tibble tibble
#' @importFrom magrittr %>%
#' @importFrom tictoc tic toc
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
extract_cvr <- function(path = NULL,  cvr = NULL, zipdir = NULL, future = FALSE, verbose = TRUE) {

  tic()
  if (is.null(cvr) & is.null(path))
    stop("Must have an object in `cvr` or a path in `path`")

  if (is.null(cvr) & !is.null(path)) {
    cvr <- map(path,
                function(fn, zip = zipdir) {
                  if (!is.null(zip))
                    fn <- unz(zip, fn)

                  fromJSON(fn, simplifyDataFrame = FALSE)
                }
    )
  }

  # list of cvrExports to list of files (which include sessions)
  data <- map(cvr, ~ .x$Sessions)
  names(data) <- fs::path_file(path)

  # output
  if (future) {
    out <- future_map_dfr(data,
                   .extract_from_file,
                   .id = "file",
                   .progress = verbose)
  }

  if (!future) {
    out <- map_dfr(data,
            .extract_from_file,
            .id = "file",
            .progress = verbose)
  }

  toc()
  cat("\n")
  return(out)
}

#' @keywords internal
.extract_from_file <- function(file) {
  map_dfr(file, ~ .extract_from_session(.x))
}

#' @keywords internal
.extract_from_session <- function(sess) {
    map_dfr(sess$Original$Cards, ~.extract_from_card(.x, sess))
}

#' @keywords internal
.extract_from_card <- function(card, sess) {
  map_dfr(card$Contests, ~.extract_from_contest(.x, sess, card))
}

#' @keywords internal
.extract_from_contest <- function(cont, sess, card) {
    map_dfr(cont$Marks, ~.extract_from_mark(.x, sess, card, cont))
}


#' @keywords internal
.extract_from_mark <- function(mark, sess, card, cont) {
  tibble(
    # file_name = fn, # if only path, add the filename
    precinct = sess$Original$PrecinctPortionId,
    ballotType = sess$Original$BallotTypeId,
    tabulator = sess$TabulatorId,
    batch = sess$BatchId,
    recordId = sess$RecordId,
    countyGroupId = sess$CountingGroupId,
    # #imageMask = sess$ImageMask,
    sessionType = sess$SessionType,
    votingSessionId = sess$VotingSessionIdentifier,
    uniqueVotingIdentifer = sess$UniqueVotingIdentifier,
    cardId = card$Id,
    # # keyinId = card$KeyInId,
    paperIndex = card$PaperIndex,
    contestId = cont$Id,
    # contest = contests[as.character(cont$Id)],
    overvotes = cont$Overvotes,
    undervotes = cont$Undervotes,
    candidateID = mark$CandidateId,
    # candidate = cands[as.character(m$CandidateId)],
    rank = mark$Rank,
    mdens = mark$MarkDensity,
    isambig = mark$IsAmbiguous,
    isvote = mark$IsVote
  )
}
