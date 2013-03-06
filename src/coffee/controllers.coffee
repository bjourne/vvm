ScoreListCtrl = ($scope, Score) ->
    $scope.config =
        columns: [
            {field: 'Name', title: 'Namn'},
            {field: 'QualScore', title: 'Kvalpošng'},
            {field: 'ElimScore', title: 'Utslagspošng'},
            {field: 'FinalScore', title: 'Finalpošng'},
        ]
    $scope.listRef = new Firebase 'https://bjourne.firebaseio.com'
    $scope.listRef.on 'child_added', (snap) ->
        console.log 'added ' + snap            

