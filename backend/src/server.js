require("dotenv").config();
require("./config/firebase");
require("./config/bigquery")

const express = require("express");
const deviceRoute = require("./routes/device.route");
const userRoute  = require("./routes/user.route");

const app = express();
app.use(express.json());

app.use("/api", deviceRoute);
app.use("/api",userRoute)

const PORT = process.env.PORT || 3000;


app.listen(PORT, () => {
  console.log(`🚀 Backend running on port ${PORT}`);
});
