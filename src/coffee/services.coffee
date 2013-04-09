mod = angular.module('vvm.services', [])

mod.factory 'Urls', ->
    @urlPrefix = '/users'
    showImage: (userId) =>
        @urlPrefix + '/show_image/' + userId + '.jpg'
    whoAmI: @urlPrefix + '/whoami'
    logOut: @urlPrefix + '/logout'
    logIn: (provider) =>
        @urlPrefix + '/auth/' + provider + '/login'

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

            
