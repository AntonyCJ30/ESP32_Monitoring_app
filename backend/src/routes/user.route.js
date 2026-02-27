const express = require("express");
const router = express.Router();

const verifyFirebaseToken = require("../middlewares/verifyFireBaseToken");
const userController = require("../controllers/user.controller");

router.post("/create-user", verifyFirebaseToken, userController.createUser);

router.get("/me", verifyFirebaseToken, userController.getUser);

router.patch("/update", verifyFirebaseToken, userController.updateUser);

router.delete("/delete", verifyFirebaseToken, userController.deleteUser);

module.exports = router;