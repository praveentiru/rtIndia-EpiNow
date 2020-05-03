#' Get India regional cases
#' 
#' @description This function downloads tha latest case data for india by region

get_india_regional_cases <- function() {

    source_pth <- "https://api.covid19india.org/csv/latest/state_wise_daily.csv"
    # Extract only confirmed cases from db
    confirmed_cases <- read.csv(url(source_pth)) %>% 
        dplyr::filter(Status == "Confirmed") %>%
        dplyr::mutate(date = as.Date(Date, format="%d-%b-%y")) %>%
        dplyr::filter(date != Sys.Date()) %>%
        dplyr::select(date, 4:40)
    # print(confirmed_cases)
    # Extract names of all regions from columns
    st_names <- colnames(confirmed_cases)
    st_names <- st_names[st_names != "date"]
    # Function to build a state case list
    build_state_list <- function(state, case_list = NULL) {
        case_list %>% 
            dplyr::mutate(region = state, cases = case_list[[state]]) %>%
            dplyr::select(date, region, cases)
    }
    # Build the output list
    lapply(st_names, build_state_list, case_list = confirmed_cases) %>% purrr::reduce(dplyr::bind_rows)
}
