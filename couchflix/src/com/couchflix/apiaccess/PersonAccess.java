package com.couchflix.apiaccess;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import com.couchflix.Globals;
import com.couchflix.Utils;
import com.couchflix.entity.Person;

public class PersonAccess {

	public Person getPersonById(int id) {
		try {
			Client client = ClientBuilder.newClient();
			Response response = client.target(Globals.API_LINK)
					.path("/person/" + id)
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject person = (JSONObject) parser.parse(response
					.readEntity(String.class));

			Person newPerson = new Person();
			newPerson
					.setId(Integer.parseInt(new String(person.get("id") + "")));
			newPerson.setBiography((String) person.get("biography"));
			if (!(person.get("birthday") == null)) {
				if (!(person.get("birthday").equals(""))) {
					newPerson.setBirthday(Utils.stringToDate((String) person
							.get("birthday")));
				}
			}
			if (!(person.get("deathday") == null)) {
				if (!(person.get("deathday").equals(""))) {
					newPerson.setDeathday(Utils.stringToDate((String) person
							.get("deathday")));
				}
			}
			newPerson.setHomepage((String) person.get("homepage"));
			newPerson.setName((String) person.get("name"));
			newPerson.setPlace_of_birth((String) person.get("place_of_birth"));
			newPerson.setProfile_path((String) person.get("profile_path"));

			return newPerson;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}

}
