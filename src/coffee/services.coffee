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
mod.factory 'User', (Urls) ->
    @data = {is_anon: true, display_name: null, id: 0}
    getUser: => @data
    init: (cb) =>
        $.get Urls.whoAmI, {}, (data) =>
            @data = data
            @data.id = parseInt @data.id
            cb()
    logout: (cb) =>
        if not @isAnon
            $.post Urls.logOut, {}, (data) =>
                @data = {is_anon: true, display_name: null, id: 0}
                cb()

            
