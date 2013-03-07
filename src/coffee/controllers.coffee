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
            schema:
                data: (resp) ->
                    console.log resp
                    resp.objects
                total: (resp) ->
                    console.log resp
                    resp.num_results
                model:
                    id: 'id'
                    fields: 
                        id: {type: 'number'}
                        name: {type: 'string'}
        columns: [
            {field: 'id', title: 'ID'},
            {field: 'name', title: 'Namn'}
            {field: 'QualScore', title: 'Kvalpoäng'},
            {field: 'ElimScore', title: 'Utslagspoäng'},
            {field: 'FinalScore', title: 'Finalpoäng'}
        ]
