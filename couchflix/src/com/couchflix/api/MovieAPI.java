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
import com.couchflix.apiaccess.MovieAccess;
import com.couchflix.entity.Discover;
import com.couchflix.entity.Movie;
import com.couchflix.manager.MovieManager;

@Path("/movie")
public class MovieAPI {

	@GET
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Movie getMovieByMovieDBId(@PathParam("id") int movieDBId) {

		MovieManager manager = new MovieManager();
		Movie movie = manager.readMovieByMovieDBId(movieDBId);

		if (movie == null) {
			MovieAccess movieAccess = new MovieAccess();
			movie = movieAccess.getMovieById(movieDBId);
		}

		return movie;
	}

	public List<Discover> getMostPopularMovies() {

		try {

			List<Discover> mostPopularMovies = new ArrayList<>();

			Client client = ClientBuilder.newClient();
			Response response = client.target(Globals.API_LINK)
					.path("/discover/movie")
					.queryParam("sort_by", "popularity.desc")
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject discover = (JSONObject) parser.parse(response
					.readEntity(String.class));
			JSONArray discoverArray = (JSONArray) discover.get("results");
			for (int i = 0; i < discoverArray.size(); i++) {
				Discover discoverMovie = new Discover();
				discoverMovie.setId(Integer.parseInt(new String(
						((JSONObject) discoverArray.get(i)).get("id") + "")));
				discoverMovie
						.setBackdrop_path((String) ((JSONObject) discoverArray
								.get(i)).get("backdrop_path"));
				discoverMovie
						.setPoster_path((String) ((JSONObject) discoverArray
								.get(i)).get("poster_path"));
				discoverMovie.setTitle((String) ((JSONObject) discoverArray
						.get(i)).get("title"));
				discoverMovie.setReleaseDate(Utils
						.stringToDate((String) ((JSONObject) discoverArray
								.get(i)).get("release_date")));
				mostPopularMovies.add(discoverMovie);
			}
			return mostPopularMovies;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}

	public List<Discover> getRecentReleases() {
		try {

			List<Discover> mostPopularMovies = new ArrayList<>();
			
			Date today = new Date();
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(today);
			calendar.add(Calendar.DAY_OF_MONTH, -30);
			Date lastMonth = new Date();
			lastMonth.setTime(calendar.getTime().getTime());
			Client client = ClientBuilder.newClient();
			Response response = client.target(Globals.API_LINK)
					.path("/discover/movie")
					.queryParam("sort_by", "popularity.desc")
					.queryParam("primary_release_date.gte",Utils.dateToString(lastMonth))
					.queryParam("primary_release_date.lte", Utils.dateToString(today))
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject discover = (JSONObject) parser.parse(response
					.readEntity(String.class));
			JSONArray discoverArray = (JSONArray) discover.get("results");
			for (int i = 0; i < discoverArray.size(); i++) {
				Discover discoverMovie = new Discover();
				discoverMovie.setId(Integer.parseInt(new String(
						((JSONObject) discoverArray.get(i)).get("id") + "")));
				discoverMovie
						.setBackdrop_path((String) ((JSONObject) discoverArray
								.get(i)).get("backdrop_path"));
				discoverMovie
						.setPoster_path((String) ((JSONObject) discoverArray
								.get(i)).get("poster_path"));
				discoverMovie.setTitle((String) ((JSONObject) discoverArray
						.get(i)).get("title"));
				discoverMovie.setReleaseDate(Utils
						.stringToDate((String) ((JSONObject) discoverArray
								.get(i)).get("release_date")));
				mostPopularMovies.add(discoverMovie);
			}
			return mostPopularMovies;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public List<Discover> getComingSoon() {
		try {

			List<Discover> mostPopularMovies = new ArrayList<>();
			
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
					.path("/discover/movie")
					.queryParam("sort_by", "popularity.desc")
					.queryParam("primary_release_date.gte",Utils.dateToString(today))
					.queryParam("primary_release_date.lte", Utils.dateToString(fiveMonths))
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject discover = (JSONObject) parser.parse(response
					.readEntity(String.class));
			JSONArray discoverArray = (JSONArray) discover.get("results");
			for (int i = 0; i < discoverArray.size(); i++) {
				Discover discoverMovie = new Discover();
				discoverMovie.setId(Integer.parseInt(new String(
						((JSONObject) discoverArray.get(i)).get("id") + "")));
				discoverMovie
						.setBackdrop_path((String) ((JSONObject) discoverArray
								.get(i)).get("backdrop_path"));
				discoverMovie
						.setPoster_path((String) ((JSONObject) discoverArray
								.get(i)).get("poster_path"));
				discoverMovie.setTitle((String) ((JSONObject) discoverArray
						.get(i)).get("title"));
				discoverMovie.setReleaseDate(Utils
						.stringToDate((String) ((JSONObject) discoverArray
								.get(i)).get("release_date")));
				mostPopularMovies.add(discoverMovie);
			}
			return mostPopularMovies;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}
}
