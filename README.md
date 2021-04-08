# tenx-rnaseq-pipeline

Scripts for annotating 10x Genomics scRNA-seq analysis data

<a id="contents"></a>

## Contents

#### [Dependencies](#dependencies)

### 10x cellranger scRNA-seq data

#### [Metadata Annotation: run_add_tenx_rna_metadata.R](#meta)
- [Parameters](#meta_param)
- [Non-Hashed Guidelines](#non)
  - [SampleSheet](#non_sample_sheet)
  - [Outputs](#non_out)
- [Cell Hashing Guidelines](#hash)
  - [SampleSheet](#hash_sample_sheet)
  - [Outputs](#hash_out)
- [Tests](#meta_test)

### 10x cellranger-arc processing

#### [Modifications for ARC](#arc)

#### [Format outputs: 00_arc_formatting.R](#arc_uuid)
- [Parameters](#arc_uuid_param)
- [Outputs](#arc_uuid_out)

#### [ARC Metadata Annotation: run_crossplatform_rna_metadata.R](#arc_meta)
- [Parameters](#arc_meta_param)
- [SampleSheet](#arc_meta_sample_sheet)
- [Outputs](#arc_meta_out)

<a id="dependencies"></a>

## Dependencies

This repository requires that `pandoc` and `libhdf5-dev` libraries are installed:
```
sudo apt-get install pandoc libhdf5-dev
```

It also depends on the `H5weaver`, `jsonlite`, `rmarkdown`, and `optparse` libraries.

`jsonlite`, `rmarkdown` and `optparse` are available from CRAN, and can be installed in R using:
```
install.packages("jsonlite")
install.packages("rmarkdown")
install.packages("optparse")
```

`H5weaver` is found in the aifimmunology Github repositories. Install with:
```
Sys.setenv(GITHUB_PAT = "[your_PAT_here]")
devtools::install_github("aifimmunology/H5weaver")
```

[Return to Contents](#contents)

<a id="meta"></a>

## Metadata annotation for cellranger results

This repository can add important QC characteristics and cell metadata for 10x Genomics. It requires the `filtered_feature_bc_matrix.h5`, `molecule_info.h5`, and `metrics_summary.csv` files generated by `cellranger count` as inputs, as well as a `SampleSheet.csv` file (as described below), and generates a decorated output .h5 file and a JSON metrics file based on these parameters and a WellID.

[Return to Contents](#contents)

<a id="meta_param"></a>

There are 7 parameters for this script:  
- `-i or --in_h5`: The path to the filtered_feature_bc_matrix.h5 file from cellranger outs/  
- `-l or --in_mol`: The path to the molecule_info.h5 file from cellranger outs/  
- `-s or --in_sum`: The path to the metrics_summary.csv file from cellranger outs/  
- `-k or --in_key`: The path to SampleSheet.csv  
- `-w or --in_well`: A well name to use for metadata in the format `[XB][0-9]{3}-P[0-9]C[0-9]W[0-9]`  
- `-d or --out_dir`: A directory to use to output the modified .h5 and JSON metrics  
- `-o or --out_html`: A filename to use to output the HTML summary report file  

An example run for a cellranger count result is:
```
Rscript --vanilla \
  tenx-rnaseq-pipeline/run_add_tenx_rna_metadata.R \
  -i /shared/lucasg/pipeline_cellhashing_tests/data/pool16/filtered_feature_bc_matrix.h5 \
  -l /shared/lucasg/pipeline_cellhashing_tests/data/pool16/molecule_info.h5 \
  -s /shared/lucasg/pipeline_cellhashing_tests/data/pool16/metrics_summary.csv \
  -k /shared/lucasg/pipeline_cellhashing_tests/data/pool16/SampleSheet.csv \
  -w X000-P1C1W3 \
  -d /shared/lucasg/pipeline_cellhashing_tests/output/pool16/ \
  -o /shared/lucasg/pipeline_cellhashing_tests/output/pool16/X000-P1C1W3_metadata_report.html
```

[Return to Contents](#contents)

## `SampleSheet.csv` formats and output filenames

This script is designed to work with both **Non-Hashed** and **Cell Hashed** input data.

Each should have a slightly different SampleSheet.csv, as described below. The primary difference is that **Non-Hashed** SampleSheets have a WellID column, whereas **Cell Hashed** SampleSheets have a HashTag column. The script will use this difference to detect the type of run.

<a id="non"></a>

<a id="non_sample_sheet"></a>

#### **Non-Hashed** `SampleSheet.csv`

For **Non-Hashed** runs, `SampleSheet.csv` conveys the relationship between SampleID and WellID.

It should have 4 columns: SampleID, BatchID, WellID, and PoolID
```
SampleID,BatchID,WellID,PoolID
PB00042,X051,X051-P1C1W1,X051-P1
PB00043,X051,X051-P1C1W2,X051-P1
PB00044,X051,X051-P1C1W2,X051-P1
```

[Return to Contents](#contents)

<a id="non_out"></a>

#### **Non-Hashed** output files

For **Non-Hashed** outputs, two files will be generated. The .h5 will be named based on PoolID and SampleID, while the JSON metrics for this well will be named based on WellID:  
- .h5 file: [PoolID]_[SampleID].h5, e.g. X051-P1_PB0042.h5
- JSON file: [WellID]_well_metrics.json, e.g. X051-P1C1W1_well_metrics.json

This ensures that the .h5 filename matches the .h5 naming convention that **Cell Hashed** files obtain after the merge step.

<a id="hash"></a>

<a id="hash_sample_sheet"></a>

#### **Cell Hashed** `SampleSheet.csv`

For **Cell Hashed** runs, `SampleSheet.csv` conveys the relationship between SampleID and HashTag.

It should have 4 columns: SampleID, BatchID, HashTag, and PoolID
```
SampleID,BatchID,HashTag,PoolID
PB00042,X051,HT1,X051-P1
PB00043,X051,HT2,X051-P1
PB00044,X051,HT3,X051-P1
```

<a id="hash_out"></a>

#### **Cell Hashed** output files

For **Cell Hashed** outputs, two files will be generated and will be named based on WellID:  
- .h5 file: [WellID].h5, e.g. X000-P1C1W3.h5
- JSON file: [WellID]_well_metrics.json, e.g. X000-P1C1W3_well_metrics.json

Unlike **Non-Hashed** datasets, these .h5 files are still a mixture of all SampleIDs, so filenames will reflect only the WellID at this stage.


[Return to Contents](#contents)

<a id="meta_test"></a>

### Tests

Test runs can be performed using datasets provided with the `H5weaver` package by excluding parameters other than `-o`.

```
Rscript --vanilla \
  tenx-rnaseq-pipeline/run_add_nonhashed_metadata.R \
  -o test_metadata_report.html
```

[Return to Contents](#contents)


<a id="arc"></a>

## Modifications for cellranger-arc

Some QC statistics and parameters differ when using cellranger-arc for 10x Multiome or TEA-seq experiments. To account for these differences, there are modified versions of a few key steps.

**NOTE** The scripts for this step are stored in the `tenx-atacseq-pipeline` repository. This step only needs to be performed once for a given cellranger-arc output set.

[Return to Contents](#contents)

<a id = "arc_uuid"></a>

### Format Arc Outputs

Prior to running processing of ATAC or RNA data from cellranger-arc output, run 00_run_arc_formatting.R to add a common UUID and restructure the metadata files from arc for downstream processing. This ensures that we don't end up with different UUIDs assigned in the RNA and ATAC arms of the pipeline.

<a id="arc_uuid_param"></a>

### Parameters

There are two parameters for this script:  
- `-t`: path to cellranger-arc outs/
- `-o`: path for the HTML output generated by the script

An example run is:
```
Rscript --vanilla tenx-atacseq-pipeline/00_run_arc_formatting.R \
  -t outs/
  -o arc_formatting_report.html
```

<a id="arc_uuid_out"></a>

### Outputs

This script outputs .csv files to the outs/ directory for downstream processing:
- arc_singlecell.csv: Arc version of the standard 10x ATAC singlecell.csv output
- atac_summary.csv: Arc version of the standard 10x ATAC summary.csv output
- rna_summary.csv: Arc version of the standard 10x RNA metrics_summary.csv

[Return to Contents](#contents)

<a id="arc_meta"></a>

## Metadata annotation for cellranger-arc results

As for standard scRNA-seq cellranger results, this script will add additional cell metadata to the RNA .h5 files.

In addition, it will separate the Gene Expression and Peaks matrices into separate matrix objects in the .h5 file to enable downstream processing of hashed runs.

[Return to Contents](#contents)

<a id="arc_meta_param"></a>

### Parameters

The main difference from the main difference in parameters is the use of the cellranger outs/ directory rather than specifying individual outputs. This version of the script will detect whether cellranger or cellranger-arc was used based on the presence or absence of the formatting script, above.

There are 5 parameters for this script:  
- `-t or --in_tenx`: The path to cellranger-arc outs/  
- `-k or --in_key`: The path to SampleSheet.csv  
- `-w or --in_well`: A well name to use for metadata in the format `[XB][0-9]{3}-P[0-9]C[0-9]W[0-9]`  
- `-d or --out_dir`: A directory to use to output the modified .h5 and JSON metrics  
- `-o or --out_html`: A filename to use to output the HTML summary report file  

An example run for a cellranger-arc count result is:
```
Rscript --vanilla \
  tenx-rnaseq-pipeline/run_arc_tenx_rna_metadata.R \
  -t outs/ \
  -k SampleSheet.csv \
  -w X000-P1C1W3 \
  -d rna_preprocessed/ \
  -o rna_preprocessed/X000-P1C1W3_metadata_report.html
```

[Return to Contents](#contents)

<a id="arc_meta_sample_sheet"></a>

### `SampleSheet.csv` formats and output filenames

This script is designed to work with both **Non-Hashed** and **Cell Hashed** input data.

Sample sheet formats follow the same conventions as [for scRNA-seq, above](#non_sample_sheet).

[Return to Contents](#contents)

<a id="arc_meta_out"></a>

### Output files

Ouput formats follow the same conventions as [for scRNA-seq, above](#non_out).

[Return to Contents](#contents)

