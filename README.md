Parse freely available Coded Instrument Flight Procedures (CIFP) raw data from AeroNav/FAA as ARINC424 v18 into SQLite3 database

See here for an example of the output of this utility: https://www.dropbox.com/s/htex68b9fn4mgso/cifp-1707.db.zip?dl=0

See how Instrument Procedures (including SIDs and STARs) are actually constructed!

This is an adaptation of the original parseCifp code for use with Amazon S3 and Lambda. **The original parseCifp was 
created by Jesse McGraw, jlmcgraw@gmail.com.**

### AWS Lambda

Builds `CIFP_[cycle].db.bz2` from `CIFP_[cycle].zip` files uploaded to an S3 bucket. 

1. Create a container lambda based on this image.
2. Set target bucket environment variables:
   * `CIFP_TARGET_BUCKET` bucket name.
   * `CIFP_TARGET_KEY_PREFIX` key prefix (if it does not contain a trailing `/`, one will be added.)
3. Configure an S3 bucket to send `PutObject` notifications to the lambda.
4. Grant the lambda execution role the following permissions:
   * S3 **Read** (`GetObject`) on the *source* S3 bucket.
   * S3 **Write** (`PutObject`) on the *target* S3 bucket.

> At the time of this writing, the following settings seem to be optimal for the lambda execution environment:
> * Architecture: ARM64 (cheaper)
> * Timeout: 15 minutes
> * Memory: 512MB
>
> Typically takes about 12 minutes to execute.

Building and pushing images:

```shell
# Note: [platform] "linux/arm64/v8" and "linux/amd64" are supported.
$ docker buildx build --platform [platform] --push --tag [tag] .
```
