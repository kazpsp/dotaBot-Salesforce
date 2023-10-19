@RestResource(urlMapping='/playerAPI/*')
global with sharing class playerAPI {
	@HttpPost
	global static String createPlayer(String name, String notes) {
		Player__c newPlayer = new Player__c(
				Name = name,
				Notes__c = notes
		);

		insert newPlayer;
		return newPlayer.Id;
	}

	@httpGet
	global static Player__c  getPlayer() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String playerName = req.params.get('player_name');
		system.debug('playerName: ' + playerName);
		List<Player__c> players = [SELECT Id, Name, Notes__c FROM Player__c WHERE Name = :playerName];
		if(players.size()>0) {
			return players[0];
		}
		return null;
	}
}