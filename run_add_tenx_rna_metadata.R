library(optparse)

option_list <- list(
  make_option(opt_str = c("-i","--in_h5"),
              type = "character",
              default = NULL,
              help = "Input filtered_feature_bc_matrix.h5 file",
              metavar = "character"),
  make_option(opt_str = c("-l","--in_mol"),
              type = "character",
              default = NULL,
              help = "Input molecule_info.h5 file",
              metavar = "character"),
  make_option(opt_str = c("-s", "--in_sum"),
              type = "character",
              default = NULL,
              help = "Input metrics_summary.csv file",
              metavar = "character"),
  make_option(opt_str = c("-k", "--in_key"),
              type = "character",
              default = NULL,
              help = "Input SampleSheet.csv file",
              metavar = "character"),
  make_option(opt_str = c("-w","--in_well"),
              type = "character",
              default = NULL,
              help = "Well",
              metavar = "character"),
  make_option(opt_str = c("-d","--out-dir"),
              type = "character",
              default = NULL,
              help = "Output directory",
              metavar = "character"),
  make_option(opt_str = c("-o","--out_html"),
              type = "character",
              default = NULL,
              help = "Output HTML run summary file",
              metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)

args <- parse_args(opt_parser)

if(is.null(args$out_html)) {
  print_help(opt_parser)
  stop("No parameters supplied.")
}

file.copy(system.file("rmarkdown/add_tenx_rna_metadata.Rmd", package = "H5weaver"),
          "./add_tenx_rna_metadata.Rmd",
          overwrite = TRUE)

rmarkdown::render(
  input = "./add_tenx_rna_metadata.Rmd",
  params = list(in_h5 = args$in_h5,
                in_mol = args$in_mol,
                in_sum = args$in_sum,
                in_key = args$in_key,
                in_well = args$in_well,
                out_dir = args$out_dir),
  output_file = args$out_html,
  quiet = TRUE
)

file.remove("./add_tenx_rna_metadata.Rmd")
