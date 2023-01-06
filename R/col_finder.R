col_finder <- function(original_lists, pattern, number_col = NA, retention_col = NA) {
  if (!all(is.na(number_col)) && !all(is.na(retention_col))) {
    new_lists <- original_lists %>%
      .[map(., ~ identical(.x, number_col)) %>%
        unlist() %>%
        !.] %>%
      .[map(., ~ identical(.x, retention_col)) %>%
        unlist() %>%
        !.]
  } else {
    new_lists <- original_lists
  }
  new_lists %>%
    map(
      ~ grep(pattern, .x, value = TRUE, ignore.case = TRUE) %>%
        unlist()
    ) %>%
    map_int(length) %>%
    which.max(.) %>%
    new_lists[.] %>%
    unlist() %>%
    as.character()
}
