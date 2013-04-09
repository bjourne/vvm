dateToUTC = (date) ->
    new Date Date.UTC(date.getFullYear(), date.getMonth(), date.getDate())

objToHtmlAttrs = (obj) ->
    ((_.pairs obj).map ([k, v]) -> k + '="' + v + '"').join(' ')

mutateMatchingAttrs = (obj, matchFun, applyFun) ->
    for [k, v] in _.pairs obj
        if matchFun v
            console.log 'applying'
            obj[k] = applyFun v



    
