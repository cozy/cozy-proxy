# Compares who array and returns true if they contains the same elements
module.exports.areEquals = (array1, array2) ->
    if not (array1 and array2)
        return false
    if array1.length isnt array2.length
        return false
    else
        isElementsEqual = array1.every (elem, i) -> elem is array2[i]
        return isElementsEqual
