PROVIDER_TEMPLATE = kendo.template '''
    <div class = "loginalt">
        #if (data.slug) { #
        <img src = "/static/images/favicons/#=data.slug#.png"/>
        #=data.text#
        # } else { #
        Välj nätverk...
        # } #
    </div>
    '''

userAuthorized = ->
    scope = ngGetElementScope 'html[ng-app]'
    scope = scope.$$childHead
    scope.completeLogin()

angular.element(document).ready ->
    kendo.culture 'sv-SE'

deps = ['vvm.services', 'vvm.directives', 'ngSanitize']
mod = angular.module 'vvm', deps
mod.config ['$routeProvider', ($routeProvider) ->
    $routeProvider
        .when '/scores'
            templateUrl: 'static/partials/score.html'
            controller: ScoreListCtrl
        .when '/users/:slug'
            templateUrl: 'static/partials/user.html'
            controller: UserInstCtrl            
        .otherwise redirectTo: '/scores'
    ]

SOCIAL_LOGINS = [
    {text: 'Twitter', slug: 'twitter'},
    {text: 'Google+', slug: 'google'},
    {text: 'Facebook', slug: 'facebook'},
    {text: 'Github', slug: 'github'},
    {text: 'SoundCloud', slug: 'soundcloud'},
    {text: 'BitBucket', slug: 'bitbucket'}
    ]

mod.run ($rootScope, User, Urls) ->
    $rootScope.startLogin = (provider) ->
        url = Urls.logIn provider
        window.open url, null, 'height=600,width=400'
    $rootScope.completeLogin = ->
        User.init ->
            $rootScope.$broadcast 'userInfoChanged'
            $rootScope.$apply()
    $rootScope.logout = ->
        User.logout ->
            $rootScope.$broadcast 'userInfoChanged'
            $rootScope.$apply()
    $rootScope.providersConfig =
        optionLabel: 'Välj nätverk...'
        dataTextField: 'text',
        dataValueField: 'value'
        template: PROVIDER_TEMPLATE
        dataSource: SOCIAL_LOGINS
        select: (e) ->
            provider = (@dataItem e.item.index()).slug
            $rootScope.startLogin provider
    $rootScope.ddId = 'providers'

    $rootScope.formatUser = (user) ->
        userinfo = kendo.template '''
        <span class = "userinfo">
            <img src="#=imageUrl#">
            <a href = "\\#/users/#=slug#">#=name#</a> (#=provider#)
        </span>
        '''
        userinfo
            slug: user.display_slug
            id: user.id
            name: user.display_name
            provider: user.oauth_provider
            imageUrl: Urls.showImage(user.id)
    $rootScope.User = User
    $rootScope.completeLogin()

