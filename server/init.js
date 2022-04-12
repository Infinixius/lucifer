require("./assets/keylimepie.js")

if (process.argv.includes("--scan")) {
	require("./modules/lanscanner.client.js")
} else {
	require("./index.js")
}