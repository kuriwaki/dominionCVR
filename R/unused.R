#
# Vestigial code from the days of mapping to parse the JSON
# https://github.com/kuriwaki/dominionCVR/blob/e3ca9041f7d78c5464c7f34a26adda1afb163570/R/readCVR.R#L59
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
      precinctPortionId = sess$Original$PrecinctPortionId,
      ballotType = sess$Original$BallotTypeId,
      isCurrent = sess$Original$IsCurrent
    ) %>%
    # Add "modified" marks
    bind_rows(
      map_dfr(sess$Modified$Cards, ~ .extract_from_card(.x)) %>%
        mutate(
          originalModified = "M",
          precinctPortionId = sess$Modified$PrecinctPortionId,
          ballotType = sess$Modified$BallotTypeId,
          isCurrent = sess$Modified$IsCurrent
        )
    ) %>%
    mutate(
      tabulatorId = sess$TabulatorId,
      batchId = sess$BatchId,
      recordId = sess$RecordId,
      countingGroupId = sess$CountingGroupId,
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
  if (length(cont$Marks) == 0) {
    mrks <- list(list())
  } else {
    mrks <- cont$Marks
  }
  map(mrks, ~.extract_from_mark(.x, card, cont))
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
    partyId = mark$PartyId,
    rank = mark$Rank,
    # mdens = mark$MarkDensity,
    isAmbiguous = mark$IsAmbiguous,
    isVote = mark$IsVote
  )
}
