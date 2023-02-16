#' Simple wrapper around manifest json file
#'
#' @importFrom RcppSimdJson fparse
#' @importFrom tibble as_tibble
#' @importFrom magrittr %>%
#' @importFrom readr read_file_raw
#'
#' @param path The path to a specific JSON file.  It can be a path within a zipfile,
#'  in which case you can also set the `zipdir` argument. The possible set of
#'  Manifest file names are listed below.
#' @export
#'
#'
#' @examples
#' \dontrun{
#'  read_manifest("data-raw/json/BallotTypeContestManifest.json")
#'  read_manifest("data-raw/json/BallotTypeManifest.json")
#'  read_manifest("data-raw/json/CandidateManifest.json")
#'  read_manifest("data-raw/json/ContestManifest.json")
#'  read_manifest("data-raw/json/CountingGroupManifest.json")
#'  read_manifest("data-raw/json/DistrictManifest.json")
#'  read_manifest("data-raw/json/DistrictPrecinctPortionManifest.json")
#'  read_manifest("data-raw/json/DistrictTypeManifest.json")
#'  read_manifest("data-raw/json/ElectionEventManifest.json")
#'  read_manifest("data-raw/json/OutstackConditionManifest.json")
#'  read_manifest("data-raw/json/PartyManifest.json")
#'  read_manifest("data-raw/json/PrecinctManifest.json")
#'  read_manifest("data-raw/json/PrecinctPortionManifest.json")
#'  read_manifest("data-raw/json/TabulatorManifest.json")
#'  }
read_manifest <- function(path = NULL, zipdir = NULL) {

  if (!is.null(zipdir))
    the_json <- read_file_raw(unz(zipdir, path))
  else
    the_json <- read_file_raw(path)

  fparse(the_json)$List %>%
    as_tibble()
}

