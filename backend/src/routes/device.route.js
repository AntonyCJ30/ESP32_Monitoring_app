const express = require("express");
const router = express.Router();
const deviceController = require("../controllers/device.controller");

router.post("/device-data", deviceController.receiveDeviceData);

module.exports = router;
