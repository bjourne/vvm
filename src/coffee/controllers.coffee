ScoreListCtrl = ($scope, Score) ->
    $scope.config =
        columns: [
            {field: 'Name', title: 'Namn'},
            {field: 'QualScore', title: 'Kvalpo�ng'},
            {field: 'ElimScore', title: 'Utslagspo�ng'},
            {field: 'FinalScore', title: 'Finalpo�ng'},
        ]
    $scope.listRef = new Firebase 'https://bjourne.firebaseio.com'
    $scope.listRef.on 'child_added', (snap) ->
        console.log 'added ' + snap            

