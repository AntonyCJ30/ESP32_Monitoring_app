const { z } = require("zod");

const registerDeviceSchema = z.object({
  deviceId: z.string().min(3)
});

module.exports = registerDeviceSchema;