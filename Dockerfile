FROM amazonlinux:2 AS builder
RUN mkdir /faa
WORKDIR /faa
RUN yum -y update \
  && yum -y install bzip2 cpanminus gcc gzip tar unzip
RUN cpanm Carton
COPY cpanfile ./
RUN carton install
COPY addIndexes.sql \
  continuation_application_parsers.pl \
  continuation_base_parsers.pl \
  parseCifp.pl \
  parseCifp.sh \
  parsers.pl \
  sections.pl \
  ./

FROM builder AS runtime
RUN mkdir /data
WORKDIR /data
CMD ["/faa/parseCifp.sh", "/data/cifp.zip"]
