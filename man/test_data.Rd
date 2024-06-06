\name{test_data}
\alias{test_data}
\docType{data}
\title{
An example input dataset for MintTea
}
\description{
An example input dataset for MintTea
}
\usage{data("test_data")}
\source{Franzosa, Eric A., et al. "Gut microbiome structure and metabolic activity in inflammatory bowel disease." Nature microbiology 4.2 (2019): 293-305.}
\format{
- Rows represent samples and columns are features;
- The dataframe should include two special columns: a column holding sample identifiers and a column holding study groups ("healthy" and "disease" labels);
- Features from each omic should start with the omic-prefix (for example: 'T_' for taxonomy, 'P_' for pathways, 'M_' for metabolites, etc.);
- Features in each view should be pre-processed in advance, according to common practices;
- It is highly recommended to remove rare features, and cluster highly correlated features;
}
