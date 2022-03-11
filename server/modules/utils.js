export function avoidCircularReference(obj) {
	return function(key, value) {
		return key && typeof value === "object" && obj === value ? undefined : value
	}
}