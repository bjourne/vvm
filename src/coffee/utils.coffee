ngGetElementScope = (expr) ->
    el = $(expr)[0]
    angular.element(el).scope()


    
