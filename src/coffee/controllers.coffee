API_BASE = 'http://desolate-meadow-9868.herokuapp.com/api'

ScoreListCtrl = ($scope, $resource) ->
    $scope.config =
        columns: [
            {field: 'Name', title: 'Namn'},
            {field: 'QualScore', title: 'Kvalpo�ng'},
            {field: 'ElimScore', title: 'Utslagspo�ng'},
            {field: 'FinalScore', title: 'Finalpo�ng'},
        ]
    @Score = $resource(
        'http://desolate-meadow-9868.herokuapp.com/api/score/:scoreId',
    )
    @scores = @Score.get {scoreId: 4}
     
                

