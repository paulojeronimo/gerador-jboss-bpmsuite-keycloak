(function() {
    var app = angular.module('myapp', ['ngRoute']);

    app.controller('ProductController', function($scope, $http, keycloakLauncher,initService) {

        $scope.loggedIn = initService.isLoggedIn();
        $scope.user = initService.getUserInfo();

        $scope.products = [];
        $scope.reloadData = function() {
        	$http.get("/myapp-backend/products").success(function(data) {
                $scope.products = angular.fromJson(data);

            });
        };

        $scope.logout = function(){
            console.log('*** LOGOUT');
            keycloakLauncher.loggedIn = false;
            keycloakLauncher.keycloak = null;
            window.location = keycloakLauncher.logoutUrl;
        };
        $scope.login = function () {
            console.log('*** LOGIN');
            keycloakLauncher.keycloak.login();
        };

    });

    app.provider('keycloakLauncher', function keycloakLauncherProvider() {
        this.keycloak = {};
        this.loggedIn = false;
        this.logoutUrl = "/auth/realms/myapp/tokens/logout?redirect_uri=/myapp-frontend";

        this.$get =  function () {
            var keycloak = this.keycloak;
            var loggedIn = this.loggedIn;
            return {
                keycloak: keycloak,
                loggedIn: loggedIn,
                logoutUrl: this.logoutUrl
            };
        };
    });

    app.factory('authInterceptor', function($q, keycloakLauncher) {
        return {
            request: function (config) {
                var deferred = $q.defer();
                var keycloak = keycloakLauncher.keycloak;
                console.log("authint", keycloakLauncher.loggedIn);
                if (keycloak.token) {
                    keycloak.updateToken(5).success(function() {
                        config.headers = config.headers || {};
                        config.headers.Authorization = 'Bearer ' + keycloak.token;

                        deferred.resolve(config);
                    }).error(function() {
                        deferred.reject('Failed to refresh token');
                    });
                }else{
                    return config;
                }
                return deferred.promise;
            }
        };
    });

    app.factory('errorInterceptor', function($q) {
        return function(promise) {
            return promise.then(function(response) {
                return response;
            }, function(response) {
                if (response.status == 401) {
                    console.log('session timeout?');
                    logout();
                } else if (response.status == 403) {
                    alert("Forbidden");
                } else if (response.status == 404) {
                    alert("Not found");
                } else if (response.status) {
                    if (response.data && response.data.errorMessage) {
                        alert(response.data.errorMessage);
                    } else {
                        alert("An unexpected server error has occurred");
                    }
                }
                return $q.reject(response);
            });
        };
    });

    app.config(function($httpProvider, $routeProvider, keycloakLauncherProvider,$locationProvider) {
        keycloakLauncherProvider.keycloak = new Keycloak('keycloak.json');
        $httpProvider.interceptors.push('errorInterceptor');
        $httpProvider.interceptors.push('authInterceptor');
        $routeProvider.when('/', {
                controller: 'ProductController',
                templateUrl: 'partials/products.htm',
                resolve: {
                    init: ['initService', function(init) {
                        console.log("initservice xxxx",init.promise);
                        return init.promise;
                    }]
                }
            });
    });


    app.run(['keycloakLauncher','initService',function(keycloakLauncher,init) {
        console.log("runner");
        var user = {};
        keycloakLauncher.keycloak.init({ onLoad: 'check-sso' }).success(function () {
            console.log("entro");
            keycloakLauncher.loggedIn = keycloakLauncher.keycloak.authenticated;
            console.log("run login", keycloakLauncher.loggedIn);
            init.setLoggedIn(keycloakLauncher.keycloak.authenticated);

            if(keycloakLauncher.keycloak.authenticated) {
                user.email = keycloakLauncher.keycloak.idTokenParsed.email;
            }else{
                user.email = "Anonymous"
            }
            init.setUserInfo(user)
            init.defer.resolve();
        }).error(function () {
            window.location.reload();
            init.defer.reject('Failed to Init KC');
        });

    }]);

    app.service('initService', ['$q', function ($q) {
        var d = $q.defer();
        var loggedIn = false;
        var userInfo = {};

        return {
            defer: d,
            promise: d.promise,
            setLoggedIn: function (logged) {
                loggedIn = logged;
            },
            isLoggedIn: function () {
                return loggedIn;
            },
            setUserInfo: function (user) {
                userInfo = user;
            },
            getUserInfo: function () {
                return userInfo;
            }
        };
    }]);

})();
