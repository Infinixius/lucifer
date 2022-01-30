/* 
	keylimepie v1.1.1 - made with <3 by https://infinixius.github.io
	https://github.com/Infinixius/dumpster/tree/main/keylimepie
*/
const lime = {
	version: "1.1.1",
	versionNum: 7,
	platform: undefined
}

try { if (window) lime.platform = "browser" } catch (err) {}
try { if (process) lime.platform = "node" } catch (err) {}

/**
 * Returns the array alphabetically sorted.
 * // ["Orange","Apple","Grapes","Banana"].alphabeticalsort()
 * @returns Array
 */
Array.prototype.alphabeticalsort = function() {
	return this.sort((a, b) => {
		if (typeof a != "string") return 0
		if (typeof b != "string") return 0

		var fa = a.toLowerCase()
		var fb = b.toLowerCase()
	
		if (fa < fb) return -1
		if (fa > fb) return 1
		
		return 0
	})
}

/**
 * Returns a random item from the array.
 * // example: [0,1,2,3,4,5,6,7,8,9].random()
 * @returns Random item from the array
 */
Array.prototype.random = function() {
	return this[Math.floor(Math.random() * this.length)]
}

/**
 * Returns an array with elements up to amount, intended to be used in for loops. Essentially a port of Python's range().
 * example: Array.range(5) == [ 0, 1, 2, 3, 4 ]
 * @param amount Amount of elements in the array
 * @returns Any
 */
Array.prototype.range = function(amount) {
	if (amount === undefined) return new Error("Missing argument!")
	if (typeof amount != "number") return new Error("Not a number!")

	var range = []
	for (var i = 0; i < amount; i++) {
		range.push(i)
	}
	return range
}

/**
 * Capitalizes the first letter of a string.
 * example: "foobar".capitalize() would return "Foobar"
 * @returns String
 */
String.prototype.capitalize = function() {
	return this.slice(0,1).toUpperCase() + this.slice(1)
}

/**
 * Removes the first occurance of a string in another string. Alternative to String.replace("string", "").
 * example: "foobar".cut("bar") would return "foo"
 * @param string String to remove
 * @returns String
 */
String.prototype.cut = function(string) {
	if (string === undefined) return new Error("Missing argument!")
	if (typeof string != "string") return new Error("Not a string!")

	return this.replace(string, "")
}

/**
 * Find a string in another string. Alternative to "String.search() != -1" or "String.includes()".
 * example: "foobar".find("bar") would return "true"
 * @param string String to search for
 * @returns String
 */
String.prototype.find = function(search) {
	if (search === undefined) return new Error("Missing argument!")
	if (typeof search != "string") return new Error("Not a string!")

	if (this.search(search) != -1) { return true } else { return false }
}

/**
 * Removes all non-alphanumeric characters from a string. Uses `/[^a-z A-Z 0-9]+/g`.
 * @returns String
 */
String.prototype.sanitize = function() {
	return this.replace(/[^a-z A-Z 0-9]+/g, "")
}

/**
 * Removes all non-ASCII characters from a string. Uses `/[^\x00-\x7F]/g`.
 * @returns String
 */
 String.prototype.sanitizeascii = function() {
	return this.replace(/[^\x00-\x7F]/g, "")
}

/**
 * Returns a random number between min and max.
 * @param min 
 * @param max 
 * @returns Number
 */
lime.random = function(min, max) {
	if (min === undefined) return new Error("Missing argument!")
	if (typeof min != "number") return new Error("Not a number!")

	if (max === undefined) return Math.floor((Math.random() * max))
	
	return Math.floor((Math.random() * max) + min)
}

if (lime.platform == "node") global.lime = lime
if (lime.platform == "browser") window.lime = lime