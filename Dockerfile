FROM circleci/golang:1.12 AS base

WORKDIR /app
#
# ---- Dependencies (with packages) ----
FROM base AS dependencies
COPY . .
RUN go get -u golang.org/x/lint/golint
RUN go get -u github.com/mitchellh/gox
#
# ---- Test & Build ----
# run linters, setup and tests
FROM dependencies AS build_app
RUN make all-linux

#
# ---- Release App ----
FROM alpine:3.14.1 AS release_app
WORKDIR /usr/src
COPY --from=build_app /app/build/go-anonymize-mysqldump_linux_amd64.gz /usr/src
RUN gunzip -c /usr/src/go-anonymize-mysqldump_linux_amd64.gz > /usr/local/bin/anonymize-mysqldump
RUN chmod +x /usr/local/bin/anonymize-mysqldump
CMD [ "anonymize-mysqldump" ]