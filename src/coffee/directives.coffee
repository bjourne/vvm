mod = angular.module 'vvmDirectives', []
mod.directive 'kgrid', ->
    restrict: 'E'
    replace: true
    scope:
        config: '=config'
    template: '<div id="theGrid"></div>'
    link: (scope, el, attrs) ->
        el.kendoGrid scope.config

    
