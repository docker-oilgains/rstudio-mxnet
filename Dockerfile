# no rocker here
FROM f0nzie/rstudio
MAINTAINER Alfonso Reyes

# install python-dev. This affects the .so library loading
RUN apt-get update \
    && apt-get upgrade \
    && apt-get install -y --no-install-recommends \
    r-base \
    r-base-dev \
    build-essential \
    git \
    ## install BLAS and LAPACK
    libopenblas-dev \
    liblapack-dev \
    ## install OpenCV
    libopencv-dev \
    ## necessary for devtools. otherwise not compiling from code
    ## in packages like diagrammeR
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libxt-dev \
    fftw3 \
    fftw3-dev \
    pkg-config

# install mxnet as rstudio user
USER rstudio
# download MxNet sources and build MXNet core shared library
RUN cd ~/ \
    && git clone --recursive https://github.com/apache/incubator-mxnet.git mxnet --branch 0.11.0 \
    && cd mxnet \
    && make -j $(nproc) USE_OPENCV=1 USE_BLAS=openblas \
# build and install the MxNet binding
    && make rpkg \
    && R CMD INSTALL mxnet_current_r.tar.gz

# go back as root user
USER root

# install packages that are used in the demos
RUN install2.r --error \
    codetools \
    tictoc \
    randomForest \
    xgboost \
    tidyverse \
    fftwtools
