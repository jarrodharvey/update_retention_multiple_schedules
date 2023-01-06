convert_docx_to_table <- function(docx_file) {
  if (!exists("docx_file")) {
    docx_file <- list.files("data/prov_sample_data", full.names = TRUE) %>%
      sample(1)
  }
  
  doc_raw <- docx_extract_all_tbls(read_docx(docx_file))

  doc_cleaned <- doc_raw %>%
    map(
      ~ .x %>%
        modify_at(
          1, ~ na_if(.x, "")
        )
    ) 

  relevant_columns_extracted <- map(doc_cleaned, extract_relevant_columns) %>%
    .[!is.na(.)] %>%
    bind_rows %>%
    filter(!grepl("[a-z]{5}", .$disposal.number)) %>%
    fill(disposal.number) %>%
    filter(grepl("(\\d+\\.){2}\\d+", .$disposal.number)) %>%
    split(as.factor(.$disposal.number)) %>%
    map(
      ~ tibble_row(
        disposal.number = .x %>%
          chuck("disposal.number") %>%
          unique,
        description = .x %>%
          chuck("description") %>%
          .[!is.na(.)] %>%
          paste(collapse = " "),
        disposal.action = .x %>%
          chuck("disposal.action") %>%
          .[!is.na(.)] %>%
          paste(collapse = " ")
      )
    ) %>%
    bind_rows %>%
    add_column(
      rda = docx_file %>%
        str_extract("[A-Za-z0-9_]*\\.docx") %>%
        str_remove("\\.docx"),
      .before = 1
    )

}
