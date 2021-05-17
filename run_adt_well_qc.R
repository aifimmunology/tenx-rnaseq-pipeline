library(optparse)

option_list <- list(
  make_option(opt_str = c("-i", "--in_counts"),
              type = "character",
              default = NULL,
              help = "Input barcounter Tag_Counts.csv file",
              metavar = "character"),
  make_option(opt_str = c("-b", "--in_bcs"),
              type = "character",
              default = NULL,
              help = "Input 10x CellRanger barcodes.tsv.gz file",
              metavar = "character"),
  make_option(opt_str = c("-w", "--well_id"),
              type = "character",
              default = NULL,
              help = "Input WellID",
              metavar= "character"),
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
                     paste0(args$well_id,
                            "_adt_well_qc.Rmd"))

file.copy(system.file("rmarkdown/adt_well_qc.Rmd", package = "H5weaver"),
          rmd_loc,
          overwrite = TRUE)

rmarkdown::render(
  input = rmd_loc,
  params = list(in_counts = args$in_counts,
                in_bcs = args$in_bcs,
                well_id = args$well_id,
                out_dir = args$out_dir),
  output_file = args$out_html,
  quiet = TRUE
)

file.remove(rmd_loc)