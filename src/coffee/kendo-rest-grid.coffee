kendoGridStateToRestless = (gs) ->
    restlessOrder = (ob) -> {field: ob.field, direction: ob.dir}
    order_by: (restlessOrder ob for ob in gs.sort ? [])

kendoRestlessTransport = (baseUrl) ->
    read: baseUrl
    create:
        url: baseUrl
        contentType: 'application/json; charset=utf-8'
        dataType: 'json'
        type: 'post'
    update:
        url: (o) -> baseUrl + '/' + o.id
        contentType: 'application/json; charset=utf-8'
        dataType: 'json'
        type: 'patch'
    destroy:
        url: (o) -> baseUrl + '/' + o.id
        contentType: 'application/json; charset=utf-8'
        dataType: 'json'
        type: 'delete'
    parameterMap: (data, op) ->
        console.log data
        if op != 'read'
            mutateMatchingAttrs data, ((v) -> v instanceof Date), dateToUTC
            return kendo.stringify data
        else
            q = kendoGridStateToRestless data
            q = kendo.stringify q
            q = encodeURIComponent q
            return 'q=' + q + '&page=' + data.page
    
