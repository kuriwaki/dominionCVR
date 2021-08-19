
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
#> Loading required package: jsonlite
```

``` r
library(tidyverse)
library(jsonlite)
```

## Manifest Files

Metadata about the contests are stored in Manifest files, e.g. for
contests

``` r
fromJSON("data-raw/json/ContestManifest.json")$List %>% as_tibble()
#> # A tibble: 42 × 7
#>    Description              Id ExternalId DistrictId VoteFor NumOfRanks Disabled
#>    <chr>                 <int> <chr>           <int>   <int>      <int>    <int>
#>  1 PRESIDENT AND VICE P…     1 110               101       1          0        0
#>  2 US House of Rep Dist…     2 1020              102       1          0        0
#>  3 US House of Rep Dist…     3 1030              103       1          0        0
#>  4 US House of Rep Dist…     4 1040              104       1          0        0
#>  5 State Senator Distri…     5 1130              105       1          0        0
#>  6 STATE ASSEMBLY MEMBE…     6 1310              106       1          0        0
#>  7 STATE ASSEMBLY MEMBE…     7 1210              107       1          0        0
#>  8 BOARD OF EDUCATION        8 6100              121       4          0        0
#>  9 COMMUNITY COLLEGE BO…     9 8530              121       4          0        0
#> 10 BART DIRECTOR DISTRI…    10 6000              122       1          0        0
#> # … with 32 more rows
```

and candidates in those contests

``` r
fromJSON("data-raw/json/CandidateManifest.json")$List %>% 
  as_tibble()
#> # A tibble: 139 × 6
#>    Description                        Id ExternalId ContestId Type      Disabled
#>    <chr>                           <int> <chr>          <int> <chr>        <int>
#>  1 "JOSEPH R. BIDEN AND KAMALA D.…    59 ""                 1 Regular          0
#>  2 "DONALD J. TRUMP AND MICHAEL R…    54 ""                 1 Regular          0
#>  3 "GLORIA LA RIVA AND SUNIL FREE…    55 ""                 1 Regular          0
#>  4 "ROQUE \"ROCKY\" DE LA FUENTE …    56 ""                 1 Regular          0
#>  5 "HOWIE HAWKINS AND ANGELA NICO…    57 ""                 1 Regular          0
#>  6 "JO JORGENSEN AND JEREMY \"SPI…    58 ""                 1 Regular          0
#>  7 "Write-in"                        126 ""                 1 WriteIn          0
#>  8 "BRIAN CARROLL AND AMAR PATEL"    133 ""                 1 Qualifie…        0
#>  9 "MARK CHARLES AND ADRIAN WALLA…   134 ""                 1 Qualifie…        0
#> 10 "JOSEPH KISHORE AND NORISSA SA…   135 ""                 1 Qualifie…        0
#> # … with 129 more rows
```

## CVR Exports

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
#>    CandidateId ManifestationId PartyId  Rank MarkDensity IsAmbiguous IsVote
#>          <int>           <int>   <int> <int>       <int> <lgl>       <lgl> 
#>  1          59          284046       0     1         100 FALSE       TRUE  
#>  2         116          284054       1     1          97 FALSE       TRUE  
#>  3         115          284055       1     1          92 FALSE       TRUE  
#>  4         113          284058       1     1          90 FALSE       TRUE  
#>  5          11          284059       0     1          99 FALSE       TRUE  
#>  6          10          284062       0     1         100 FALSE       TRUE  
#>  7          14          284064       0     1          96 FALSE       TRUE  
#>  8           7          284066       0     1          95 FALSE       TRUE  
#>  9          52          284076       0     1         100 FALSE       TRUE  
#> 10          50          284077       0     1          98 FALSE       TRUE  
#> 11          49          284080       0     1          98 FALSE       TRUE  
#> 12          51          284083       0     1          96 FALSE       TRUE  
#> # … with 1 more variable: OutstackConditionIds <list>
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
#>    contest       candidate      IsVote CandidateId ManifestationId PartyId  Rank
#>    <chr>         <chr>          <lgl>        <int>           <int>   <int> <int>
#>  1 PRESIDENT AN… JOSEPH R. BID… TRUE            59          284046       0     1
#>  2 US House of … NANCY PELOSI   TRUE           116          284054       1     1
#>  3 State Senato… SCOTT WIENER   TRUE           115          284055       1     1
#>  4 STATE ASSEMB… PHIL TING      TRUE           113          284058       1     1
#>  5 BOARD OF EDU… KEVINE BOGGESS TRUE            11          284059       0     1
#>  6 BOARD OF EDU… JENNY LAM      TRUE            10          284062       0     1
#>  7 BOARD OF EDU… MICHELLE PARK… TRUE            14          284064       0     1
#>  8 BOARD OF EDU… ALIDA FISHER   TRUE             7          284066       0     1
#>  9 COMMUNITY CO… TOM TEMPRANO   TRUE            52          284076       0     1
#> 10 COMMUNITY CO… MARIE HURABIE… TRUE            50          284077       0     1
#> 11 COMMUNITY CO… JEANETTE QUICK TRUE            49          284080       0     1
#> 12 COMMUNITY CO… SHANELL WILLI… TRUE            51          284083       0     1
#> # … with 3 more variables: MarkDensity <int>, IsAmbiguous <lgl>,
#> #   OutstackConditionIds <list>
```
