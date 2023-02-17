
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dominionCVR

**Shiro Kuriwaki** and **Jeff Lewis**

<!-- badges: start -->
<!-- badges: end -->

Dominion voting machines, used in many places such as Arizona, Orange
County, CA, and San Francisco Couty, CA, export their cast vote records
in JSON format. This R package provides a common interface to read such
data files into tabular form.

## Installation

You can install the released version of dominionCVR from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("dominionCVR")
```

## Package and Dependencies

``` r
library(dominionCVR)
#> Loading required package: RcppSimdJson
```

``` r
library(tidyverse)
library(jsonlite)
```

## Usage

Currently there is a simple function to read from a JSON file:

``` r
extract_cvr(path = "data-raw/json/CvrExport_42.json") |> 
  as_tibble()
#> 0.05 sec elapsed
#> # A tibble: 1,216 × 21
#>    origi…¹ sessi…² preci…³ ballo…⁴ tabul…⁵ batch recor…⁶ count…⁷ votin…⁸ isCur…⁹
#>    <chr>   <chr>     <int>   <int>   <int> <int>   <int>   <int> <chr>   <lgl>  
#>  1 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  2 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  3 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  4 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  5 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  6 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  7 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  8 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  9 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#> 10 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#> # … with 1,206 more rows, 11 more variables: cardId <int>, paperIndex <int>,
#> #   contestId <int>, overvotes <int>, undervotes <int>, candidateId <int>,
#> #   rank <int>, mdens <int>, isAmbiguous <lgl>, isVote <lgl>, file <chr>, and
#> #   abbreviated variable names ¹​originalModified, ²​sessionType, ³​precinct,
#> #   ⁴​ballotTypeId, ⁵​tabulator, ⁶​recordId, ⁷​countingGroupId, ⁸​votingSessionId,
#> #   ⁹​isCurrent
```

It can read multiple files at the same time and run in multicore
settings

``` r
library(furrr)
#> Loading required package: future
plan("multicore")
#> Warning in supportsMulticoreAndRStudio(...): [ONE-TIME WARNING] Forked
#> processing ('multicore') is not supported when running R from RStudio because
#> it is considered unstable. For more details, how to control forked processing
#> or not, and how to silence this warning in future R sessions, see
#> ?parallelly::supportsMulticore
extract_cvr(path = c("data-raw/json/CvrExport_42.json",
                     "data-raw/json/CvrExport_24940.json")) |> 
  as_tibble()
#> 0.025 sec elapsed
#> # A tibble: 1,384 × 21
#>    origi…¹ sessi…² preci…³ ballo…⁴ tabul…⁵ batch recor…⁶ count…⁷ votin…⁸ isCur…⁹
#>    <chr>   <chr>     <int>   <int>   <int> <int>   <int>   <int> <chr>   <lgl>  
#>  1 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  2 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  3 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  4 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  5 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  6 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  7 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  8 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#>  9 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#> 10 Origin… Scanne…     157      51      21    20      88       2 ""      TRUE   
#> # … with 1,374 more rows, 11 more variables: cardId <int>, paperIndex <int>,
#> #   contestId <int>, overvotes <int>, undervotes <int>, candidateId <int>,
#> #   rank <int>, mdens <int>, isAmbiguous <lgl>, isVote <lgl>, file <chr>, and
#> #   abbreviated variable names ¹​originalModified, ²​sessionType, ³​precinct,
#> #   ⁴​ballotTypeId, ⁵​tabulator, ⁶​recordId, ⁷​countingGroupId, ⁸​votingSessionId,
#> #   ⁹​isCurrent
```

## Inside CVR Exports

Each CVR export is a hierarchical data format.

``` r
cvr <- fromJSON("data-raw/json/CvrExport_42.json") 

