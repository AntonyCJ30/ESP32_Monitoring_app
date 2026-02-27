const express = require("express");
const router = express.Router();

const verifyFirebaseToken = require("../middlewares/verifyFireBaseToken");
const deviceController = require("../controllers/device.controller");

// POST /api/register-device
router.post(
  "/register-device",
  verifyFirebaseToken,
  deviceController.registerDevice
);

// POST /api/update-state
router.post(
  "/update-state",
  verifyFirebaseToken,
  deviceController.updateState
);

module.exports = router;