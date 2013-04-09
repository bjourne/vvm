log = (args...) -> console.log 'controllers', args...

ERROR_TEMPLATE = kendo.template '''
    <div class="k-widget k-tooltip k-tooltip-validation k-invalid-msg field-validation-error"
    style="margin: 0.5em; display: block;" >
    <span class="k-icon k-warning"></span>
    #=message#
    <div class="k-callout k-callout-n"></div></div>
    '''

ERROR_TO_MESSAGE = {
    'unique:user_id/uq-program_date': \
        'Det finns redan ett resultat för den här spelaren för det här datumet',
    'check:name/len' : \
        'Spelarens namn måste bestå av 3 eller fler bokstäver.',
    'check:name/format' : \
        'Spelarens namn får inte börja eller sluta med blanksteg.',
    'check:program_date/weekday' : \
        'Programmets datum måste infalla på en vardag.',
    'check:program_date/future' : \
        'Det inmatade datumet får inte ligga i framtiden.',
    'check:qual_score/oob' : \
        'Kvalpoängen får inte vara högre än frågeantalet.',
    'check:qual_questions/oob' : \
        'Antalet kvalfrågor måste vara mellan 1 och 100.',
    'check:final_score/oob' : \
        'Finalpoängen får inte vara högre än frågeantalet.',
    'check:final_questions/oob' : \
        'Antalet finalfrågor måste vara mellan 1 och 100.',
    'check:elim_score/oob' : \
        'Utslagspoängen får inte vara högre än frågeantalet.',
    'check:elim_questions/oob' : \
        'Antalet utslagsfrågor måste vara mellan 1 och 100.'
}

##############################################################################
dateToUTC = (date) ->
    new Date Date.UTC(date.getFullYear(), date.getMonth(), date.getDate())

parsePgError = (text) ->
    expressions = [
        '\\((?<error>[^\)]+)\\) duplicate key value violates (?<type>unique) constraint "(?<name>[^"]+)"\\s+' +
        'DETAIL:\\s+Key \\((?P<key>[^\)]+)\\)',
        '\\((?<error>[^\)]+)\\) new row for relation "(?P<rel>\\w+)" violates (?P<type>check) constraint "(?<name>[^"]+)"'
        ]
    results = (XRegExp.exec text, (XRegExp e) for e in expressions)
    result = _.find results
    if not result
        null
    else
        key = [result.type, result.name].join(":")
        [key, result]

objToHtmlAttrs = (obj) ->
    ((_.pairs obj).map ([k, v]) -> k + '="' + v + '"').join(' ')

appendScoreInput = (container, field) ->
    inputArgs = (field) ->
        type: "text"
        style: "width: 55px"
        name: field
        'data-bind': 'value: ' + field
    text = '<input ' + objToHtmlAttrs(inputArgs(field)) + '/>'
    $(text)
        .appendTo(container)
        .kendoNumericTextBox
            format: "#"
            min: 0
            max: 100
            upArrowText: 'Öka poängen'
            downArrowText: 'Minska poängen'

createScoreColumn = (title, scoreField, questionsField) ->
    editor = (container, opts) ->
        appendScoreInput container, scoreField
        $('<span> rätt av </span>').appendTo(container)
        appendScoreInput container, questionsField
    {
        title: title,
        template: (t) ->
            score = t[scoreField]
            questions = t[questionsField]
            ratio = kendo.toString score / questions, 'p0'
            score + " rätt av " + questions + " (" + ratio + ")"
        editor: editor,
        field: scoreField
    }

scoreField = ->
    type: 'number'
    validation:
        min: 0
        max: 100

kendoGridStateToRestless = (gs) ->
    restlessOrder = (ob) -> {field: ob.field, direction: ob.dir}
    order_by: (restlessOrder ob for ob in gs.sort ? [])

