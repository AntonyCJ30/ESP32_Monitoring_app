const userRepository = require("../repositories/user.repository");


async function createUserProfile(uid, email) {
  await userRepository.createUser(uid, email);
}

async function getUserProfile(uid) {
  return await userRepository.getUser(uid);
}

async function updateUserProfile(uid, data) {
  // Only allow safe fields to update
  const allowedFields = ["status"];
  const filteredData = {};

  for (const key of allowedFields) {
    if (data[key] !== undefined) {
      filteredData[key] = data[key];
    }
  }

  await userRepository.updateUser(uid, filteredData);
}

async function deleteUserCompletely(uid) {
  await userRepository.deleteUser(uid);
  await admin.auth().deleteUser(uid);
}

module.exports = {
  createUserProfile,
  getUserProfile,
  updateUserProfile,
  deleteUserCompletely
};