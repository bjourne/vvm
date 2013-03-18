USERINFO_TEMPLATE = kendo.template '''
    <span class = "userinfo">
        <img src="/show_image/#=id#.jpg">#=name# (#=provider#)
    </span>
    '''

userAuthorized = ->
    el = $('html[ng-app]')[0]
    scope = angular.element(el).scope()
    scope = scope.$$childHead
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

mod.run ($rootScope, User) ->
    $rootScope.startLogin = (provider) ->
        url = '/auth/' + provider + '/login'
        window.open url, null, 'height=600,width=400'
    $rootScope.completeLogin = ->
        User.init ->
            $rootScope.$broadcast 'userInfoChanged'
            $rootScope.$apply()
    $rootScope.logout = ->
        User.logout ->
            $rootScope.$broadcast 'userInfoChanged'
            $rootScope.$apply()

    $rootScope.formatUser = (user) ->
        if not user.display_name
            'okänd'
        else
            USERINFO_TEMPLATE
                id: user.id
                name: user.display_name
                provider: user.oauth_provider
    $rootScope.User = User
    $rootScope.completeLogin()

