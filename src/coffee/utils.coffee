ngGetElementScope = (expr) ->
    el = $(expr)[0]
    angular.element(el).scope()
    
dateToUTC = (date) ->
    new Date Date.UTC(date.getFullYear(), date.getMonth(), date.getDate())

objToHtmlAttrs = (obj) ->
    ((_.pairs obj).map ([k, v]) -> k + '="' + v + '"').join(' ')

mutateMatchingAttrs = (obj, matchFun, applyFun) ->
    for [k, v] in _.pairs obj
        if matchFun v
            obj[k] = applyFun v

class Logger
    constructor: (@name) ->
    log: (args...) ->
        console.log @name, args...                    



    
