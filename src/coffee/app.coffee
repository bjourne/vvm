angular.element(document).ready ->
    kendo.culture 'sv-SE'

deps = ['vvmServices', 'vvmDirectives', 'ui', 'ui.bootstrap']

app = angular.module('vvm', deps)
    .config ['$routeProvider', ($routeProvider) ->
        $routeProvider
            .when '/scores'
                templateUrl: 'partials/score.html'
                controller: ScoreListCtrl
            .otherwise redirectTo: '/scores'
        ]

