'use strict'

tcApp.controller("accountCtrl", function($scope, $resource, Account, $location) {
	// Default states
	$scope.shown = false
	$scope.sending = false
	$scope.withdraw = {}

	Account.get("/", function(account) {
		$scope.account = account
		$scope.shown = true
		$scope.submitWithdraw = function() {

			$scope.sending = true
			account.$withdraw({
				toAddress: $scope.withdraw.toAddress,
				withdrawAmount: $scope.withdraw.amount,
			}, function(response) {
				$scope.sending = false
				$scope.withdrawFailed = false
				$scope.account = response
			}, function(error) {
				console.log(error)
				$scope.sending = false
				$scope.withdrawFailed = true
			})
		}
	}, function(error) {
		$location.path("/")
	})
})
