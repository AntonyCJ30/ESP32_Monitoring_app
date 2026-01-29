const admin = require("../config/firebase");
const db = admin.database();

exports.storeDeviceData = async (deviceId, data) => {
  if (!deviceId || !data) {
    throw new Error("deviceId and data are required");
  }

  await db.ref(`telemetry/${deviceId}`).push({
    ...data,
    timestamp: Date.now(),
  });
};
