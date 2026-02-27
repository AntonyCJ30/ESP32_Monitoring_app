const admin = require("../config/firebase");
const db = admin.firestore();

async function createUser(uid, email) {
  const userRef = db.collection("users").doc(uid);
  const doc = await userRef.get();

  if (!doc.exists) {
    await userRef.set({
      email,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      hasDevice: false,
      role: "PATIENT",
      status: "ACTIVE"
    });
  }
}

async function getUser(uid) {
  const doc = await db.collection("users").doc(uid).get();
  return doc.exists ? doc.data() : null;
}

async function updateUser(uid, updateData) {
  await db.collection("users").doc(uid).update(updateData);
}

async function deleteUser(uid) {
  await db.collection("users").doc(uid).delete();
}

module.exports = {
  createUser,
  getUser,
  updateUser,
  deleteUser
};