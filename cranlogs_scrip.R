# generate_badge_json.R
library(cranlogs)
library(jsonlite)

##### Remove everything in badges/
unlink("badges", recursive = TRUE)
dir.create("badges", showWarnings = FALSE)

##### Packages and dates
pkg  <- cbind(c("CDatanet", "2021-02-17"),
              c("vMF", "2022-11-21"),
              c("PartialNetwork", "2023-08-22"), 
              c("QuantilePeer", "2025-06-19"))

npkgs <- ncol(pkg)
dwlds <- matrix(NA, npkgs, 2)
today <- Sys.Date()

##### Create json for each package
for (k in 1:npkgs) {
  downloads   <- cran_downloads(pkg[1, k], from = pkg[2, k])
  totd        <- sum(downloads$count)
  mond        <- sum(downloads[downloads$date >= today - 182,]$count)
  dwlds[k, 1] <- totd
  dwlds[k, 2] <- mond
  
  # Format number
  label     <- format(totd, big.mark = ",")
  
  json      <- list(
    schemaVersion = 1,
    label = "",
    message = paste0(label, " downloads"),
    color = "blue"
  )
  
  # Save JSON
  write_json(json, paste0("badges/", pkg[1, k],  ".json"), auto_unbox = TRUE)
}


##### Create general badge
dwlds <- colSums(dwlds)
dwlds <- list(date     = format(today, "%B %d, %Y"),
              total    = format(dwlds[1], big.mark = ","), 
              semester = format(dwlds[2], big.mark = ","))
jsonlite::write_json(dwlds, "badges/allpackages.json", auto_unbox = TRUE)

## Total downloads since first release
json <- list(
  schemaVersion = 1,
  label = "CRAN",
  message = paste0(dwlds$total, " downloads"),
  color = "blue"
)
jsonlite::write_json(json, "badges/alltotal.json", auto_unbox = TRUE)

## Downloads in the last 6 months
json <- list(
  schemaVersion = 1,
  label = "CRAN (last 6 months)",
  message = paste0(dwlds$semester, " downloads"),
  color = "blue"
)
jsonlite::write_json(json, "badges/allsemester.json", auto_unbox = TRUE)