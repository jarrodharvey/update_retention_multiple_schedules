create_replacement_data <- function() {
  # Use to spawn replacement data for testing purposes
  # Will randomly pick out 60% of data for replacement
  sample_data <- rda %>%
    filter(grepl("\\d+ year", .$`DISPOSAL ACTION`)) %>%
    add_column(tmp.is.caa = (.$NAME == "Common Administrative Functions")) %>%
    split(as.factor(.$tmp.is.caa)) %>%
    modify_at("TRUE", ~ sample_n(.x, nrow(.x) * 0.3)) %>%
    bind_rows %>%
    transmute(
      "RDA" = .$RDA,
      "NUMBER" = .$`NUMBER`,
      "New retention (years)" = sample(1:50, nrow(.), replace = TRUE)
    ) %>%
    sample_n(nrow(.))
  
  WriteXLS(
    x = sample_data,
    ExcelFileName = "data/new_retention_periods.xlsx",
    AdjWidth = TRUE,
    AutoFilter = TRUE,
    BoldHeaderRow = TRUE,
    FreezeRow = 1
  )
}
