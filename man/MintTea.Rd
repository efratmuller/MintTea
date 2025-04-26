\name{MintTea}
\alias{MintTea}
\title{MintTea - Identifying Disease-Associated Modules in Multi-Omic Microbiome Data}
\description{
The MintTea function receives a table containing multiple concatenated omics, alongside sample ids and study groups. It identifies modules of features from all omics that are both highly associated with one another and often also highly associated with disease state. After identifying the modules, their association to disease is evaluated using AUROC.
}
\usage{MintTea(x)}
\arguments{
  \item{proc_data}{A single table containing all features of all views. Samples are rows and features are columns. Two special columns expected are a column holding sample identifiers and a column holding study groups ("healthy" and "disease"). Features from each view should start with a prefix representing the specific view followed by two underscores, e.g. 'T_' for taxonomy, 'G_' for genes, 'P_' for pathways, 'M_' for metabolites. Features in each view should be pre-processed according to common practices. It is advised to remove rare features, and cluster highly-correlated features.}
  \item{study_group_column}{Name of column holding study groups}
  \item{control_group_name}{Label for the "control" group. Should match the labels given in the `study_group_column` column. Defaults to "healthy"}
  \item{case_group_name}{Label for the "case" group. Should match the labels given in the `study_group_column` column. Defaults to "disease"}
  \item{sample_id_column}{Name of column holding sample identifiers}
  \item{view_prefixes}{Vector of prefixes marking the different views/omics}
  \item{param_diablo_keepX}{Number of features to select from each view, serving as a constraint for the sparse CCA. Note: these are sparsity constraints for the CCA modules, not the final consensus modules. Higher values will produce larger modules. More than one value can be provided if sensitivity analysis is desired. Default: 10}
  \item{param_sgcca_design}{A prior on expected relations between different views. Supports values between 0 and 1 (inclusive). 0 indicates no association between views is expected, and modules should maximize association with disease only. 1 indicates expected inter-view association and modules should therefore maximize both disease-association and between-view associations. More than one value can be provided if sensitivity analysis is desired. Default: 0.5}
  \item{param_n_repeats}{Number of sCCA repeats on data subsamples. More than one value can be provided if sensitivity analysis is desired.}
  \item{param_n_folds}{Number of folds used for subsetting the data before running sCCA (DIABLO). A value of 10, for example, will divide the data into 10 subsets, and then run CCA on 9/10 of the data, excluding each subset one at a time. Lower values will result in smaller subsets used for training and accordingly to higher variability between sCCA models. In such a case we expect less modules to be identified, but their robustness to be higher. More than one value can be provided if sensitivity analysis is desired.}
  \item{param_sgcca_ncomp}{Number of sCCA components to extract each DIABLO run. Note that DIABLO authors recommend using only the first few components. Typically, components >3 are less stable, and will often not contribute to final consensus modules. More than one value can be provided if sensitivity analysis is desired. Default: 5}
  \item{param_edge_thresholds}{Number between 0 and 1 (exclusive), determining the threshold for consensus components. Higher values mean more conservative results. Values between 0.5 and 0.8 are recommended. More than one value can be provided if sensitivity analysis is desired. Default: 0.8}
  \item{n_evaluation_repeats}{Number of cross-validation repeats for overall AUROC estimation}
  \item{n_evaluation_folds}{Number of cross-validation folds for overall AUROC estimation}
  \item{log_level}{See \code{library(logger); ?log_levels}. Default: \code{DEBUG}}
  \item{seed}{For result reproducibility}
}
\details{
The function returns the modules themselves alongside overall AUROC evaluations, module specific AUROC evaluations, and various other statistics. The entire evaluation process is also performed on shuffled modules, serving as null models to compare to.

The pipeline could be run using one or more set of pipeline parameters. If more than one parameter is given in any of the arguments (only those starting with the param_ prefix) then all parameter combinations will be used, and results will include a column indicating the specific set of parameters used for each result. User is advised to examine results and choose a single combination of parameters that best fits his data and research objectives.

Future versions will include:
- Support for running in parallel on multiple threads;
- Support for more than 2 study groups;
- Support for continuous labels;
- Support for using an independent validation set for AUC calculations, rather than CV;
}
\value{
A list of MintTea's multi-view modules, for each MintTea pipeline setting used.
For each module, the following properties are returned:
* Module size
* List of module features
* Module's AUROC and shuffled modules' AUROC
* Average correlations between features from different views, and the same for shuffled modules
* A list of edge weights in case the user wants to draw the module as a network
}
\references{Muller, Efrat, Itamar Shiryan, and Elhanan Borenstein. "Multi-omic integration of microbiome data for identifying disease-associated modules." Nature Communications 15.1 (2024): 2621.}
\seealso{
\code{library(mixOmics); library(PMA)}
}
\examples{
library(MintTea)

# Load example data
data("test_data")

# Run MintTea
minttea_results <- MintTea(test_data, view_prefixes = c('T', 'P', 'M'))
}

