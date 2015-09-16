package com.couchflix.apiaccess;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

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
import com.couchflix.entity.Discover;

public class MediaAccess {

	public List<Discover> search(String query) {
		if (!query.equals("")) {
			try {
				System.out.println("Query - " + query);
				List<Discover> searchResult = new ArrayList<>();

				Client client = ClientBuilder.newClient();
				Response response = null;
				try {
					response = client
							.target(Globals.API_LINK)
							.path("/search/multi")
							.queryParam("api_key", Globals.API_KEY)
							.queryParam("query",
									URLEncoder.encode(query, "UTF-8"))
							.request(MediaType.TEXT_PLAIN_TYPE)
							.header("Accept", "application/json").get();
				} catch (UnsupportedEncodingException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				JSONParser parser = new JSONParser();
				JSONObject searchObject = (JSONObject) parser.parse(response
						.readEntity(String.class));
				System.out.println(searchObject.toString());
				JSONArray searchArray = (JSONArray) searchObject.get("results");
				for (int i = 0; i < searchArray.size(); i++) {
					Discover discover = new Discover();
					if (((String) ((JSONObject) searchArray.get(i))
							.get("media_type")).equals("movie")) {

						discover.setId(Integer.parseInt(new String(
								((JSONObject) searchArray.get(i)).get("id")
										+ "")));
						discover.setBackdrop_path((String) ((JSONObject) searchArray
								.get(i)).get("backdrop_path"));
						discover.setPoster_path((String) ((JSONObject) searchArray
								.get(i)).get("poster_path"));
						discover.setTitle((String) ((JSONObject) searchArray
								.get(i)).get("title"));
						if (((String) ((JSONObject) searchArray.get(i))
								.get("release_date")) != null
								&& (!((String) ((JSONObject) searchArray.get(i))
										.get("release_date")).equals("")))
							discover.setReleaseDate(Utils
									.stringToDate((String) ((JSONObject) searchArray
											.get(i)).get("release_date")));
						discover.setType("movie");
					} else if (((String) ((JSONObject) searchArray.get(i))
							.get("media_type")).equals("tv")) {
						discover.setId(Integer.parseInt(new String(
								((JSONObject) searchArray.get(i)).get("id")
										+ "")));
						discover.setBackdrop_path((String) ((JSONObject) searchArray
								.get(i)).get("backdrop_path"));
						discover.setPoster_path((String) ((JSONObject) searchArray
								.get(i)).get("poster_path"));
						discover.setTitle((String) ((JSONObject) searchArray
								.get(i)).get("name"));
						if (((String) ((JSONObject) searchArray.get(i))
								.get("first_air_date")) != null
								&& (!((String) ((JSONObject) searchArray.get(i))
										.get("first_air_date")).equals("")))
							discover.setReleaseDate(Utils
									.stringToDate((String) ((JSONObject) searchArray
											.get(i)).get("first_air_date")));
						discover.setType("tv");
					}

					searchResult.add(discover);
				}
				return searchResult;
			} catch (ParseException e) {
				e.printStackTrace();
				return null;
			}
		} else {
			List<Discover> searchResult = new ArrayList<>();
			return searchResult;
		}
	}

	public static void main(String args[]) {
		MediaAccess access = new MediaAccess();
		access.search("Game");
	}

}
