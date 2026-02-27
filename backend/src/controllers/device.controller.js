const deviceService = require("../services/device.service");

exports.registerDevice = async (req, res) => {
  try {
    const result = await deviceService.registerDevice(
      req.user.uid,
      req.body
    );

    res.status(200).json(result);

  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.updateState = async (req, res) => {
  try {
    const result = await deviceService.updateState(
      req.user.uid,
      req.body
    );

    res.status(200).json(result);

  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};