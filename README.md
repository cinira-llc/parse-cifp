Parse freely available Coded Instrument Flight Procedures (CIFP) raw data from AeroNav/FAA as ARINC424 v18 into SQLite3 database

See here for an example of the output of this utility: https://www.dropbox.com/s/htex68b9fn4mgso/cifp-1707.db.zip?dl=0

See how Instrument Procedures (including SIDs and STARs) are actually constructed!

This is an adaptation of the original parseCifp code for use as a simple parser. Direct support for downloading the CIFP
cycle internally has been removed. **The original parseCifp was created by Jesse McGraw, jlmcgraw@gmail.com.**

### Use

1. Mount the CIFP cycle file at `/faa/cifp.zip`
2. Run the container.
3. Copy the resulting SQLite3 database from `/faa/cifp-cifp.db`.

```shell
# Note: [platform] "linux/arm64" and "linux/amd64" are supported.
$ docker buildx build --platform [platform] --push --tag [tag] .
```
