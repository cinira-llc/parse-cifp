FROM --platform=linux/amd64 ubuntu:24.04 AS build-amd64
FROM --platform=linux/arm64 ubuntu:24.04 AS build-arm64
FROM --platform=linux/riscv64 riscv64/ubuntu:24.04 AS build-riscv64

FROM build-$BUILDARCH
RUN mkdir /app
WORKDIR /app
RUN apt update -y \
  && apt install -y cpanminus gcc unzip xz-utils
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
ENTRYPOINT ["/app/parseCifp.sh"]
