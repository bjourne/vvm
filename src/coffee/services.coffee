angular.module('vvmServices', ['ngResource'])
    .factory 'Score', ($resource) ->
        $resource('tjaba')
