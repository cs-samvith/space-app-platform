const path = require("path");
const cors = require("cors");
const express = require("express");
const os = require("os");
const app = express(); // create express app

app.use(cors());

const bodyParser = require("body-parser");
app.use(bodyParser.json());

const PORT = process.env.PORT || 5000;

// // add middlewares
// const root = require("path").join(__dirname, "build");
// app.use(express.static(root));

// app.use("/*", (req, res) => {
//   res.sendFile(path.join(__dirname, "build", "index.html"));
// });

app.get("/api", (req, res) => {
  res.json({
    message: os.hostname(),
    env: { test: process.env.TESTENV },
  });
});

app.get("/healthz/readiness", (req, res) => {
  let isSystemStable = false;
  isSystemStable = true;
  const date = new Date();
  const formattedDate = date.toLocaleString("en-US", { timeZoneName: "short" });

  console.log("..................running readiness ==> " + formattedDate);
  if (isSystemStable) {
    res
      .json({
        status: "ready",
      })
      .status(200);
  } else {
    res.status(503); // Service unavailable
  }
});

app.get("/healthz/liveness", (req, res) => {
  let isSystemStable = false;
  const d = new Date();
  let minutes = Math.round(d.getMinutes() % 4);

  if (minutes === 0) {
    isSystemStable = false;
  } else {
    isSystemStable = true;
  }
  const date = new Date();
  const formattedDate = date.toLocaleString("en-US", { timeZoneName: "short" });

  console.log("..................running liveness ==> " + formattedDate);

  if (isSystemStable) {
    res
      .json({
        status: "not live",
      })
      .status(200);
  } else {
    res.status(503); // Service unavailable
  }
});

//add middleware
let root = require("path").join(__dirname, "build");
if (process.env.NODE_ENV === "development") {
  app.use(express.static(root));
  app.use("/*", (req, res) => {
    res.sendFile(path.join(__dirname, "build", "index.html"));
  });
} else {
  root = require("path").join(__dirname, "..", "client", "build");
  app.use(express.static(root));
  app.use("/*", (req, res) => {
    res.sendFile(path.join(__dirname, "..", "client", "build", "index.html"));
  });
}

// const bodyParser = require("body-parser");
// app.use(bodyParser.json());

// // add middlewares
// const root = require("path").join(__dirname, "build");
// app.use(express.static(root));

// app.use("/*", (req, res) => {
//   res.sendFile(path.join(__dirname, "build", "index.html"));
// });

// start express server on port 5000
// app.listen(process.env.PORT || 5000, () => {
//   console.log("server started");

app.listen(PORT || 5000, () => {
  console.log(`Server listening on ${PORT}`);
});
