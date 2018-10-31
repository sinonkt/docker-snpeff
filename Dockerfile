FROM openjdk:8-slim

# MAINTAINER oatkrittin@gmail.com

ENV SNPEFF_HOME=/opt/snpEff 
ENV SNPEFF_JAR=/opt/snpEff/snpEff.jar 
ENV HTSLIB_VERSION=1.9
ENV APP_HOME=/usr/local/src
ENV PATH=$APP_HOME/vt:$PATH

# Install dependencies 
# utils tools like wget, unzip, bzip2 
# build-essential, zlib1g-dev, libbz2-dev, libcurl4-openssl-dev, libssl-dev, liblzma-dev needed to build htslib and other utils
RUN apt-get update && \
  apt-get -y install \
  wget \ 
  unzip \
  bzip2 \
  build-essential \ 
  zlibc \
  zlib1g-dev \
  libbz2-dev \
  libcurl4-openssl-dev \
  libssl-dev liblzma-dev \
  && \
  apt-get clean

# Install snpEff
RUN wget http://downloads.sourceforge.net/project/snpeff/snpEff_latest_core.zip \
  && unzip snpEff_latest_core.zip -d /opt/ \
  && rm snpEff_latest_core.zip

# Install htslib to get tabix, bgzip utils tools
RUN wget https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2 \
  && tar -xjf htslib-${HTSLIB_VERSION}.tar.bz2 \
  && cd htslib-${HTSLIB_VERSION} \
  && ./configure \
  && make && make install \
  && rm ../htslib-${HTSLIB_VERSION}.tar.bz2 

# Predefined supported reference databases to be pre-downloaded to this image. side notes: h - for human, m - for mouse
RUN for db in GRCh37.75; do java -jar $SNPEFF_JAR download $db; done

WORKDIR $APP_HOME

# Install vt
RUN git clone https://github.com/atks/vt.git 
RUN cd vt && make && make test
