#' Extract tabular data from Dominion CVR
#'
#'
#' @param cvr,path The data. Use `cvr` for a list output from `jsonlite::fromJSON`,
#'  or use `path` to give the `fromJSON` path directly.
#'
#' @importFrom jsonlite fromJSON
#' @importFrom purrr map_dfr
#' @importFrom magrittr %>%
#' @examples
#'  extract_cvr(path = "data-raw/json/CvrExport_42.json")
#'
#' @export
#'
extract_cvr <- function(cvr = NULL, path = NULL) {

  if (is.null(cvr) & is.null(path))
    stop("Must have an object in `cvr` or a path in `path`")

  if (is.null(cvr) & !is.null(path))
    cvr <- fromJSON(path, simplifyDataFrame = FALSE)


  data <- cvr$Sessions

  data %>%
    map_dfr(function(sess) {
      precinct <- sess$Original$PrecinctPortionId
      ballotType <- sess$Original$BallotTypeId
      sess$Original$Cards %>%
        map_dfr(function(card) {
          map_dfr(card$Contests, function(cont) {
            # print(names(card))
            map_dfr(cont$Marks, function(m) {
              tibble(
                # file_name = fn, # if only path, add the filename
                precinct = precinct,
                ballotType = ballotType,
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
                candidateID = m$CandidateId,
                # candidate = cands[as.character(m$CandidateId)],
                rank = m$Rank,
                mdens = m$MarkDensity,
                isambig = m$IsAmbiguous,
                isvote = m$IsVote
              )
            })
          })
        })
    })
}
