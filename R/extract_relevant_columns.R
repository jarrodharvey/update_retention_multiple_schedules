extract_relevant_columns <- function(rda_page) {
  if (!exists("rda_page")) {
    rda_page <- sample(doc_cleaned, 1) %>%
      chuck(1)
  }

  pg_cols_as_lists <- rda_page %>%
    as.list() %>%
    map(~ na_if(.x, "")) %>%
    unname() %>%
    # The script 'guesses' what the description column is based on which column
    # contains the most text. Somewhere this can fail is when it comes to
    # record storage and maintenance requirements (which can contain more
    # text than the description column). The workaround that works in this 
    # SPECIFIC instance is to simply not include columns that contain the 
    # keyword "APROSS", although this would of course cause problems if a legitimate
    # description column actually contained "APROSS"!
    map(
      ~ if (
        grepl("APROSS", .x) %>%
          any()
      ) {
        NA
      } else {
        .x
      }
    ) %>%
    .[!is.na(.)]

  number_col <- col_finder(
    pg_cols_as_lists,
    "(\\d+\\.){2}"
  )
  retention_col <- col_finder(
    pg_cols_as_lists,
    "(destroy|years|retain|archives)"
  )
  description_col <- col_finder(
    pg_cols_as_lists, "[a-z]",
    number_col, retention_col
  )

  if (length(description_col) == 0) {
    return(NA)
  }

  tibble(
    disposal.number = number_col,
    description = description_col,
    disposal.action = retention_col
  )
}
