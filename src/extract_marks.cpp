#include <Rcpp.h>

//' Extract marks and metadata from CVR JSON
//'
//' @param sessions  CVR JSON
//' @param max_marks Maximum number of vote choice that JSON could contain
//' @return dataframe containing the extracted vote choices and meta data
// [[Rcpp::export]]

Rcpp::DataFrame extract_marks(Rcpp::List sessions, int max_marks) {
    Rcpp::StringVector origMod = {"Original", "Modified"};

    std::vector<std::string> originalModified(max_marks);
    std::vector<std::string> sessionType(max_marks);
    std::vector<int> precinct(max_marks);
    std::vector<int> ballotTypeId(max_marks);
    std::vector<int> tabulator(max_marks);
    std::vector<int> batch(max_marks);
    std::vector<int> recordId(max_marks);
    std::vector<int> countingGroupId(max_marks);
    std::vector<std::string> votingSessionId(max_marks);
    std::vector<std::string> uniqueVotingIdentifer(max_marks);
    std::vector<bool> isCurrent(max_marks);
    std::vector<int> cardId(max_marks);
    std::vector<int> paperIndex(max_marks);
    std::vector<int> contestId(max_marks);
    std::vector<int> overvotes(max_marks);
    std::vector<int> undervotes(max_marks);
    std::vector<int> candidateId(max_marks);
    std::vector<int> rank(max_marks);
    std::vector<int> mdens(max_marks);
    std::vector<bool> isAmbiguous(max_marks);
    std::vector<bool> isVote(max_marks);

    int mark_no = 0;
    for (int i=0; i<sessions.length(); i++) {
      Rcpp::List session=sessions[i];
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
                for (int m=0; m<marks.length(); m++) {
                  Rcpp::List mark = marks[m];
                  originalModified[mark_no] = om;
                  sessionType[mark_no] =  st; // session["SessionType"];
                  precinct[mark_no] = orig_mod["PrecinctPortionId"];
                  ballotTypeId[mark_no] = orig_mod["BallotTypeId"];
                  tabulator[mark_no] = session["TabulatorId"];
                  batch[mark_no] = session["BatchId"];
                  recordId[mark_no] = session["RecordId"];
                  countingGroupId[mark_no] = session["CountingGroupId"];
                  votingSessionId[mark_no] = (const char *) session["VotingSessionIdentifier"];
                  uniqueVotingIdentifer[mark_no] = (const char *) session["UniqueVotingIdentifier"];
                  isCurrent[mark_no] = (bool) orig_mod["IsCurrent"];
                  cardId[mark_no] = card["Id"];
                  paperIndex[mark_no] = card["PaperIndex"];
                  contestId[mark_no] = contest["Id"];
                  overvotes[mark_no] = contest["Overvotes"];
                  undervotes[mark_no] = contest["Undervotes"];
                  candidateId[mark_no] = mark["CandidateId"];
                  rank[mark_no] = mark["Rank"];
                  mdens[mark_no] = mark["MarkDensity"];
                  isAmbiguous[mark_no] =  (bool) mark["IsAmbiguous"];
                  isVote[mark_no] = (bool) mark["IsVote"];
                  mark_no++;
                }
            }
          }
        }
      }
    }

    //Shorten vectors to actual length
    originalModified.resize(mark_no);
    sessionType.resize(mark_no);
    precinct.resize(mark_no);
    ballotTypeId.resize(mark_no);
    tabulator.resize(mark_no);
    batch.resize(mark_no);
    recordId.resize(mark_no);
    countingGroupId.resize(mark_no);
    votingSessionId.resize(mark_no);
    uniqueVotingIdentifer.resize(mark_no);
    isCurrent.resize(mark_no);
    cardId.resize(mark_no);
    paperIndex.resize(mark_no);
    contestId.resize(mark_no);
    overvotes.resize(mark_no);
    undervotes.resize(mark_no);
    candidateId.resize(mark_no);
    rank.resize(mark_no);
    mdens.resize(mark_no);
    isAmbiguous.resize(mark_no);
    isVote.resize(mark_no);

    return(Rcpp::DataFrame::create(
      Rcpp::Named("originalModified") = originalModified,
      Rcpp::Named("sessionType") = sessionType,
      Rcpp::Named("precinct") = precinct,
      Rcpp::Named("ballotTypeId") = ballotTypeId,
      Rcpp::Named("tabulator") = tabulator,
      Rcpp::Named("batch") = batch,
      Rcpp::Named("recordId") = recordId,
      Rcpp::Named("countingGroupId") = countingGroupId,
      Rcpp::Named("votingSessionId") = votingSessionId,
      //Rcpp::Named("uniqueVotingIdentifer") = uniqueVotingIdentifer,
      Rcpp::Named("isCurrent") = isCurrent,
      Rcpp::Named("cardId") = cardId,
      Rcpp::Named("paperIndex") = paperIndex,
      Rcpp::Named("contestId") = contestId,
      Rcpp::Named("overvotes") = overvotes,
      Rcpp::Named("undervotes") = undervotes,
      Rcpp::Named("candidateId") = candidateId,
      Rcpp::Named("rank") = rank,
      Rcpp::Named("mdens") = mdens,
      Rcpp::Named("isAmbiguous") = isAmbiguous,
      Rcpp::Named("isVote") = isVote)
    );
  }
