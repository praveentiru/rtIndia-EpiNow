#' Generates regional rt estimates for India
#'

#Packages
require(EpiNow, quietly = TRUE)
require(NCoVUtils, quietly = TRUE)
require(furrr, quietly = TRUE)
require(future, quietly = TRUE)
require(dplyr, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(magrittr, quietly = TRUE)
require(future.apply, quietly = TRUE)
require(fable, quietly = TRUE)
require(fabletools, quietly = TRUE)
require(feasts, quietly = TRUE)
require(urca, quietly = TRUE)

# Get cases
NCoVUtils::reset_cache()

cases <- get_india_regional_cases()

cases <- cases %>%
  dplyr::rename(local = cases) %>%
  dplyr::mutate(imported = 0) %>%
  tidyr::gather(key = "import_status", value = "cases", local, imported) %>% 
  tidyr::drop_na(region)

# Get linelist ------------------------------------------------------------

linelist <-  NCoVUtils::get_international_linelist()

# Set up cores -----------------------------------------------------
if (!interactive()){
  options(future.fork.enable = TRUE)
}

future::plan("multiprocess", workers = future::availableCores())

data.table::setDTthreads(threads = 1)

# Run pipeline ----------------------------------------------------

EpiNow::regional_rt_pipeline(
  cases = cases,
  linelist = linelist,
  regional_delay = FALSE,
  target_folder = "india/regional",
  horizon = 14,
  approx_delay = TRUE
)

# EpiNow::regional_rt_pipeline(
#   cases = cases,
#   linelist = linelist,
#   regional_delay = FALSE,
#   target_folder = "india/regional",
#   horizon = 14,
#   approx_delay = TRUE,
#   report_forecast = TRUE,
#   forecast_model = function(...) {
#     EpiSoon::fable_model(model = fabletools::combination_model(fable::RW(y ~ drift()), fable::ETS(y), 
#                                                                fable::NAIVE(y),
#                                                                cmbn_args = list(weights = "inv_var")), ...)
#   }
# )

# Summarise results -------------------------------------------------------

EpiNow::regional_summary(results_dir = "india/regional",
                         summary_dir = "india/regional-summary",
                         target_date = "latest",
                         region_scale = "Region")
