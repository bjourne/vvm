ScoreListCtrl = ($scope, $resource) ->
    $scope.config =
        dataSource:
            serverPaging: true
            serverSorting: true
            serverFiltering: true
            pageSize: 10
            type: 'json'
            transport:
                read:
                    url: '/api/score'
                    dataType: 'json'
                create:
                    url: '/api/score'
                    dataType: 'json'
                    type: 'post'
                parameterMap: (opts, op) ->
                    console.log op
                    console.log opts
                    if op != 'read' and opts.models
                        alert 'submitting data..'
            schema:
                data: (resp) ->
                    resp.objects
                total: (resp) ->
                    resp.num_results
                model:
                    id: 'id'
                    fields: 
                        id: {type: 'number'}
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
                title: 'Kvalpo�ng',
                format: '{0:#}'
            },
            {
                field: 'elim_score',
                title: 'Utslagspo�ng',
                format: '{0:#}'
            },
            {
                field: 'final_score',
                title: 'Finalpo�ng',
                format: '{0:#}'
            },
            {command: ['edit', 'destroy'], title: '&nbsp;' }
        ]
