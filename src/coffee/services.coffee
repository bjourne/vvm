mod = angular.module('vvmServices', ['ngResource'])

# http://vyazici.blogspot.se/2012/09/angularjs-authentication-service.html
mod.factory 'User', ->
    @isAnon = true
    @email = null
    # Getter methods really needed?
    isAnon: => @isAnon
    getEmail: => @email
    init: (scope) =>
        $.get '/whoami', {}, (data) =>
            scope.$apply =>
                @email = data.email
                @isAnon = data.isAnon
    login: (email, password, scope) =>
        $.post '/login', {email: email, password: password}, (data) =>
            res = data.success
            if data.success
                @isAnon = false
                @email = email
            scope.$apply -> null

    logout: (scope) =>
        if @email != 'okänd'
            $.post '/logout', {}, (data) =>
                @email = data.email
                @isAnon = true
                scope.$apply -> null

