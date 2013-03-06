angular.module("vvm", ['vvmServices', 'vvmDirectives'])
    .config ["$routeProvider", ($routeProvider) ->
        $routeProvider
            .when "/scores"
                templateUrl: "partials/score.html"
                controller: ScoreListCtrl
            .otherwise redirectTo: "/scores"
        ]                            
