mod = angular.module('vvmServices', [])

# http://vyazici.blogspot.se/2012/09/angularjs-authentication-service.html
mod.factory 'User', ->
    @data = {is_anon: true, display_name: null, id: 0}
    getUser: => @data
    init: (scope) =>
        $.get '/whoami', {}, (data) =>
            @data = data
            @data.id = parseInt @data.id
            scope.$apply()
    logout: (scope, cb) =>
        if not @isAnon
            $.post '/logout', {}, (data) =>
                @data = {is_anon: true, display_name: null, id: 0}
                cb()
                scope.$apply()

