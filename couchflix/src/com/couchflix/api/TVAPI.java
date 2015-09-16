package com.couchflix.api;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import com.couchflix.Globals;
import com.couchflix.Utils;
import com.couchflix.apiaccess.TVAccess;
import com.couchflix.entity.Discover;
import com.couchflix.entity.TV;
import com.couchflix.manager.TVManager;

@Path("/tv")
public class TVAPI {

	@GET
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public TV getTVByMovieDBId(@PathParam("id") int movieDBId) {

		TVManager manager = new TVManager();
		TV tv = manager.readTVByMovieDBId(movieDBId);

		if (tv == null) {
			TVAccess tvAccess = new TVAccess();
			tv = tvAccess.getTVById(movieDBId);
		}

		return tv;
	}

	public List<Discover> getMostPopularTVShows() {

		try {

			List<Discover> mostPopularTVShows = new ArrayList<>();

			Client client = ClientBuilder.newClient();
			Response response = client.target(Globals.API_LINK)
					.path("/discover/tv")
					.queryParam("sort_by", "popularity.desc")
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject discover = (JSONObject) parser.parse(response
					.readEntity(String.class));
			JSONArray discoverArray = (JSONArray) discover.get("results");
			for (int i = 0; i < discoverArray.size(); i++) {
				Discover discoverTV = new Discover();
				discoverTV.setId(Integer.parseInt(new String(
						((JSONObject) discoverArray.get(i)).get("id") + "")));
				discoverTV
						.setBackdrop_path((String) ((JSONObject) discoverArray
								.get(i)).get("backdrop_path"));
				discoverTV.setPoster_path((String) ((JSONObject) discoverArray
						.get(i)).get("poster_path"));
				discoverTV
						.setTitle((String) ((JSONObject) discoverArray.get(i))
								.get("name"));
				discoverTV.setReleaseDate(Utils
						.stringToDate((String) ((JSONObject) discoverArray
								.get(i)).get("first_air_date")));
				mostPopularTVShows.add(discoverTV);
			}
			return mostPopularTVShows;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}

	public List<Discover> getRecentReleases() {

		try {

			List<Discover> mostPopularTVShows = new ArrayList<>();

			Date today = new Date();
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(today);
			calendar.add(Calendar.DAY_OF_MONTH, -90);
			Date last3Month = new Date();
			last3Month.setTime(calendar.getTime().getTime());

			Client client = ClientBuilder.newClient();
			Response response = client.target(Globals.API_LINK)
					.path("/discover/tv")
					.queryParam("sort_by", "popularity.desc")
					.queryParam("first_air_date.gte", last3Month)
					.queryParam("first_air_date.lte", today)
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject discover = (JSONObject) parser.parse(response
					.readEntity(String.class));
			JSONArray discoverArray = (JSONArray) discover.get("results");
			for (int i = 0; i < discoverArray.size(); i++) {
				Discover discoverTV = new Discover();
				discoverTV.setId(Integer.parseInt(new String(
						((JSONObject) discoverArray.get(i)).get("id") + "")));
				discoverTV
						.setBackdrop_path((String) ((JSONObject) discoverArray
								.get(i)).get("backdrop_path"));
				discoverTV.setPoster_path((String) ((JSONObject) discoverArray
						.get(i)).get("poster_path"));
				discoverTV
						.setTitle((String) ((JSONObject) discoverArray.get(i))
								.get("name"));
				discoverTV.setReleaseDate(Utils
						.stringToDate((String) ((JSONObject) discoverArray
								.get(i)).get("first_air_date")));
				mostPopularTVShows.add(discoverTV);
			}
			return mostPopularTVShows;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}

	public List<Discover> getComingSoon() {

		try {

			List<Discover> mostPopularTVShows = new ArrayList<>();

			Date today = new Date();
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(today);
			calendar.add(Calendar.DAY_OF_MONTH, 1);
			today.setTime(calendar.getTime().getTime());
			calendar.add(Calendar.DAY_OF_MONTH, 150);
			Date fiveMonths = new Date();
			fiveMonths.setTime(calendar.getTime().getTime());

			Client client = ClientBuilder.newClient();
			Response response = client.target(Globals.API_LINK)
					.path("/discover/tv")
					.queryParam("sort_by", "popularity.desc")
					.queryParam("first_air_date.gte", today)
					.queryParam("first_air_date.lte", fiveMonths)
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject discover = (JSONObject) parser.parse(response
					.readEntity(String.class));
			JSONArray discoverArray = (JSONArray) discover.get("results");
			for (int i = 0; i < discoverArray.size(); i++) {
				Discover discoverTV = new Discover();
				discoverTV.setId(Integer.parseInt(new String(
						((JSONObject) discoverArray.get(i)).get("id") + "")));
				discoverTV
						.setBackdrop_path((String) ((JSONObject) discoverArray
								.get(i)).get("backdrop_path"));
				discoverTV.setPoster_path((String) ((JSONObject) discoverArray
						.get(i)).get("poster_path"));
				discoverTV
						.setTitle((String) ((JSONObject) discoverArray.get(i))
								.get("name"));
				discoverTV.setReleaseDate(Utils
						.stringToDate((String) ((JSONObject) discoverArray
								.get(i)).get("first_air_date")));
				mostPopularTVShows.add(discoverTV);
			}
			return mostPopularTVShows;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}

}
