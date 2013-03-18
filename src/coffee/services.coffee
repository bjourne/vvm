mod = angular.module('vvm.services', [])

# http://vyazici.blogspot.se/2012/09/angularjs-authentication-service.html
mod.factory 'User', ->
    @data = {is_anon: true, display_name: null, id: 0}
    getUser: => @data
    init: (cb) =>
        $.get '/whoami', {}, (data) =>
            @data = data
            @data.id = parseInt @data.id
            cb()
    logout: (cb) =>
        if not @isAnon
            $.post '/logout', {}, (data) =>
                @data = {is_anon: true, display_name: null, id: 0}
                cb()

