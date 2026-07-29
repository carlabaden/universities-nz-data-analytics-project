# SAS Data Processing

This folder contains the SAS programs used to clean, transform, and prepare copyright usage data for the **CONZUL Copyright Dashboard** project.

The SAS workflow was used to standardise data from multiple New Zealand universities and prepare datasets for Tableau visualisation.

## Workflow

The SAS process included:

- Importing raw Excel datasets
- Cleaning and standardising variables
- Merging datasets across reporting years
- Applying lookup tables and classification rules
- Performing data quality checks
- Creating final datasets for dashboard development

## Files

### `otago_processing.sas`

This file is included as an example of the processing workflow applied to one university dataset.

It demonstrates:
- Importing and combining 2019–2024 data
- Standardising variables
- Applying course classification lookups
- Cleaning publication information
- Creating derived metrics

The same approach was adapted for other university datasets.

### `macros.sas`

Contains reusable SAS macros developed to improve consistency and reduce repeated code, including:

- Data import functions
- Material type standardisation
- Publication classification
- Cost calculations

## SAS Skills Demonstrated

- DATA step transformations
- PROC IMPORT
- PROC SQL
- Macro programming
- Dataset merging
- Data validation
- Text processing
