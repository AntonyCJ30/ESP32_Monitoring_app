const { BigQuery } = require("@google-cloud/bigquery");

const bigquery = new BigQuery(); 
// Uses GOOGLE_APPLICATION_CREDENTIALS automatically

console.log("📊 BigQuery initialized");

module.exports = bigquery;