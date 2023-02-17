library(jsonlite)

cvr <- fromJSON("../../data-raw/json/CvrExport_24940.json", simplifyDataFrame = FALSE)


test_that("Internal Extract functions run as intended",
          {
            sess0 <- cvr$Sessions[[1]]
            card0 <- sess0$Original$Cards[[1]]
            cont0 <- card0$Contests[[1]]

            out_sess <- dominionCVR:::.extract_from_session(sess0)
            out_card <- dominionCVR:::.extract_from_card(card0)
            out_cont <- dominionCVR:::.extract_from_contest(cont0, card = card0)
            out_mark <- dominionCVR:::.extract_from_mark(cont0$Marks, cont0, card = card0)

            expect_equal(nrow(out_sess), 38)
            expect_equal(length(out_card), 13)
            expect_equal(length(out_cont), 1)
            expect_equal(length(out_mark), 10)
          })


test_that("Rcpp extract run as intended",
          {
            sess0 <- cvr$Sessions[1]
            out_marks <- extract_marks(sess0, max_marks = 1e5)
            expect_equal(nrow(out_marks), 38)
          })
