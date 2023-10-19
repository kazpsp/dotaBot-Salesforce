global class MatchDetailsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	global Database.QueryLocator start(Database.BatchableContext BC) {
		// Query for Match__c records that haven't had the API called yet.
		return Database.getQueryLocator([SELECT Match_id__c FROM Match__c WHERE api_called__c = false]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Match__c> matchesToUpdate = new List<Match__c>();
		List<Player__c> playersToInsert = new List<Player__c>();
		for (sObject s : scope) {
			Match__c matchRecord = (Match__c) s;

			// Make API call
			HttpResponse response = getMatchDetails(matchRecord.Match_id__c);
			PlayerObject players = (PlayerObject) JSON.deserialize(response.getBody(), PlayerObject.class);
			if (response != null && response.getStatusCode() == 200) {
				// Here you can parse the response and update any necessary fields on the Match__c record.
				// For now, we'll just mark the API as called.
				matchRecord.api_called__c = true;
				for(PlayerObject.players player : players.players	){
					Player__c playerRecord = new Player__c();
					playerRecord.Name = player.personaname;
					system.debug('player.account_id: ' + player.account_id);
					playerRecord.Player_Id__c = String.valueOf(player.account_id);
					playerRecord.Last_Match__c = matchRecord.Id;
					if(playerRecord.Player_Id__c != null){
						if(playerRecord.Name == null){
							playerRecord.Name = playerRecord.Player_Id__c;
						}
						playersToInsert.add(playerRecord);
					}

				}

				matchesToUpdate.add(matchRecord);

			}
		}

		if (!matchesToUpdate.isEmpty()) {
			update matchesToUpdate;
		}
		if (!playersToInsert.isEmpty()) {
			upsert playersToInsert Player__c.Player_Id__c;
		}
	}

	global void finish(Database.BatchableContext BC) {
		// This is executed after all batches. You can send notifications or do post-processing here.
	}

	private HttpResponse getMatchDetails(String matchId) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();

		String endpoint = 'https://api.opendota.com/api/matches/' + matchId;
		request.setEndpoint(endpoint);
		request.setMethod('GET');
		request.setTimeout(60000);  // Optional: Set timeout in milliseconds

		try {
			HttpResponse response = http.send(request);
			if (response.getStatusCode() == 200) {
				// Successful callout
				System.debug(response.getBody());
				return response;
			} else {
				System.debug('HTTP callout failed with status ' + response.getStatusCode());
				System.debug(response.getBody());
			}
		} catch (Exception e) {
			System.debug('Exception during callout: ' + e.getMessage());
		}
		return null;
	}
}
