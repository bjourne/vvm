userAuthorized = ->
    div = $('div[ng-view]')[0]
    scope = angular.element(div).scope().$$childHead
    scope.completeLogin()

angular.element(document).ready ->
    kendo.culture 'sv-SE'

deps = ['vvm.services', 'vvm.directives', 'ui', 'ui.bootstrap', 'ngSanitize']
mod = angular.module 'vvm', deps
mod.config ['$routeProvider', ($routeProvider) ->
    $routeProvider
        .when '/scores'
            templateUrl: 'partials/score.html'
            controller: ScoreListCtrl
        .otherwise redirectTo: '/scores'
    ]

