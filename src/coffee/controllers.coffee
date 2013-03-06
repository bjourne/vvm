ScoreListCtrl = ($scope, Score) ->
    $scope.config =
        columns: [
            {field: 'Name', title: 'Namn'},
            {field: 'QualScore', title: 'Kvalpoäng'},
            {field: 'ElimScore', title: 'Utslagspoäng'},
            {field: 'FinalScore', title: 'Finalpoäng'},
        ]
    $scope.listRef = new Firebase 'https://bjourne.firebaseio.com'
    $scope.listRef.on 'child_added', (snap) ->
        console.log 'added ' + snap            

