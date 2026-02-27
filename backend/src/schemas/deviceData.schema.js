const { z } = require("zod");

const deviceDataSchema = z.object({
  deviceId: z.string().min(3),

  heartbeat: z.number().int().min(20).max(220),
  breathingRate: z.number().int().min(5).max(60),

  weightFL: z.number(),
  weightFR: z.number(),
  weightBL: z.number(),
  weightBR: z.number(),

  sleepStage: z.enum(["AWAKE", "LIGHT", "DEEP", "REM"]),
  position: z.enum(["BACK", "LEFT", "RIGHT", "STOMACH"]),

  timestamp: z.number()
});

module.exports = deviceDataSchema;