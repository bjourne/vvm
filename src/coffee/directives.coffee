# This is my kendo extension for handling foreing keys bound to
# datasources.
#
# Nice recursive spaghetti code for handling asyncronous js. :)
dataSourceToValues = (ds, textField, valueField) ->
    {text: d[textField], value: d[valueField]} for d in ds.data()

preloadColumns = (columns, cb) ->
    if columns.length == 0
        cb()
    else
        col = columns[0]
        fkDef = col.dsForeignKey
        textField = fkDef.dataTextField
        valueField = fkDef.dataValueField
        ds = fkDef.dataSource
        ds.fetch (x) ->
            col.values = dataSourceToValues ds, textField, valueField
            preloadColumns _.rest(columns), cb

preloadForeignKeys = (config, cb) ->
    columns = _.filter config.columns, 'dsForeignKey'
    preloadColumns columns, ->
        config.save = (e) ->
            m = e.model
            zeroColumns = _.filter columns, (c) -> m[c.field] == 0
            keyValues = ([c.field, c.values[0].value] for c in zeroColumns)
            defaults = _.object keyValues
            e.model = _.merge m, defaults
        cb()

mod = angular.module 'vvmDirectives', []
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
    link: (scope, el, attrs) -> el.kendoDropDownList scope.config




