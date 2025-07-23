Parse freely available Coded Instrument Flight Procedures (CIFP) raw data from AeroNav/FAA as ARINC424 v18 into SQLite3 database

See here for an example of the output of this utility: https://www.dropbox.com/s/htex68b9fn4mgso/cifp-1707.db.zip?dl=0

See how Instrument Procedures (including SIDs and STARs) are actually constructed!

This is an adaptation of the original parseCifp code for use as a simple parser. Direct support for downloading the CIFP
cycle internally has been removed. **The original parseCifp was created by Jesse McGraw, jlmcgraw@gmail.com.**

### Use

```shell
docker run --rm -v /path/to/source/dir:/data registry.cinira.net/parse-cifp:latest /data/CIFP_[cycle].zip
# Output will be in /path/to/source/dir/CIFP_[cycle].db.xz 
```

### Multiplatform Build

```shell
# Install prepare multiplatform builder if necessary.
docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx create --name multiplatform_builder --platform linux/amd64,linux/arm64,linux/riscv64 --use
# Note: [platform] "linux/arm64", "linux/amd64", and "linux/riscv64" are supported.
docker buildx build --platform [platform] --push --tag [tag] .
```
### Build for all platforms and push to registry.cinira.net (assume version `X.Y.Z`)

```shell
docker login registry.cinira.net
# Enter username and password when prompted.
docker buildx build --push \
  --platform linux/amd64,linux/arm64,linux/riscv64 \
  --tag registry.cinira.net/parse-cifp:X.Y.Z \
  --tag registry.cinira.net/parse-cifp:X.Y \
  --tag registry.cinira.net/parse-cifp:X \
  --tag registry.cinira.net/parse-cifp:latest \
  .
```
