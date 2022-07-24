FROM public.ecr.aws/lambda/nodejs:16 AS builder
RUN mkdir /faa
WORKDIR /faa
COPY cpanfile /faa
RUN yum -y update \
  && yum -y install bzip2 cpanminus gcc gzip tar unzip \
  && cpanm Carton \
  && carton install

FROM builder AS parseCifp
COPY addIndexes.sql \
  continuation_application_parsers.pl \
  continuation_base_parsers.pl \
  parseCifp.pl \
  parseCifp.sh \
  parsers.pl \
  sections.pl \
  /faa
COPY package.json \
  index.js \
  ${LAMBDA_TASK_ROOT}
RUN pushd ${LAMBDA_TASK_ROOT} \
  && npm install \
  && popd
CMD ["index.handler"]
