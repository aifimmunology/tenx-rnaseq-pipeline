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
  make_option(opt_str = c("-w","--in_well"),
              type = "character",
              default = NULL,
              help = "Well",
              metavar = "character"),
  make_option(opt_str = c("-u","--out-h5"),
              type = "character",
              default = NULL,
              help = "Output .h5 file",
              metavar = "character"),
  make_option(opt_str = c("-o","--out_html"),
              type = "character",
              default = NULL,
              help = "Output HTML run summary file",
              metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)

args <- parse_args(opt_parser)

if(is.null(args$in_h5)) {
  print_help(opt_parser)
  stop("No parameters supplied.")
}

file.copy(system.file("rmarkdown/add_nonhashed_metadata.Rmd", package = "H5weaver"),
          "./add_nonhashed_metadata.Rmd",
          overwrite = TRUE)

rmarkdown::render(
  input = "./add_nonhashed_metadata.Rmd",
  params = list(in_h5 = args$in_h5,
                in_mol = args$in_mol,
                in_well = args$in_well,
                out_h5 = args$out_h5),
  output_file = args$out_html,
  quiet = TRUE
)

file.remove("./add_nonhashed_metadata.Rmd")
