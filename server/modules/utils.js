module.exports.avoidCircularReference = function(obj) {
	return function(key, value) {
		return key && typeof value === "object" && obj === value ? undefined : value
	}
}