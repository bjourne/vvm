mod = angular.module 'vvmDirectives', []
mod.directive 'kgrid', ->
    restrict: 'E'
    replace: true
    scope:
        config: '=config'
    template: '<div id="theGrid"></div>'
    link: (scope, el, attrs) ->
        grid = el.kendoGrid scope.config
        el.on 'keydown', 'tr', (e) ->
            code = if e.keyCode then e.keyCode else e.which
            if code == 13
                $(e.srcElement).closest('tbody').focus()
                setTimeout ->
                    el.data('kendoGrid').saveRow()
                
    
