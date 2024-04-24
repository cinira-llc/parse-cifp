FROM amazonlinux:2
RUN mkdir /faa
WORKDIR /faa
COPY cpanfile /faa
RUN yum -y update \
  && yum -y install bzip2 cpanminus gcc gzip tar unzip \
  && cpanm Carton \
  && carton install
COPY addIndexes.sql \
  continuation_application_parsers.pl \
  continuation_base_parsers.pl \
  parseCifp.pl \
  parseCifp.sh \
  parsers.pl \
  sections.pl \
  /faa
CMD ["/faa/parseCifp.sh", "/faa/cifp.zip"]
