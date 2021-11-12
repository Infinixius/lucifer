/* 
	keylimepie v1.0.4 - made with <3 by https://infinixius.github.io
	https://github.com/Infinixius/dumpster/tree/main/keylimepie
*/
const lime = {
	version: "1.0.4",
	versionNum: 5,
	platform: undefined
}

try { if (window) lime.platform = "browser" } catch (err) {}
try { if (process) lime.platform = "node" } catch (err) {}

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
 * @returns Array
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
 * Find a string in another string. Alternative to "String.search() != -1".
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

global.lime = lime