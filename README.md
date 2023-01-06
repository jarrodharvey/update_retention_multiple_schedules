# update_retention_multiple_schedules

This script extracts categories from multiple disposal schedules (in the sample data provided, it extracts from some PROV RDAs) and updates their retention periods based on the contents of "data/new_retention_periods.xlsx".

It then writes the new schedules (with updated retention periods) to the "outputs" folder, with each schedule a separate spreadsheet.

## Usage

Open the .Rproject file in RStudio, and load the required packages from the R console.

```r
renv::restore()
```

You can adapt this to bulk update your own disposal schedule! 

In the line below:

```r
rda <- get_prov_sample_data()
```

Instead of get_prov_sample_data() you will need to write your own RDA(s) to the rda variable.

The rda variable MUST have the below columns:

1. RDA: a unique identifier for the source document, e.g. "0901var1"
2. NUMBER: a unique identifier for the category within the source document, e.g. 5.4.2
3. DISPOSAL ACTION: The disposal action, e.g. "Destroy 7 years after last action"

Make sure that the file in data/new_retention_periods.xlsx is filled in to reflect the changes to retention periods and the script will do the rest!
