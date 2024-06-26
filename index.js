import aws from "aws-sdk";
import crypto from "node:crypto";
import fs from "node:fs";
import process from "node:process";
import child_process from "node:child_process";
import {promisify} from "node:util";
import stream from "node:stream";

const exec = promisify(child_process.exec);
const mkdir = promisify(fs.mkdir);
const pipeline = promisify(stream.pipeline);
const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);
const s3 = new aws.S3({apiVersion: "2006-03-01"})

/**
 * S3 bucket for parsed CIFP sqlite database files.
 *
 * @type {string}
 */
const TARGET_BUCKET = process.env["CIFP_TARGET_BUCKET"];
if (!TARGET_BUCKET) {
    throw Error("The [CIFP_TARGET_BUCKET] environment variable must be set to the target S3 bucket name.");
}

/**
 * S3 key prefix for parsed CIFP sqlite database files.
 *
 * @type {string}
 */
const TARGET_KEY_PREFIX = process.env["CIFP_TARGET_KEY_PREFIX"]?.replace(/\/$/, "");
if (!TARGET_KEY_PREFIX) {
    throw Error("The [CIFP_TARGET_KEY_PREFIX] environment variable must be set to the target S3 object key prefix.");
}

/**
 * Retrieve CIFP zip file(s) to the local `/tmp` directory.
 *
 * @param event the event.
 * @returns {Promise<[[string, string, string]]>} the paths to the CIFP zip file(s) in the local `/tmp` directory.
 */
const retrieveSources = async event => {
    const {Records: records} = event;
    const tag = crypto.randomBytes(16).toString("base64").replaceAll(/\//g, "_"),
        sources = [];
    for (const record of records) {
        const {s3: {bucket: {name: bucket}, object: {key}}} = record,
            name = key.substring(key.lastIndexOf("/") + 1),
            dir = `/tmp/cifp-${tag}-${sources.length}`,
            temp = `${dir}/${name}`,
            getParams = {Bucket: bucket, Key: key};
        console.debug(`Downloading CIFP from [s3://${bucket}/${key}].`);
        const {Body: content} = await s3.getObject(getParams).promise();
        console.debug(`Writing CIFP to [file://${temp}].`);
        await mkdir(dir);
        await writeFile(temp, Buffer.from(content));
        console.debug(`Wrote CIFP to [file://${temp}].`);
        sources.push([temp, bucket, key]);
    }
    console.debug(`Returning ${sources.length} source(s): [${sources.map(([source]) => source).sort().join("], [")}]`);
    return sources;
}

/**
 * Event handler.
 *
 * @param event the lambda event.
 * @returns {Promise<void>}
 */
export const handler = async event => {

    /* Retrieve CIFP cycle (zip) objects from S3 into /tmp. */
    const sources = await retrieveSources(event),
        targets = [];
    for (const [source] of sources) {

        /* Parse the next object to a bzipped sqlite database. */
        const targetPath = source.substring(0, source.lastIndexOf(".")),
            target = `${targetPath}.db.bz2`;
        console.debug(`Parsing CIFP from [file://${source}] to database [file://${target}].`);
        try {
            await exec(`/faa/parseCifp.sh ${source}`);
            targets.push(target);
            console.debug(`Parsed CIFP from [file://${source}] to database [file://${target}].`);
        } catch (error) {
            console.error(error);
            const {status, stderr, stdout} = error;
            console.error(`parseCifp returned error status ${status}.`);
            console.error(`STDERR: ${stderr}`);
            console.error(`STDOUT: ${stdout}`);
            throw Error(`parseCifp returned error status ${status}.`);
        }
    }

    /* Upload the parsed sqlite databases to S3. */
    for (const target of targets) {
        console.debug(`Reading database from [file://${target}].`);
        const data = await readFile(target),
            name = target.substring(target.lastIndexOf("/") + 1),
            key = `${TARGET_KEY_PREFIX}/${name}`,
            putParams = {
                Bucket: TARGET_BUCKET,
                Key: key,
                Body: data
            };
        console.debug(`Uploading database to [s3://${TARGET_BUCKET}/${key}].`);
        await s3.putObject(putParams).promise();
        console.debug(`Uploaded database to [s3://${TARGET_BUCKET}/${key}].`);
    }
}
