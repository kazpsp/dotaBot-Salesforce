public class OpenDotaAPI {
	private static final String ENDPOINT = 'https://api.opendota.com/api/players/6410004/recentMatches';

	public static void getRecentMatchesAndUpsert() {
		HttpResponse response = getRecentMatches();
		if (response != null && response.getStatusCode() == 200) {
			List<MatchObject> matches = (List<MatchObject>) JSON.deserialize(response.getBody(), List<MatchObject>.class);
			upsertMatchRecords(matches);
		}
	}

	public static HttpResponse getRecentMatches() {
		Http http = new Http();
		HttpRequest request = new HttpRequest();

		request.setEndpoint(ENDPOINT);
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

	private static HttpResponse getMatchDetails(Decimal matchId) {
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


	private static void upsertMatchRecords(List<MatchObject> matches) {
		List<Match__c> recordsToUpsert = new List<Match__c>();

		for (MatchObject mo : matches) {
			Match__c match = new Match__c();
			match.Match_id__c = String.valueOf(mo.match_id);
			match.Name = String.valueOf(mo.match_id);

			recordsToUpsert.add(match);
		}

		try {
			upsert recordsToUpsert Match_id__c;
		} catch (DmlException e) {
			System.debug('Error upserting matches: ' + e.getMessage());
		}
	}
}