cvr %>% str(max.level = 3, vec.len = 2)
#> List of 3
#>  $ Version   : chr "5.10.50.85"
#>  $ ElectionId: chr "San Francisco Consolidated General Election"
#>  $ Sessions  :'data.frame':  118 obs. of  10 variables:
#>   ..$ TabulatorId            : int [1:118] 21 21 21 21 21 ...
#>   ..$ BatchId                : int [1:118] 20 20 20 20 20 ...
#>   ..$ RecordId               : int [1:118] 88 87 48 47 33 ...
#>   ..$ CountingGroupId        : int [1:118] 2 2 2 2 2 ...
#>   ..$ ImageMask              : chr [1:118] "D:\\NAS\\San Francisco Consolidated General Election\\Results\\Tabulator00021\\Batch020\\Images\\00021_00020_000088*.*" "D:\\NAS\\San Francisco Consolidated General Election\\Results\\Tabulator00021\\Batch020\\Images\\00021_00020_000087*.*" ...
#>   ..$ SessionType            : chr [1:118] "ScannedVote" "ScannedVote" ...
#>   ..$ VotingSessionIdentifier: chr [1:118] "" "" ...
#>   ..$ UniqueVotingIdentifier : chr [1:118] "" "" ...
#>   ..$ Original               :'data.frame':  118 obs. of  4 variables:
#>   .. ..$ PrecinctPortionId: int [1:118] 157 157 391 391 563 ...
#>   .. ..$ BallotTypeId     : int [1:118] 51 51 67 67 83 ...
#>   .. ..$ IsCurrent        : logi [1:118] TRUE TRUE TRUE ...
#>   .. ..$ Cards            :List of 118
#>   ..$ Modified               :'data.frame':  118 obs. of  4 variables:
#>   .. ..$ PrecinctPortionId: int [1:118] NA NA NA NA NA ...
#>   .. ..$ BallotTypeId     : int [1:118] NA NA NA NA NA ...
#>   .. ..$ IsCurrent        : logi [1:118] NA NA NA ...
#>   .. ..$ Cards            :List of 118
```

The key parts in this top level output is `Sessions$Orignal$Cards`.

`Orignal` includes the ballot data as taken. Each session includes cards
for the ballots.

Each card includes contests. Here we take the 49th card.

``` r
length(cvr$Sessions$Original$Cards)
#> [1] 118

# First card
cvr$Sessions$Original$Cards[[49]] %>% str(max.level = 2)
#> 'data.frame':    1 obs. of  5 variables:
#>  $ Id                  : int 8649
#>  $ KeyInId             : int 8649
#>  $ PaperIndex          : int 0
#>  $ Contests            :List of 1
#>   ..$ :'data.frame': 6 obs. of  6 variables:
#>  $ OutstackConditionIds:List of 1
#>   ..$ : list()
```

Each contest is identified by a *Contest ID*.

``` r
cvr$Sessions$Original$Cards[[49]]$Contests[[1]] %>% 
  as_tibble()
#> # A tibble: 6 × 6
#>      Id ManifestationId Undervotes Overvotes OutstackConditionIds Marks       
#>   <int>           <int>      <int>     <int> <list>               <list>      
#> 1     1           76056          0         0 <list [0]>           <df [1 × 8]>
#> 2     2           76057          0         0 <list [0]>           <df [1 × 8]>
#> 3     5           76058          0         0 <list [0]>           <df [1 × 8]>
#> 4     7           76059          0         0 <list [0]>           <df [1 × 8]>
#> 5     8           76060          0         0 <list [0]>           <df [4 × 8]>
#> 6     9           76061          0         0 <list [0]>           <df [4 × 8]>
```

Each contest ID in a card has itself a table of Marks. A contests’ mark
is read into R as a list of row-1 dataframes.

``` r
cvr$Sessions$Original$Cards[[49]]$Contests[[1]]$Marks %>% str(list.len = 2)
#> List of 6
#>  $ :'data.frame':    1 obs. of  8 variables:
#>   ..$ CandidateId         : int 59
#>   ..$ ManifestationId     : int 284046
#>   .. [list output truncated]
#>  $ :'data.frame':    1 obs. of  8 variables:
#>   ..$ CandidateId         : int 116
#>   ..$ ManifestationId     : int 284054
#>   .. [list output truncated]
#>   [list output truncated]
```

Therefore this list can be stacked into a table.

``` r
votes <- cvr$Sessions$Original$Cards[[49]]$Contests[[1]]$Marks %>% 
  bind_rows()

