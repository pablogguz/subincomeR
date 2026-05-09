# tests/testthat/test-coverage.R
#
# Coverage / consistency tests between the DOSE CSV (Zenodo) and the
# GADM-DOSE geometries (Dropbox). These guard against the class of bug where
# the geometries gpkg is regenerated with mismatched GID_1 codes, leaving
# CSV rows with no matching polygon (e.g. v0.5.0's Canada/Portugal orphan
# regression).

test_that("every country in DOSE has at least one polygon in the geometries", {
  skip_on_cran()

  dose <- getDOSE()
  geom <- getDOSE_geom(download = TRUE)

  countries_in_csv <- sort(unique(dose$GID_0))
  countries_in_geom <- sort(unique(geom$GID_0))
  missing <- setdiff(countries_in_csv, countries_in_geom)

  expect_equal(
    missing, character(0),
    info = paste0(
      "Countries in DOSE CSV with NO matching polygons in the geometries: ",
      paste(missing, collapse = ", "),
      ". This usually means data-raw/_prepare_gpkg.R over-filtered GADM."
    )
  )
})

test_that("DOSE CSV GID_1 codes have matching polygons in the geometries", {
  skip_on_cran()

  dose <- getDOSE()
  geom <- getDOSE_geom(download = TRUE)

  # GID_1 codes present in the CSV but absent from the geometries:
  # these rows would silently produce NA polygons inside matchDOSE().
  orphans <- setdiff(unique(dose$GID_1), unique(geom$GID_1))

  # We tolerate a small number of orphans (DOSE occasionally has dependencies
  # or aggregated-only entries with no GADM-1 polygon), but a regression
  # like v0.5.0's (36 orphans, full Canada + Portugal) must fail loudly.
  expect_lt(
    length(orphans), 10,
    label = paste0(
      length(orphans), " GID_1 codes in DOSE CSV have no polygon in the ",
      "geometries gpkg (first few: ", paste(head(orphans, 10), collapse = ", "),
      ").  See data-raw/_prepare_gpkg.R."
    )
  )
})

test_that("matchDOSE returns a non-NA GID_1 for known coordinates in major DOSE countries", {
  skip_on_cran()

  # One coordinate per country: Toronto (CAN), Lisbon (PRT), Mexico City (MEX),
  # London (GBR), Tokyo (JPN). All of these countries are in DOSE; if any
  # comes back with NA GID_1, the geometries gpkg lost coverage for them.
  pts <- data.frame(
    lat  = c(43.6532, 38.7223, 19.4326, 51.5074, 35.6762),
    long = c(-79.3832, -9.1393, -99.1332, -0.1276, 139.6503),
    iso3 = c("CAN",    "PRT",    "MEX",   "GBR",   "JPN")
  )

  res <- matchDOSE(
    lat = pts$lat,
    long = pts$long,
    countries = pts$iso3,
    format_countries = "iso3c",
    download = TRUE
  )

  # one point may produce multiple year rows; collapse to (lat, long, GID_1)
  matched <- unique(res[, c("lat", "long", "GID_1")])
  expect_true(
    all(!is.na(matched$GID_1)),
    label = paste0(
      "matchDOSE returned NA GID_1 for at least one of: ",
      paste(pts$iso3[is.na(matched$GID_1)], collapse = ", ")
    )
  )
})
