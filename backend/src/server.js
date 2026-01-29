require("dotenv").config();
const express = require("express");

const deviceRoutes = require("./routes/device.routes");

const app = express();
app.use(express.json());

app.use("/api", deviceRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