as_tibble(votes)
#> # A tibble: 12 × 8
#>    CandidateId ManifestationId PartyId  Rank MarkDensity IsAmbi…¹ IsVote Outst…²
#>          <int>           <int>   <int> <int>       <int> <lgl>    <lgl>  <list> 
#>  1          59          284046       0     1         100 FALSE    TRUE   <list> 
#>  2         116          284054       1     1          97 FALSE    TRUE   <list> 
#>  3         115          284055       1     1          92 FALSE    TRUE   <list> 
#>  4         113          284058       1     1          90 FALSE    TRUE   <list> 
#>  5          11          284059       0     1          99 FALSE    TRUE   <list> 
#>  6          10          284062       0     1         100 FALSE    TRUE   <list> 
#>  7          14          284064       0     1          96 FALSE    TRUE   <list> 
#>  8           7          284066       0     1          95 FALSE    TRUE   <list> 
#>  9          52          284076       0     1         100 FALSE    TRUE   <list> 
#> 10          50          284077       0     1          98 FALSE    TRUE   <list> 
#> 11          49          284080       0     1          98 FALSE    TRUE   <list> 
#> 12          51          284083       0     1          96 FALSE    TRUE   <list> 
#> # … with abbreviated variable names ¹​IsAmbiguous, ²​OutstackConditionIds
```

Here we finally get to the real part. `IsVote = TRUE` means that the
mark is a vote for the candidate. We can merge this with the candidate
metadata to who these candidates are.

``` r
# make contest data
cont_df <- fromJSON("data-raw/json/ContestManifest.json")$List %>% 
  rename_all(~ str_c("Contest", .x)) %>% 
  as_tibble()

# merge with candidate data
cand_df <- cont_df %>% 
  select(ContestDescription, ContestId) %>% 
  left_join(fromJSON("data-raw/json/CandidateManifest.json")$List, by = "ContestId") %>% 
  as_tibble()
#> Warning in left_join(., fromJSON("data-raw/json/CandidateManifest.json")$List, : Each row in `x` is expected to match at most 1 row in `y`.
#> ℹ Row 1 of `x` matches multiple rows.
#> ℹ If multiple matches are expected, set `multiple = "all"` to silence this
#>   warning.
```

``` r
labels <- select(cand_df, 
                 contest = ContestDescription, 
                 candidate = Description, 
                 CandidateId = Id)

votes %>% 
  # add name to candidate
  left_join(labels, by = "CandidateId") %>% 
  relocate(contest, candidate, IsVote) %>% 
  as_tibble()
#> # A tibble: 12 × 10
#>    contest  candi…¹ IsVote Candi…² Manif…³ PartyId  Rank MarkD…⁴ IsAmb…⁵ Outst…⁶
#>    <chr>    <chr>   <lgl>    <int>   <int>   <int> <int>   <int> <lgl>   <list> 
#>  1 PRESIDE… JOSEPH… TRUE        59  284046       0     1     100 FALSE   <list> 
#>  2 US Hous… NANCY … TRUE       116  284054       1     1      97 FALSE   <list> 
#>  3 State S… SCOTT … TRUE       115  284055       1     1      92 FALSE   <list> 
#>  4 STATE A… PHIL T… TRUE       113  284058       1     1      90 FALSE   <list> 
#>  5 BOARD O… KEVINE… TRUE        11  284059       0     1      99 FALSE   <list> 
#>  6 BOARD O… JENNY … TRUE        10  284062       0     1     100 FALSE   <list> 
#>  7 BOARD O… MICHEL… TRUE        14  284064       0     1      96 FALSE   <list> 
#>  8 BOARD O… ALIDA … TRUE         7  284066       0     1      95 FALSE   <list> 
#>  9 COMMUNI… TOM TE… TRUE        52  284076       0     1     100 FALSE   <list> 
#> 10 COMMUNI… MARIE … TRUE        50  284077       0     1      98 FALSE   <list> 
#> 11 COMMUNI… JEANET… TRUE        49  284080       0     1      98 FALSE   <list> 
#> 12 COMMUNI… SHANEL… TRUE        51  284083       0     1      96 FALSE   <list> 
#> # … with abbreviated variable names ¹​candidate, ²​CandidateId, ³​ManifestationId,
#> #   ⁴​MarkDensity, ⁵​IsAmbiguous, ⁶​OutstackConditionIds
```

## Inside Manifest Files

Metadata about the contests are stored in Manifest files, e.g. for
contest codes, use `contestManifest.json` and for candidate codes use
`CandidateManifest.json`. These are single-table JSONs that are easy to
read, but we provide the function `read_manifest` that exports a tibble
and can extract from a zip file too.

``` r
 read_manifest("data-raw/json/BallotTypeContestManifest.json")
