angular.element(document).ready ->
    kendo.culture 'sv-SE'

app = angular.module('vvm', ['vvmServices', 'vvmDirectives'])
    .config ['$routeProvider', ($routeProvider) ->
        $routeProvider
            .when '/scores'
                templateUrl: 'partials/score.html'
                controller: ScoreListCtrl
            .otherwise redirectTo: '/scores'
        ]

