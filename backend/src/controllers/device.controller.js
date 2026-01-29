const deviceService = require("../services/device.service");

exports.receiveDeviceData = async (req, res) => {
  try {
    const { deviceId, data } = req.body;

    await deviceService.storeDeviceData(deviceId, data);

    res.json({ status: "ok" });
  } catch (err) {
    console.error(err.message);
    res.status(400).json({ error: err.message });
  }
};