#> # A tibble: 2,462 × 2
#>    BallotTypeId ContestId
#>           <int>     <int>
#>  1            1         1
#>  2            1         4
#>  3            1         5
#>  4            1         7
#>  5            1         8
#>  6            1         9
#>  7            1        11
#>  8            1        17
#>  9            1        18
#> 10            1        19
#> # … with 2,452 more rows
 read_manifest("data-raw/json/BallotTypeManifest.json")
#> # A tibble: 96 × 3
#>    Description       Id ExternalId
#>    <chr>          <int> <chr>     
#>  1 Ballot Type 1      1 1         
#>  2 Ballot Type 11     2 11        
#>  3 Ballot Type 13     3 13        
#>  4 Ballot Type 22     4 22        
#>  5 Ballot Type 10     5 10        
#>  6 Ballot Type 14     6 14        
#>  7 Ballot Type 26     7 26        
#>  8 Ballot Type 19     8 19        
#>  9 Ballot Type 16     9 16        
#> 10 Ballot Type 18    10 18        
#> # … with 86 more rows
 read_manifest("data-raw/json/CandidateManifest.json")
#> # A tibble: 139 × 6
#>    Description                                  Id Exter…¹ Conte…² Type  Disab…³
#>    <chr>                                     <int> <chr>     <int> <chr>   <int>
#>  1 "JOSEPH R. BIDEN AND KAMALA D. HARRIS"       59 ""            1 Regu…       0
#>  2 "DONALD J. TRUMP AND MICHAEL R. PENCE"       54 ""            1 Regu…       0
#>  3 "GLORIA LA RIVA AND SUNIL FREEMAN"           55 ""            1 Regu…       0
#>  4 "ROQUE \"ROCKY\" DE LA FUENTE GUERRA AND…    56 ""            1 Regu…       0
#>  5 "HOWIE HAWKINS AND ANGELA NICOLE WALKER"     57 ""            1 Regu…       0
#>  6 "JO JORGENSEN AND JEREMY \"SPIKE\" COHEN"    58 ""            1 Regu…       0
#>  7 "Write-in"                                  126 ""            1 Writ…       0
#>  8 "BRIAN CARROLL AND AMAR PATEL"              133 ""            1 Qual…       0
#>  9 "MARK CHARLES AND ADRIAN WALLACE"           134 ""            1 Qual…       0
#> 10 "JOSEPH KISHORE AND NORISSA SANTA CRUZ"     135 ""            1 Qual…       0
#> # … with 129 more rows, and abbreviated variable names ¹​ExternalId, ²​ContestId,
#> #   ³​Disabled
 read_manifest("data-raw/json/ContestManifest.json")
#> # A tibble: 42 × 7
#>    Description                        Id Exter…¹ Distr…² VoteFor NumOf…³ Disab…⁴
#>    <chr>                           <int> <chr>     <int>   <int>   <int>   <int>
#>  1 PRESIDENT AND VICE PRESIDENT        1 110         101       1       0       0
#>  2 US House of Rep District 12         2 1020        102       1       0       0
#>  3 US House of Rep District 13         3 1030        103       1       0       0
#>  4 US House of Rep District 14         4 1040        104       1       0       0
#>  5 State Senator District 11           5 1130        105       1       0       0
#>  6 STATE ASSEMBLY MEMBER District…     6 1310        106       1       0       0
#>  7 STATE ASSEMBLY MEMBER District…     7 1210        107       1       0       0
#>  8 BOARD OF EDUCATION                  8 6100        121       4       0       0
#>  9 COMMUNITY COLLEGE BOARD             9 8530        121       4       0       0
#> 10 BART DIRECTOR DISTRICT 7           10 6000        122       1       0       0
#> # … with 32 more rows, and abbreviated variable names ¹​ExternalId, ²​DistrictId,
#> #   ³​NumOfRanks, ⁴​Disabled
 read_manifest("data-raw/json/CountingGroupManifest.json")
