const bigquery = require("./src/config/bigquery");

async function test() {
  try {
    const [rows] = await bigquery.query("SELECT 1 as test");
    console.log("✅ Query result:", rows);
  } catch (error) {
    console.error("❌ Error:", error);
  }
}

test();