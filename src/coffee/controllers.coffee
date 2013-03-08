ERROR_TEMPLATE = kendo.template '<div class="k-widget k-tooltip ' +
    'k-tooltip-validation k-invalid-msg field-validation-error" ' +
    'style="margin: 0.5em; display: block; >' +
    '<span class="k-icon k-warning"></span>' +
    '#=message#' +
    '<div class="k-callout k-callout-n"></div></div>'

parsePgError = (text) ->
    expressions = [
        '\\((?<error>[^\)]+)\\) duplicate key value violates (?<type>unique) constraint "(?<name>[^"]+)"\\s+' +
        'DETAIL:\\s+Key \\((?P<key>[^\)]+)\\)',
        '\\((?<error>[^\)]+)\\) new row for relation "(?P<rel>\\w+)" violates (?P<type>check) constraint "(?<name>[^"]+)"'
        ]
    results = (XRegExp.exec text, (XRegExp e) for e in expressions)
    result = _.find results
    key = [result.error, result.type, result.name].join(":")
    [key, result]

showMessage = (container, name ,errors) ->
    container
        .find('[data-val-msg-for=' + name + ']')
        .replaceWith('hejsan!')

ERROR_TO_MESSAGE = {
    'IntegrityError:unique:uq/name+program_date' : [
        'name',
        'Det finns redan ett resultat för den här spelaren för det här datumet'
    ],
    'IntegrityError:check:name/len' : [
        'name',
        'Spelarens namn måste bestå av 3 eller fler bokstäver.'
    ],
    'IntegrityError:check:name/format' : [
        'name',
        'Spelarens namn får inte börja eller sluta med blanksteg.'
    ],        
    'IntegrityError:check:weekday' : [
        'program_date',
        'Programmets datum måste infalla på en vardag.'
    ],
    'IntegrityError:check:program_date/future' : [
        'program_date',
        'Det inmatade datumet får inte ligga i framtiden.'
    ]        
}            

handleGridError = (err) ->
    text = err.xhr.responseText
    try
        obj = JSON.parse text
    catch error
        alert "Unexpected error occured: " + error + "\n" + text
        return 
    err = obj.message
    console.log err
    [errId, data] = parsePgError err
    [field, message] = ERROR_TO_MESSAGE[errId]

    grid = $('#theGrid').data('kendoGrid')

    container = grid.editable.element
    el = container.find '[data-container-for="' + field + '"]'
    el.append ERROR_TEMPLATE message: message

ScoreListCtrl = ($scope, $resource) ->
    $scope.config =
        dataSource:
            serverPaging: true
            serverSorting: true
            serverFiltering: true
            pageSize: 10
            type: 'json'
            batch: false
            error: handleGridError
            transport:
                read:
                    url: '/api/score'
                    dataType: 'json'
                    type: 'get'
                create:
                    url: '/api/score'
                    contentType: 'application/json; charset=utf-8'
                    dataType: 'json'
                    type: 'post'
                update:
                    url: (o) -> '/api/score/' + o.id
                    contentType: 'application/json; charset=utf-8'
                    dataType: 'json'
                    type: 'patch'
                destroy:
                    url: (o) -> '/api/score/' + o.id
                    contentType: 'application/json; charset=utf-8'
                    dataType: 'json'
                    type: 'delete'
                parameterMap: (data, op) ->
                    if op != 'read'
                        d = data.program_date
                        data.program_date = new Date Date.UTC(d.getFullYear(), d.getMonth(), d.getDate())
                        return kendo.stringify data
            schema:
                data: (resp) -> resp.objects
                total: (resp) -> resp.num_results
                model:
                    id: 'id'
                    fields: 
                        id:
                            type: 'number'
                            editable: false
                            nullable: true
                        program_date: {type: 'date'}
                        name: {type: 'string'}
                        qual_score:
                            type: 'number'
                            validation:
                                min: 0
                                max: 100
                        elim_score: {type: 'number'}
                        final_score: {type: 'number'}
        toolbar: ['create']
        editable: 'inline'
        scrollable: false
        columns: [
            {
                field: 'program_date',
                title: 'Programmets datum',
                format: '{0:yyyy-MM-dd}'
            },
            {field: 'name', title: 'Namn'},
            {
                field: 'qual_score',
                title: 'Kvalpoäng',
                format: '{0:#}'
            },
            {
                field: 'elim_score',
                title: 'Utslagspoäng',
                format: '{0:#}'
            },
            {
                field: 'final_score',
                title: 'Finalpoäng',
                format: '{0:#}'
            },
            {command: ['edit', 'destroy'], title: '&nbsp;' }
        ]
