mod = angular.module('vvmServices', ['ngResource'])

# http://vyazici.blogspot.se/2012/09/angularjs-authentication-service.html
mod.factory 'User', ->
    @isAnon = true
    @email = null
    @id = 0
    # Getter methods really needed?
    isAnon: => @isAnon
    getId: => @id
    getEmail: => @email
    init: (scope) =>
        $.get '/whoami', {}, (data) =>
            scope.$apply =>
                console.log data
                @email = data.email
                @id = parseInt data.id
                @isAnon = data.isAnon
    login: (email, password, scope) =>
        $.post '/login', {email: email, password: password}, (data) =>
            if data.success
                @isAnon = false
                @email = email
                @id = 33
            scope.$apply -> null
    logout: (scope) =>
        if @email != 'okänd'
            $.post '/logout', {}, (data) =>
                @email = data.email
                @isAnon = true
                @id = 0
                scope.$apply -> null

