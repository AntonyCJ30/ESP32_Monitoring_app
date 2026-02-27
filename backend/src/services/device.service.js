const registerDeviceSchema = require("../schemas/deviceRegistration.schema");
const deviceRepository = require("../repositories/device.repository");

// REGISTER DEVICE
exports.registerDevice = async (uid, body) => {
  const parsed = registerDeviceSchema.parse(body);
  const deviceId = parsed.deviceId;

 

  const existing = await deviceRepository.getDevice(uid, deviceId);
  if (existing) {
    throw new Error("Device already registered");
  }

  await deviceRepository.createDevice(uid, deviceId);


  return { message: "Device registered successfully" };
};


// UPDATE DEVICE STATE (Smart Merge)
exports.updateState = async (uid, body) => {
  const { deviceId, ...incoming } = body;

  if (!deviceId) {
    throw new Error("Device ID is required");
  }

  const existing = await deviceRepository.getDevice(uid, deviceId);
  if (!existing) {
    throw new Error("Device not found");
  }

  // Remove undefined values
  const cleaned = Object.fromEntries(
    Object.entries(incoming).filter(([_, v]) => v !== undefined)
  );

  // Get previous state
  const previousState = await deviceRepository.getCurrentState(uid, deviceId);

  // Merge
  const mergedState = {
    ...previousState,
    ...cleaned
  };

  await deviceRepository.setCurrentState(uid, deviceId, mergedState);

  // Optional anomaly detection
  await detectAnomalies(uid, deviceId, mergedState);

  return { message: "State updated successfully" };
};


// PRIVATE: anomaly detection
async function detectAnomalies(uid, deviceId, state) {
  const events = [];

  if (state.heartbeat && state.heartbeat > 120) {
    events.push({
      type: "HIGH_HEART_RATE",
      value: state.heartbeat,
      severity: "CRITICAL"
    });
  }

  if (state.breathingRate && state.breathingRate < 8) {
    events.push({
      type: "LOW_BREATHING_RATE",
      value: state.breathingRate,
      severity: "HIGH"
    });
  }

  for (const event of events) {
    await deviceRepository.addEvent(uid, deviceId, event);
  }
}