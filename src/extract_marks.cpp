#include <Rcpp.h>

// Function to count marks in JSON file to use when .max_marks
// is exceeded for better error messaging.

int count_marks(Rcpp::List sessions) {
  int mark_no = 0;
  Rcpp::StringVector origMod = {"Original", "Modified"};
  for (int i=0; i<sessions.length(); i++) {
    Rcpp::List session=sessions[i];
    for (int n=0; n<2; n++) {
      const char * om = origMod[n];
      if (session.containsElementNamed(om)) {
        Rcpp::List orig_mod = session[om];
        Rcpp::List cards = orig_mod["Cards"];
        for (int j=0; j<cards.length(); j++) {
          Rcpp::List card=cards[j];
          Rcpp::List contests = card["Contests"];
          for (int k=0; k<contests.length(); k++) {
            Rcpp::List contest = contests[k];
            Rcpp::List marks = contest["Marks"];
            mark_no += marks.length() == 0 ? 1 : marks.length();
          }
        }
      }
    }
  }
  return(mark_no);
}

//' Extract marks and metadata from CVR JSON
//'
//' @param sessions  CVR JSON
//' @param max_marks Maximum number of vote choices that the JSON could contain
//' @return dataframe containing the extracted vote choices and meta data
// [[Rcpp::export]]

