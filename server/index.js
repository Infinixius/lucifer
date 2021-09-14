const express = require("express")
const app = express()
const config = require("./config.json")

app.get("/", (req, res) => {
  res.send("kndfnnbosdjbjsdjbfjhdjdjfajsbjsbsajhafhshjdbghjasbdvjnsdfnbjkfdbjbhdvfj!")
})

app.use(express.static("."))

app.listen(config.port, () => {
  console.log(`Example app listening at http://localhost:${config.port}`)
})
