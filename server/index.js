const express = require("express")
const app = express()
const config = require("./config.json")

app.get("/", (req, res) => {
  res.send("Hello World!")
})

app.listen(config.port, () => {
  console.log(`Example app listening at http://localhost:${config.port}`)
})
