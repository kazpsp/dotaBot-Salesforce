@RestResource(urlMapping='/guildAPI/*')
global with sharing class GuildAPI {

	@HttpPatch
	global static String updateGuild(String name, String description) {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		Guild__c guildToUpdate = [SELECT Id FROM Guild__c WHERE Name = :name LIMIT 1];

		if (guildToUpdate != null) {
			guildToUpdate.Description__c = description;
			update guildToUpdate;
			return guildToUpdate.Id;
		} else {
			res.statusCode = 404;
			return 'Guild not found';
		}
	}

	@HttpPost
	global static String createGuild(String name, String description) {
		Guild__c newGuild = new Guild__c(
				Name = name,
				Description__c = description
		);

		insert newGuild;
		return newGuild.Id;
	}

	@httpGet
	global static Guild__c  getGuild() {
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		String guild_name = req.params.get('guild_name');
		system.debug('guild_name: ' + guild_name);
		List<Guild__c> guilds = [SELECT Id, Name, Description__c FROM Guild__c WHERE Name = :guild_name];
		if(guilds.size()>0) {
			return guilds[0];
		}
		return null;
	}
}
