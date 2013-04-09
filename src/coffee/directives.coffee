# This is my kendo extension for handling foreing keys bound to
# datasources.
#
# Nice recursive spaghetti code for handling asyncronous js. :)

# I like this kind of metaprogramming. :)
log = (args...) -> console.log 'directives', args...

processArraySerially = (arr, procFun, cb) ->
    if arr.length == 0
        cb()
    else
        procFun arr[0], ->
            processArraySerially _.rest(arr), procFun, cb

getterFunc = (strOrFunc) ->
    if typeof strOrFunc == 'string' then (o) -> o[strOrFunc] else strOrFunc

dataSourceToValues = (ds, textFunc, valueFunc) ->
    {text: textFunc(d), value: valueFunc(d)} for d in ds.data()

itemsToFkValues = (items, textFunc, valueFunc) ->
    {text: textFunc(i), value: valueFunc(i)} for i in items

preloadColumn = (c, cb) ->
    fkDef = c.dsForeignKey
    textGetter = getterFunc fkDef.dataTextField
    valueGetter = getterFunc fkDef.dataValueField
    ds = fkDef.dataSource
    # Remove existing change handler if present
    ds._events.change = []
    ds.bind 'change', (e) ->
        c.values = itemsToFkValues e.items, textGetter, valueGetter
        cb()
    # Trigger loading of datasource which trigger the change event.
    ds.read()

preloadColumns = (columns, cb) ->
    processArraySerially columns, preloadColumn, cb

preloadForeignKeys = (config, cb = -> null) ->
    log 'preloadForeignKeys', config
    columns = _.filter config.columns, 'dsForeignKey'
    preloadColumns columns, ->
        config.save = (e) ->
            m = e.model
            zeroColumns = _.filter columns, (c) -> m[c.field] == 0
            keyValues = ([c.field, c.values[0].value] for c in zeroColumns)
            defaults = _.object keyValues
            e.model = _.merge m, defaults
        cb()

refreshGrid = (gridId) ->
    grid = $('#' + gridId).data('kendoGrid')
    preloadForeignKeys grid, ->
        grid.dataSource.read()

mod = angular.module 'vvm.directives', []
mod.directive 'kgrid', ->
    restrict: 'E'
    replace: true
    scope:
        config: '=config'
        gridid: '=gridid'
    template: '<div id="{{gridid}}"></div>'
    link: (scope, el, attrs) ->
        preloadForeignKeys scope.config, ->
            grid = el.kendoGrid scope.config
            el.on 'keydown', 'tr', (e) ->
                code = if e.keyCode then e.keyCode else e.which
                if code == 13
                    $(e.srcElement).closest('tbody').focus()
                    setTimeout ->
                        el.data('kendoGrid').saveRow()

mod.directive 'kdropdown', ->
    restrict: 'E'
    replace: true
    scope:
        config: '=config'
        dropdownid: '=dropdownid'
    template: '<div id="{{dropdownid}}"></div>'
    link: (scope, el, attrs) ->
        el.kendoDropDownList scope.config




