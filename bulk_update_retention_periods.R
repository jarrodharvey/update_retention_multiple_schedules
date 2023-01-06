rm(list = ls())
cat("\1")

# Load packages####
library('purrr')
library('magrittr')
library('docxtractr')
library('stringr')
library('tibble')
library('glue')
library('dplyr')
library('janitor')
library('tidyr')
library('pbapply')
library('readxl')
library('WriteXLS')
#####

walk(list.files("R", full.names = TRUE), source)

# Get the sample data from the PROV RDA files
# If you want to use your own RDA(s) write a function to extract/clean your
# disposal schedules and write that to the rda variable below instead.
# The RDA variable must contain the below three columns:
# 1. RDA: a unique identifier for the source document, e.g. "0901var1"
# 2. NUMBER: a unique identifier for the category within the source document, e.g. 5.4.2
# 3. DISPOSAL ACTION: The disposal action, e.g. "Destroy 7 years after last action"
rda <- get_prov_sample_data()

if (!every(c("RDA", "NUMBER", "DISPOSAL ACTION"), ~ .x %in% names(rda))) {
  stop(
    glue("Your rda variable MUST contain the columns RDA, NUMBER and ",
         "DISPOSAL ACTION")
  )
}

# Get the list of RDAs/IDs that need their retention information updated
replacement_retentions <- read_excel("data/new_retention_periods.xlsx")

# Do a left join on your "to update" list to get a list of categories to be
# updated, along with the new retention policy. You now have a df called
# "categories_to_update"
categories_to_update <- left_join(
  replacement_retentions, rda,
  by = c("RDA", "NUMBER")
) %>%
  relocate("New retention (years)", .after = last_col()) %>%
  modify_at(
    "New retention (years)",
    ~ paste(.x, "years") %>%
      str_replace("^1 years", "1 year")
  ) %>%
  add_column(
    "DISPOSAL ACTION (new)" = map2_chr(
      .$`DISPOSAL ACTION`,
      .$`New retention (years)`,
      \(original, replacement) {
        str_replace(original, "\\d+ years?", replacement)
      }
    ) 
  ) %>%
  modify_at(
    "New retention (years)",
    ~ str_remove(.x, " .*$")
  )

# Convert categories_to_update into the "replacement" rows and then use
# rows_update() to update them all
rda_with_new_retentions <- rda %>%
  rows_update(
    categories_to_update %>%
      select(
        "RDA", "NUMBER", "DISPOSAL ACTION" = "DISPOSAL ACTION (new)"
      ),
    by = c("RDA", "NUMBER")
  )

# Split the RDAs into separate lists so they can be written to separate
# .xlsx files
all_rdas_split <- rda_with_new_retentions %>%
  split(as.factor(.$RDA))

# Write each RDA with updated retention periods to the "outputs" folder
walk2(
  all_rdas_split,
  names(all_rdas_split),
  \(rda_table, rda_name) {
    WriteXLS(
      x = rda_table,
      ExcelFileName = glue("outputs/{rda_name}.xlsx"),
      AdjWidth = TRUE,
      AutoFilter = TRUE,
      BoldHeaderRow = TRUE,
      FreezeRow = 1
    )
  }
)
