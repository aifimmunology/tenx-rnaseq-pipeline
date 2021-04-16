FROM us.gcr.io/dev-i-collabcloud/google-r-base@sha256:fc0f941fc133fc049f7df3150c2fe0b698ce9dbc04432000c730ce2f6cd90a3b
RUN apt-get update \
    && apt-get install -y \
    gcc-9-base \
    libgcc-9-dev \
    libc6-dev \
    python3-pip \
    libbz2-dev \
    liblzma-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libhdf5-dev \
    pandoc \
    && Rscript -e "install.packages(c('BiocManager', 'devtools', 'assertthat', 'cowplot', 'data.table', 'dplyr', 'ids', 'ggplot2', 'jsonlite', 'Matrix', 'optparse', 'purrr', 'R.utils', 'rmarkdown')); BiocManager::install('rhdf5')" \
    ## clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
## Install AIFI Github packages
COPY auth_token /tmp/auth_token
RUN export GITHUB_PAT=$(cat /tmp/auth_token) \
   && R -e ' devtools::install_github("aifimmunology/H5weaver", auth_token = Sys.getenv("GITHUB_PAT"))' \
  && git clone  https://aifi-gitops:$GITHUB_PAT@github.com/aifimmunology/tenx-rnaseq-pipeline.git \
  && rm -rf /tmp/downloaded_packages /tmp/*.rds /tmp/auth_token

#ENTRYPOINT ["tail", "-f", "/dev/null"]