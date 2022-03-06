import {parse, stringify, toJSON, fromJSON} from "flatted"

export class CacheManager {
	constructor(object) {
		this.cachedObject = null
	}
	check(oldObject) {
		var object = parse(stringify(oldObject)) // copy everything in object to the copy using a json trick
		delete object.cache // prevent an infinite loop where copies contained themselves through the cache

		if (stringify(object) !== this.cachedObject) {
			this.cachedObject = stringify(object)
			return true
		} else {
			return false
		}
	}
}