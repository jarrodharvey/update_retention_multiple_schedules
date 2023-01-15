get_prov_sample_data <- function() {
  # Get dataset consisting of some PROV RDA files
  rda_categories_docx <-
    list.files("data/prov_sample_data", full.names = TRUE, pattern = "\\.docx") %>%
    pblapply(., convert_docx_to_table) %>%
    bind_rows() %>%
    filter(
      grepl("(destroy|disposal|archives|transfer|perm)", .$disposal.action,
            ignore.case = TRUE)
    ) %>%
    filter(
      !grepl("^(\\d+\\.){2}", .$disposal.action)
    ) %>%
    left_join(
      .,
      read_excel("data/prov_sample_data/pros_reference_index.xlsx"),
      by = c("rda" = "File name")
    ) %>%
    relocate(Coverage, 1) %>%
    modify_at(
      "disposal.action",
      ~ str_remove(.x, "^(Permanent|Temporary) ")
    )
  
  common_admin_functions <- read_excel("data/prov_sample_data/0701var7.xlsx") %>%
    filter(grepl("(\\d+\\.){2}\\d+", .$NUMBER)) %>%
    transmute(
      Coverage = "Common Administrative Functions",
      rda = "0701var7",
      disposal.number = .$NUMBER,
      description = .$DESCRIPTION,
      disposal.action = .$`CUSTODY`
    )
  
  prov_sample_data <- bind_rows(
    rda_categories_docx, common_admin_functions
  ) %>%
    rename(
      "NAME" = "Coverage",
      "RDA" = "rda",
      "NUMBER" = "disposal.number",
      "DESCRIPTION" = "description",
      "DISPOSAL ACTION" = "disposal.action"
    )
  
  return(prov_sample_data)
}