const admin = require("../config/firebase");
const db = admin.firestore();

/* =========================
   USER
========================= */

async function getUser(uid) {
  const doc = await db.collection("users").doc(uid).get();
  return doc.exists ? doc.data() : null;
}

async function createUser(uid) {
  await db.collection("users").doc(uid).set({
    uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    hasDevice: false
  });
}

/* =========================
   DEVICE
========================= */

async function getDevice(uid, deviceId) {
  const doc = await db
    .collection("users")
    .doc(uid)
    .collection("devices")
    .doc(deviceId)
    .get();

  return doc.exists ? doc.data() : null;
}

async function createDevice(uid, deviceId, metadata = {}) {
  await db
    .collection("users")
    .doc(uid)
    .collection("devices")
    .doc(deviceId)
    .set({
      deviceId,
      firmwareVersion: metadata.firmwareVersion || "1.0.0",
      bedSide: metadata.bedSide || "LEFT",
      registeredAt: admin.firestore.FieldValue.serverTimestamp(),
      lastSeen: admin.firestore.FieldValue.serverTimestamp(),
      online: true,

      // Live vitals (initial default values)
      heartRate: 0,
      spo2: 0,
      bodyTemperature: 0,
      respirationRate: 0,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    });
}

async function updateDevice(uid, deviceId, updates) {
  await db
    .collection("users")
    .doc(uid)
    .collection("devices")
    .doc(deviceId)
    .update(updates);
}

/* =========================
   LIVE STATE (Overwritten Every 5-10s)
========================= */

async function updateLiveVitals(uid, deviceId, vitals) {
  const deviceRef = db
    .collection("users")
    .doc(uid)
    .collection("devices")
    .doc(deviceId);

  await deviceRef.set(
    {
      ...vitals,
      online: true,
      lastSeen: admin.firestore.FieldValue.serverTimestamp(),
      lastUpdated: admin.firestore.FieldValue.serverTimestamp()
    },
    { merge: true }
  );
}

/* =========================
   EVENTS (Historical Alerts)
========================= */

async function addEvent(uid, deviceId, event) {
  const ref = await db
    .collection("users")
    .doc(uid)
    .collection("devices")
    .doc(deviceId)
    .collection("events")
    .add({
      ...event,
      acknowledged: false,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    });

  return ref.id;
}

async function getEvents(uid, deviceId, limit = 20) {
  const snapshot = await db
    .collection("users")
    .doc(uid)
    .collection("devices")
    .doc(deviceId)
    .collection("events")
    .orderBy("timestamp", "desc")
    .limit(limit)
    .get();

  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}

module.exports = {
  getUser,
  createUser,
  getDevice,
  createDevice,
  updateDevice,
  updateLiveVitals,
  addEvent,
  getEvents
};