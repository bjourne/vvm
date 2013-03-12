mod = angular.module('vvmServices', [])

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
            @email = data.email
            @id = parseInt data.id
            @isAnon = data.isAnon
            scope.$apply()
    login: (email, password, scope, cb) =>
        $.post '/login', {email: email, password: password}, (data) =>
            if data.email
                @isAnon = false
                @email = data.email
                @id = data.id
            cb()
            scope.$apply()
    logout: (scope, cb) =>
        if @email != 'okänd'
            $.post '/logout', {}, (data) =>
                @email = data.email
                @isAnon = true
                @id = 0
                cb()
                scope.$apply()