#> # A tibble: 2 × 3
#>   Description     Id ExternalId
#>   <chr>        <int> <chr>     
#> 1 Election Day     1 ""        
#> 2 Vote by Mail     2 ""
 read_manifest("data-raw/json/DistrictManifest.json")
#> # A tibble: 50 × 4
#>    Description     Id DistrictTypeId                       ExternalId
#>    <chr>        <int> <chr>                                <chr>     
#>  1 Electionwide   150 f92d02b4-af65-436a-8ebf-c2dc25d637dd ""        
#>  2 CALIFORNIA     101 7278d62c-8a58-47f6-bc3f-f2cdd1f8740c "CA"      
#>  3 12TH CONG      102 34fdf5a8-a188-4ec1-9590-ccfeb16ccb5e "CON012"  
#>  4 13TH CONG      103 34fdf5a8-a188-4ec1-9590-ccfeb16ccb5e "CON013"  
#>  5 14TH CONG      104 34fdf5a8-a188-4ec1-9590-ccfeb16ccb5e "CON014"  
#>  6 11TH SENATE    105 ec30ee2d-f0e1-4250-8f78-69ba32d1d60b "266"     
#>  7 17TH ASMBLY    106 90ddf079-3ab8-4d2a-8df2-1220072c93b5 "ASM017"  
#>  8 19TH ASMBLY    107 90ddf079-3ab8-4d2a-8df2-1220072c93b5 "ASM019"  
#>  9 BD EQ,DIST2    108 aa7f3fd3-9095-4008-95a5-90a4dd6d536d "BOE002"  
#> 10 County Wide    109 b6746389-47c1-46bc-b30c-212a8a794a3a "SF"      
#> # … with 40 more rows
 read_manifest("data-raw/json/DistrictPrecinctPortionManifest.json")
#> # A tibble: 6,432 × 2
#>    DistrictId PrecinctPortionId
#>         <int>             <int>
#>  1        150                 1
#>  2        150                 2
#>  3        150                 3
#>  4        150                 4
#>  5        150                 5
#>  6        150                 6
#>  7        150                 7
#>  8        150                 8
#>  9        150                 9
#> 10        150                10
#> # … with 6,422 more rows
 read_manifest("data-raw/json/DistrictTypeManifest.json")
#> # A tibble: 11 × 3
#>    Description                   Id                                   ExternalId
#>    <chr>                         <chr>                                <chr>     
#>  1 Countywide                    f92d02b4-af65-436a-8ebf-c2dc25d637dd ""        
#>  2 STATE                         7278d62c-8a58-47f6-bc3f-f2cdd1f8740c "CA"      
#>  3 United States Representative  34fdf5a8-a188-4ec1-9590-ccfeb16ccb5e ""        
#>  4 State Senator                 ec30ee2d-f0e1-4250-8f78-69ba32d1d60b ""        
#>  5 Member of the State Assembly  90ddf079-3ab8-4d2a-8df2-1220072c93b5 ""        
#>  6 Board of Equalization (State) aa7f3fd3-9095-4008-95a5-90a4dd6d536d ""        
#>  7 County                        b6746389-47c1-46bc-b30c-212a8a794a3a ""        
#>  8 County Supervisor             b026aa7b-4730-4d39-9a33-766f22967d8a ""        
#>  9 City                          8b84f173-4ca1-411e-88d6-319b3a9ebeaf ""        
#> 10 BART                          6a75922c-fd82-4618-8694-c1137e695c6f ""        
#> 11 Neighborhood                  253b928c-aa6d-4d90-9d65-9c0080f6edcd ""
 read_manifest("data-raw/json/ElectionEventManifest.json")
#> # A tibble: 1 × 6
#>   Description                                 Id Exter…¹ Juris…² Elect…³ Elect…⁴
#>   <chr>                                    <int> <chr>   <chr>   <chr>   <list> 
#> 1 San Francisco Consolidated General Elec…     1 ""      San Fr… 202011… <int>  
#> # … with abbreviated variable names ¹​ExternalId, ²​Jurisdiction, ³​ElectionDate,
#> #   ⁴​ElectionSignature
 read_manifest("data-raw/json/OutstackConditionManifest.json")
