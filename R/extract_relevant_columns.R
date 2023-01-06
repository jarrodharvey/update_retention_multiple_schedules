extract_relevant_columns <- function(rda_page) {
  if (!exists("rda_page")) {
    rda_page <- sample(doc_cleaned, 1) %>%
      chuck(1)
  }

  pg_cols_as_lists <- rda_page %>%
    as.list() %>%
    map(~ na_if(.x, "")) %>%
    unname() %>%
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