Rcpp::DataFrame extract_marks(Rcpp::List sessions, int max_marks) {
    Rcpp::StringVector origMod = {"Original", "Modified"};

    std::vector<std::string> originalModified(max_marks);
    std::vector<std::string> sessionType(max_marks);
    std::vector<int> precinctPortionId(max_marks);
    std::vector<int> ballotTypeId(max_marks);
    std::vector<int> tabulatorId(max_marks);
    std::vector<int> batchId(max_marks);
    std::vector<int> recordId(max_marks);
    std::vector<int> countingGroupId(max_marks);
    std::vector<int> sessionIndex(max_marks);
    std::vector<std::string> votingSessionId(max_marks);
    std::vector<std::string> uniqueVotingIdentifer(max_marks);
    std::vector<bool> isCurrent(max_marks);
    std::vector<int> cardId(max_marks);
    std::vector<int> paperIndex(max_marks);
    std::vector<int> contestId(max_marks);
    std::vector<int> overvotes(max_marks);
    std::vector<int> undervotes(max_marks);
    std::vector<int> candidateId(max_marks);
    std::vector<int> partyId(max_marks);
    std::vector<int> rank(max_marks);
    // Collapse mdens and isAmbiguous fields to get around Rcpp::Dataframe field limit
    std::vector<int> isAmbiguous_mdens(max_marks);
    std::vector<bool> isVote(max_marks);

    Rcpp::List mark;
    Rcpp::List empty_mark = Rcpp::List::create();
    bool zero_marks = false;
    int mark_no = 0;

    const char * vsi;
    const char * uvi;

    for (int i=0; i<sessions.length(); i++) {
      Rcpp::List session=sessions[i];

      // Check if identifiers are omitted from the file.  Ultimately, there
      // aren't returned even if they are there, so they could just be left
      // unextracted when present.
      vsi = (session.containsElementNamed("VotingSessionIdentifier") &&
             session["VotingSessionIdentifier"] != R_NilValue) ?
             (const char *) session("VotingSessionIdentifier") :
            "NULL";
      uvi = (session.containsElementNamed("UniqueVotingIdentifier") &&
             session["UniqueVotingIdentifier"] != R_NilValue)?
            (const char *) session("UniqueVotingIdentifier") :
            "NULL";

      for (int n=0; n<2; n++) {
        const char * om = origMod[n];
        if (session.containsElementNamed(om)) {
          const char * st = session["SessionType"];
          Rcpp::List orig_mod = session[om];
          Rcpp::List cards = orig_mod["Cards"];
          for (int j=0; j<cards.length(); j++) {
            Rcpp::List card=cards[j];
            Rcpp::List contests = card["Contests"];
              for (int k=0; k<contests.length(); k++) {
                Rcpp::List contest = contests[k];
                Rcpp::List marks = contest["Marks"];
                zero_marks = marks.length() == 0;
                for (int m=0; zero_marks | (m<marks.length()); m++) {
                  if (mark_no == max_marks) {
                    int tot_marks = count_marks(sessions);
                    Rcpp::warning(".max_marks exceeded. Resetting .max_marks to %i.",
                                  tot_marks);
                    return(extract_marks(sessions, tot_marks));
                  }
                  if (marks.length() > 0) {
                    mark = marks[m];
                  }
                  else {
                    mark = empty_mark;
                  }
                  originalModified[mark_no] = om;
                  sessionType[mark_no] =  st; // session["SessionType"];
                  precinctPortionId[mark_no] = orig_mod["PrecinctPortionId"];
                  ballotTypeId[mark_no] = orig_mod["BallotTypeId"];
                  tabulatorId[mark_no] = session["TabulatorId"];
                  batchId[mark_no] = session["BatchId"];
                  recordId[mark_no] = Rf_isNull(session["RecordId"]) ? -1 : session["RecordId"];
                  countingGroupId[mark_no] = session["CountingGroupId"];
                  sessionIndex[mark_no] = i;
                  votingSessionId[mark_no] = vsi; // (const char *) session["VotingSessionIdentifier"];
                  uniqueVotingIdentifer[mark_no] = uvi; // (const char *) session["UniqueVotingIdentifier"];
                  isCurrent[mark_no] = (bool) orig_mod["IsCurrent"];
                  cardId[mark_no] = card["Id"];
                  paperIndex[mark_no] = card["PaperIndex"];
                  contestId[mark_no] = contest["Id"];
                  overvotes[mark_no] = contest["Overvotes"];
                  undervotes[mark_no] = contest["Undervotes"];
                  candidateId[mark_no] = zero_marks ? -1 : mark["CandidateId"];
                  partyId[mark_no] = (zero_marks | !mark.containsElementNamed("PartyId")) ? -1 : mark["PartyId"];
                  rank[mark_no] = zero_marks ? -1 : mark["Rank"];
                  isAmbiguous_mdens[mark_no] =  zero_marks ? -1 : (mark["IsAmbiguous"] ? 1000 : 0) + (int) mark["MarkDensity"];
                  isVote[mark_no] = (bool) zero_marks ? 0 : mark["IsVote"];
                  mark_no++;
                  if (zero_marks) break;
                }
            }
          }
        }
      }
    }

    //Shorten vectors to actual length
    originalModified.resize(mark_no);
    sessionType.resize(mark_no);
    precinctPortionId.resize(mark_no);
    ballotTypeId.resize(mark_no);
    tabulatorId.resize(mark_no);
    batchId.resize(mark_no);
    recordId.resize(mark_no);
    countingGroupId.resize(mark_no);
    sessionIndex.resize(mark_no);
    votingSessionId.resize(mark_no);
    uniqueVotingIdentifer.resize(mark_no);
    isCurrent.resize(mark_no);
    cardId.resize(mark_no);
    paperIndex.resize(mark_no);
    contestId.resize(mark_no);
    overvotes.resize(mark_no);
    undervotes.resize(mark_no);
    candidateId.resize(mark_no);
    partyId.resize(mark_no);
    rank.resize(mark_no);
    isAmbiguous_mdens.resize(mark_no);
    isVote.resize(mark_no);

    return(Rcpp::DataFrame::create(
      Rcpp::Named("originalModified") = originalModified,
      Rcpp::Named("sessionType") = sessionType,
      Rcpp::Named("precinctPortionId") = precinctPortionId,
      Rcpp::Named("ballotTypeId") = ballotTypeId,
      Rcpp::Named("tabulatorId") = tabulatorId,
      Rcpp::Named("batchId") = batchId,
      Rcpp::Named("recordId") = recordId,
      Rcpp::Named("countingGroupId") = countingGroupId,
      Rcpp::Named("sessionIndex") = sessionIndex,
      //Rcpp::Named("votingSessionId") = votingSessionId,
      //Rcpp::Named("uniqueVotingIdentifer") = uniqueVotingIdentifer,
      Rcpp::Named("isCurrent") = isCurrent,
      Rcpp::Named("cardId") = cardId,
      Rcpp::Named("paperIndex") = paperIndex,
      Rcpp::Named("contestId") = contestId,
      Rcpp::Named("overvotes") = overvotes,
      Rcpp::Named("undervotes") = undervotes,
      Rcpp::Named("candidateId") = candidateId,
      Rcpp::Named("partyId") = partyId,
      Rcpp::Named("rank") = rank,
      Rcpp::Named("isAmbiguous_mdens") = isAmbiguous_mdens,
      Rcpp::Named("isVote") = isVote)
    );
  }
