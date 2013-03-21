USERINFO_TEMPLATE = kendo.template '''
    <span class = "userinfo">
        <img src="/show_image/#=id#.jpg">#=name# (#=provider#)
    </span>
    '''

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
            templateUrl: 'partials/score.html'
            controller: ScoreListCtrl
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
    $rootScope.providersConfig =
        optionLabel: 'VÃ¤lj nÃ¤tverk...'
        dataTextField: 'text',
        dataValueField: 'value'
        template: PROVIDER_TEMPLATE 
        dataSource: SOCIAL_LOGINS
        select: (e) ->
            provider = (@dataItem e.item.index()).slug
            $rootScope.startLogin provider
    $rootScope.ddId = 'providers'

    $rootScope.formatUser = (user) ->
        USERINFO_TEMPLATE
            id: user.id
            name: user.display_name
            provider: user.oauth_provider
    $rootScope.User = User
    $rootScope.completeLogin()

