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
    {text: 'Twitter', value: '1', icon: 'twitter.png'},
    {text: 'Google+', value: '2', icon: 'gplus.png'},
    {text: 'Facebook', value: '3', icon: 'facebook.png'},
    {text: 'Github', value: '4', icon: 'github.png'},
    {text: 'SoundCloud', value: '5', icon: 'soundcloud.png'}
    {text: 'BitBucket', value: '6', icon: 'bitbucket.png'}  
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
        optionLabel: 'Välj nätverk...'
        dataTextField: 'text',
        dataValueField: 'value'
        template: '<div class="loginalt"><img src = "/static/images/favicons/${ data.icon }"/> ${ data.text }</div>'
        dataSource: SOCIAL_LOGINS 
    $rootScope.ddId = 'providers'                    

    $rootScope.formatUser = (user) ->
        if not user.display_name
            'okÃ¤nd'
        else
            USERINFO_TEMPLATE
                id: user.id
                name: user.display_name
                provider: user.oauth_provider
    $rootScope.User = User
    $rootScope.completeLogin()

