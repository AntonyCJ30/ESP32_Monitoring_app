const userService = require("../services/user.service");

async function createUser(req, res) {
  try {
    const uid = req.user.uid;
    const email = req.user.email;

    await userService.createUserProfile(uid, email);

    res.json({ message: "User profile created successfully" });
  } catch (err) {
    console.error("🔥 CREATE USER ERROR:", err);
    res.status(500).json({ error: "Failed to create user profile" });
  }
}

async function getUser(req, res) {
  try {
    const uid = req.user.uid;

    const user = await userService.getUserProfile(uid);

    res.json(user);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch user" });
  }
}

async function updateUser(req, res) {
  try {
    const uid = req.user.uid;

    await userService.updateUserProfile(uid, req.body);

    res.json({ message: "User updated successfully" });
  } catch (err) {
    res.status(500).json({ error: "User update failed" });
  }
}

async function deleteUser(req, res) {
  try {
    const uid = req.user.uid;

    await userService.deleteUserCompletely(uid);

    res.json({ message: "User deleted completely" });
  } catch (err) {
    res.status(500).json({ error: "User deletion failed" });
  }
}

module.exports = {
  createUser,
  getUser,
  updateUser,
  deleteUser
};