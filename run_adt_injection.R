library(optparse)

option_list <- list(
  make_option(opt_str = c("-i", "--in_h5"),
              type = "character",
              default = NULL,
              help = "",
              metavar = "character"),
  make_option(opt_str = c("-c", "--in_adt_counts"),
              type = "character",
              default = NULL,
              help = "Input ADT QC report counts matrix output",
              metavar = "character"),
  make_option(opt_str = c("-m", "--in_adt_meta"),
              type = "character",
              default = NULL,
              help = "Input ADT QC report metadata output",
              metavar = "character"),
  make_option(opt_str = c("-w", "--well_id"),
              type = "character",
              default = NULL,
              help = "Input well name",
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
                            "_adt_injection.Rmd"))

file.copy(system.file("rmarkdown/adt_injection.Rmd", package = "H5weaver"),
          rmd_loc,
          overwrite = TRUE)

rmarkdown::render(
  input = rmd_loc,
  params = list(in_h5 = args$in_h5,
                in_adt_counts = args$in_adt_counts,
                in_adt_meta = args$in_adt_meta,
                well_id = args$well_id,
                out_dir = args$out_dir),
  output_file = args$out_html,
  quiet = TRUE
)

file.remove(rmd_loc)