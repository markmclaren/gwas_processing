FROM continuumio/miniconda3:main

# Setup LDSC
COPY ldsc /ldsc
RUN conda env create -f /ldsc/environment.yml
RUN echo "source activate ldsc" > ~/.bashrc

# Compile bcftools because conda version has dependency problem
RUN apt-get update && apt-get install -y make gcc zlib1g-dev libbz2-dev lzma-dev lzma liblzma-dev curl libcurl4-openssl-dev
RUN curl -SL https://github.com/samtools/bcftools/releases/download/1.18/bcftools-1.18.tar.bz2 \
    | tar -xvj \
    && bcftools-1.18/configure \
    && make -C bcftools-1.18 \
    && mv bcftools-1.18/bcftools /opt/conda/envs/ldsc/bin


RUN mkdir -p /home/bin

# Get clumping reference
RUN apt-get install -y unzip
RUN wget -O plink.zip http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20181202.zip && mkdir -p /plink && mv plink.zip /plink && cd /plink && unzip plink.zip && mv plink /home/bin


ADD clump.py /home/bin
ADD ldsc.py /home/bin

# Path
ENV PATH /opt/conda/envs/ldsc/bin:/home/bin:$PATH