handleGridError = (err) ->
    text = err.xhr.responseText
    try
        obj = JSON.parse text
    catch error
        alert "Unexpected error occured: " + error + "\n" + text
        return
    message = obj.message
    t = parsePgError message
    if not t
        alert "No handler found for: " + message
        return

    key = t[0]
    message = ERROR_TO_MESSAGE[key]
    if not message
        alert "No message found for: " + key
        return

    gridId = @options.errorContainer
    field = t[1].name.split('/')[0]
    grid = $('#' + gridId).data('kendoGrid')
    if not grid
        alert 'No grid with id ' + gridId + ' found.'
        return
    container = grid.editable.element

    # one td may contain multiple fields.
    el = container.find('[data-bind="value: ' + field + '"]').closest('td')
    if not el.length
        el = container.find('[data-container-for="' + field + '"]')
    
    if not el.length
        msg = 'No element found for field: ' + field
        log 'handleGridError', msg
        alert msg
        return
    $('.field-validation-error').remove()
    el.append ERROR_TEMPLATE message: message

ScoreListCtrl = ($scope, User, Urls) ->
    $scope.$on 'userInfoChanged', (e, arg) ->
        refreshGrid $scope.gridId
    $scope.users = new kendo.data.DataSource
        type: 'json'
        transport:
            read:
                url: '/api/user'
                dataType: 'json'
        schema:
            data: (resp) -> resp.objects
            total: (resp) -> resp.num_results

    $scope.gridId = 'theGrid'
    $scope.config =
        dataSource:
            allowUnsort: false
            serverPaging: true
            serverSorting: true
            serverFiltering: true
            sort:
                field: 'program_date'
                dir: 'desc'
            pageSize: 10
            type: 'json'
            batch: false
            error: handleGridError
            # My extension
            errorContainer: $scope.gridId
            transport:
                read: '/api/score'
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
                        data.program_date = dateToUTC data.program_date
                        return kendo.stringify data
                    else
                        q = kendoGridStateToRestless data
                        q = kendo.stringify q
                        q = encodeURIComponent q
                        return 'q=' + q + '&page=' + data.page
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
                        user_id: {type: 'number'}
                        qual_score: scoreField()
                        qual_questions: scoreField()
                        elim_score: scoreField()
                        elim_questions: scoreField()
                        final_score: scoreField()
                        final_questions: scoreField()
        toolbar: [
            {name: 'create', text: 'Lägg in din poäng'}
        ]
        dataBound: ->
            grid = this
            userId = $scope.User.getUser().id
            $grid = $('#' + $scope.gridId)
            $grid.find('tbody tr .k-button')
                .each ->
                    $el = $(this)
                    di = grid.dataItem $el.closest('tr')
                    $el.toggle di.user_id == userId
            $grid.find('.k-toolbar').toggle(userId > 0)
        editable:
            update: true
            destroy: true
            confirmation: 'Säker på att du vill ta bort poängen?'
            mode: 'inline'
        sortable:
            allowUnsort: false
        pageable:
            messages:
                display: '{0} - {1} av {2} resultat'
                previous: 'Föregående sida'
                next: 'Nästa sida'
                first: 'Första sidan'
                last: 'Sista sidan'
        scrollable: false
        columns: [
            {
                field: 'program_date',
                title: 'Programmets datum',
                format: '{0:yyyy-MM-dd}'
            },
            {
                field: 'user_id'
                title: 'Spelare'
                template: (row) ->
                    user_id = row.user_id or $scope.User.getUser().id
                    grid = $('#' + $scope.gridId).data 'kendoGrid'
                    values = grid.columns[1].values
                    selValue = _.find values, (e) -> user_id == e.value
                    msg = 'Användare med id ' + user_id + ' saknas!'
                    if selValue then selValue.text else msg
                dsForeignKey:
                    dataTextField: $scope.formatUser
                    dataValueField: 'id'
                    dataSource: $scope.users
                editor: (container, opts) ->
                    text = $scope.formatUser($scope.User.getUser())
                    $(text).appendTo(container)
                encoded: true
            },
            createScoreColumn('Kvalificeringen', 'qual_score', 'qual_questions'),
            createScoreColumn('Utslagningen', 'elim_score', 'elim_questions'),
            createScoreColumn('Finalen', 'final_score', 'final_questions'),
            {
                command: [
                    {
                        name: 'edit',
                        text:
                            edit: 'Ändra'
                            update: 'Spara'
                            cancel: 'Avbryt'
                    },
                    {name: 'destroy', text: 'Ta bort'}
                ],
                title: '&nbsp;'
            }
        ]
