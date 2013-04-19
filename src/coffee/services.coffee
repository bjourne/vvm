mod = angular.module('vvm.services', [])

mod.factory 'Urls', ->
    @authPrefix = '/users'
    listUsers: '/api/user'
    listScores: '/api/score'
    showImage: (userId) =>
        @authPrefix + '/show_image/' + userId + '.jpg'
    whoAmI: @authPrefix + '/whoami'
    logOut: @authPrefix + '/logout'
    logIn: (provider) =>
        @authPrefix + '/auth/' + provider + '/login'

# http://vyazici.blogspot.se/2012/09/angularjs-authentication-service.html
anonUser = ->
    is_anon: true
    display_name: null
    display_slug: null
    id: 0

mod.factory 'User', (Urls) ->
    @data = anonUser()
    getUser: => @data
    init: (cb) =>
        $.get Urls.whoAmI, {}, (data) =>
            @data = data
            @data.id = parseInt @data.id
            cb()
    logout: (cb) =>
        if not @isAnon
            $.post Urls.logOut, {}, (data) =>
                @data = anonUser()
                cb()

            