#> # A tibble: 12 × 2
#>    Description                Id
#>    <chr>                   <int>
#>  1 Ambiguous                   0
#>  2 Writein                     1
#>  3 BlankBallot                 2
#>  4 Overvote                    5
#>  5 Undervote                   4
#>  6 BlankContest                6
#>  7 OvervotedRanking            9
#>  8 InconsistentRcvOrdering    10
#>  9 SkippedRanking             11
#> 10 DuplicatedRcvCandidate     12
#> 11 UnvotedRcvContest          13
#> 12 UnusedRanking              14
 read_manifest("data-raw/json/PartyManifest.json")
#> # A tibble: 8 × 3
#>   Description                       Id ExternalId
#>   <chr>                          <int> <chr>     
#> 1 Democratic                         1 ""        
#> 2 Republican                         2 ""        
#> 3 American Independent               3 ""        
#> 4 Peace and Freedom                  4 ""        
#> 5 Libertarian                        5 ""        
#> 6 Green                              6 ""        
#> 7 No Party Preference                7 ""        
#> 8 Non-Partisan (System Use Only)     8 ""
 read_manifest("data-raw/json/PrecinctManifest.json")
#> # A tibble: 609 × 3
#>    Description      Id ExternalId
#>    <chr>         <int> <chr>     
#>  1 PCT 1101          1 1101-1    
#>  2 PCT 1102          2 1102-1    
#>  3 PCT 1103          3 1103-1    
#>  4 PCT 1104/1105     4 1104-1    
#>  5 PCT 1106          5 1106-2    
#>  6 PCT 1107          6 1107-2    
#>  7 PCT 1108          7 1108-2    
#>  8 PCT 1109          8 1109-2    
#>  9 PCT 1111          9 1111-2    
#> 10 PCT 1112         10 1112-2    
#> # … with 599 more rows
 read_manifest("data-raw/json/PrecinctPortionManifest.json")
#> # A tibble: 609 × 4
#>    Description      Id ExternalId PrecinctId
#>    <chr>         <int> <chr>           <int>
#>  1 PCT 1101          1 1101-1              1
#>  2 PCT 1102          2 1102-1              2
#>  3 PCT 1103          3 1103-1              3
#>  4 PCT 1104/1105     4 1104-1              4
#>  5 PCT 1106          5 1106-2              5
#>  6 PCT 1107          6 1107-2              6
#>  7 PCT 1108          7 1108-2              7
#>  8 PCT 1109          8 1109-2              8
#>  9 PCT 1111          9 1111-2              9
#> 10 PCT 1112         10 1112-2             10
#> # … with 599 more rows
 read_manifest("data-raw/json/TabulatorManifest.json")
#> # A tibble: 1,246 × 10
#>    Descrip…¹    Id Votin…² Votin…³ Exter…⁴ Type  Thres…⁵ Thres…⁶ Write…⁷ Write…⁸
#>    <chr>     <int>   <int> <chr>   <chr>   <chr>   <int>   <int>   <int>   <int>
#>  1 ICC01 El…     1       1 City H… ""      Imag…       5      25       5      25
#>  2 ICC02 El…     2       1 City H… ""      Imag…       5      25       5      25
#>  3 ICC03 El…     3       1 City H… ""      Imag…       5      25       5      25
#>  4 ICC04 El…     4       1 City H… ""      Imag…       5      25       5      25
#>  5 ICC05 El…     5       1 City H… ""      Imag…       5      25       5      25
#>  6 ICC06 El…     6       1 City H… ""      Imag…       5      25       5      25
#>  7 ICC07 El…     7       1 City H… ""      Imag…       5      25       5      25
#>  8 ICC08 El…     8       1 City H… ""      Imag…       5      25       5      25
#>  9 ICC09 El…     9       1 City H… ""      Imag…       5      25       5      25
#> 10 ICC10 El…    10       1 City H… ""      Imag…       5      25       5      25
#> # … with 1,236 more rows, and abbreviated variable names ¹​Description,
#> #   ²​VotingLocationNumber, ³​VotingLocationName, ⁴​ExternalId, ⁵​ThresholdMin,
#> #   ⁶​ThresholdMax, ⁷​WriteThresholdMin, ⁸​WriteThresholdMax
```
