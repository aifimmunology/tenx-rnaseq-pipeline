library(optparse)

option_list <- list(
  make_option(opt_str = c("-t","--in_tenx"),
              type = "character",
              default = NULL,
              help = "10x Cellranger outs/ dir",
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
  make_option(opt_str = c("-d","--out_dir"),
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

if(!dir.exists(args$out_dir)) {
  dir.create(args$out_dir)
}

rmd_loc <- file.path(args$out_dir,
                     paste0(args$in_well,
                            "_crossplatform_rna_metadata.Rmd"))

file.copy(system.file("rmarkdown/add_crossplatform_rna_metadata.Rmd", package = "H5weaver"),
          rmd_loc,
          overwrite = TRUE)

rmarkdown::render(
  input = rmd_loc,
  params = list(in_tenx = args$in_tenx,
                in_key = args$in_key,
                in_well = args$in_well,
                out_dir = args$out_dir),
  output_file = args$out_html,
  quiet = TRUE
)

file.remove(rmd_loc)
