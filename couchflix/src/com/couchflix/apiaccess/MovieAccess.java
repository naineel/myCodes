package com.couchflix.apiaccess;

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
import com.couchflix.entity.Cast;
import com.couchflix.entity.Company;
import com.couchflix.entity.Crew;
import com.couchflix.entity.Genre;
import com.couchflix.entity.Media;
import com.couchflix.entity.Media_Company;
import com.couchflix.entity.Media_Genre;
import com.couchflix.entity.Movie;
import com.couchflix.entity.Status;
import com.couchflix.manager.CastManager;
import com.couchflix.manager.CompanyManager;
import com.couchflix.manager.CrewManager;
import com.couchflix.manager.GenreManager;
import com.couchflix.manager.MediaCompanyManager;
import com.couchflix.manager.MediaGenreManager;
import com.couchflix.manager.MediaManager;
import com.couchflix.manager.MovieManager;
import com.couchflix.manager.StatusManager;

public class MovieAccess {

	public Movie getMovieById(int id) {
		try {
			Client client = ClientBuilder.newClient();
			Response response = client.target(Globals.API_LINK)
					.path("/movie/" + id)
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject movie = (JSONObject) parser.parse(response
					.readEntity(String.class));

			Media newMedia = new Media();
			newMedia.setMoviedb_id(Integer.parseInt(new String(movie.get("id")
					+ "")));

			MediaManager mediaManager = new MediaManager();
			newMedia = mediaManager.createMedia(newMedia);

			Movie newMovie = new Movie();
			newMovie.setBackdrop_path((String) movie.get("backdrop_path"));
			newMovie.setId(newMedia.getId());
			newMovie.setImdb_id((String) movie.get("imdb_id"));
			newMovie.setOverview((String) movie.get("overview"));
			newMovie.setPoster_path((String) movie.get("poster_path"));
			newMovie.setRelease_date(Utils.stringToDate((String) movie
					.get("release_date")));
			newMovie.setStatus_id(getStatusId((String) movie.get("status")));
			newMovie.setTagline((String) movie.get("tagline"));
			newMovie.setTitle((String) movie.get("title"));

			MovieManager movieManager = new MovieManager();
			movieManager.createMovie(newMovie);

			MediaGenreManager mediaGenreManager = new MediaGenreManager();
			JSONArray genres = (JSONArray) movie.get("genres");
			for (int i = 0; i < genres.size(); i++) {
				Media_Genre media_Genre = new Media_Genre();
				media_Genre
						.setGenre_id(getGenreId((String) ((JSONObject) genres
								.get(i)).get("name")));
				media_Genre.setMedia_id(newMedia.getId());
				mediaGenreManager.createGenre(media_Genre);
			}

			MediaCompanyManager mediaCompanyManager = new MediaCompanyManager();
			JSONArray companies = (JSONArray) movie.get("production_companies");
			for (int i = 0; i < companies.size(); i++) {
				Media_Company media_Company = new Media_Company();
				media_Company.setCompany_id(getCompanyId(
						(String) ((JSONObject) companies.get(i)).get("name"),
						(Integer.parseInt(new String(((JSONObject) companies
								.get(i)).get("id") + "")))));
				media_Company.setMedia_id(newMedia.getId());
				mediaCompanyManager.createCompany(media_Company);
			}
			
			getCastAndCrewByMovieId(newMedia.getId(), newMedia.getMoviedb_id());			
			
			return newMovie;
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}
	}

	private void getCastAndCrewByMovieId(Integer mediaId, Integer moviedb_id) {
		
		try {

			Client client = ClientBuilder.newClient();
			Response response = client.target(Globals.API_LINK)
					.path("/movie/" + moviedb_id + "/credits")
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject credits = (JSONObject) parser.parse(response
					.readEntity(String.class));
			
			JSONArray cast = (JSONArray) credits.get("cast");
			JSONArray crew = (JSONArray) credits.get("crew");
			
			CastManager castManager = new CastManager();
			CrewManager crewManager = new CrewManager();
			
			for (int i = 0 ; i < cast.size() ; i++) {
				Cast newCast = new Cast();
				newCast.setCharacter((String)((JSONObject)cast.get(i)).get("character"));
				newCast.setMedia_id(mediaId);
				newCast.setPoster_path((String)((JSONObject)cast.get(i)).get("profile_path"));
				newCast.setPerson_id(Integer.parseInt(new String(((JSONObject)cast.get(i)).get("id") + "")));
				newCast.setName((String)((JSONObject)cast.get(i)).get("name"));
				castManager.createCast(newCast);
			}
			
			for (int i = 0 ; i < crew.size() ; i++) {
				Crew newCrew = new Crew();
				newCrew.setDepartment((String)((JSONObject)crew.get(i)).get("department"));
				newCrew.setMedia_id(mediaId);
				newCrew.setPoster_path((String)((JSONObject)crew.get(i)).get("profile_path"));
				newCrew.setPerson_id(Integer.parseInt(new String(((JSONObject)crew.get(i)).get("id") + "")));
				newCrew.setName((String)((JSONObject)crew.get(i)).get("name"));
				newCrew.setJob((String)((JSONObject)crew.get(i)).get("job"));
				crewManager.createCrew(newCrew);
			}
			
			
			System.out.println(credits.toJSONString());

		} catch (ParseException e) {
			e.printStackTrace();
		}
		
	}

	private int getStatusId(String statusString) {
		int statusId = 0;

		StatusManager statusManager = new StatusManager();
		List<Status> allStatus = statusManager.readAllStatus();
		for (Status status : allStatus) {
			if (status.getStatus().equals(statusString)) {
				statusId = status.getId();
				break;
			}
		}

		if (statusId == 0) {
			Status status = new Status();
			status.setStatus(statusString);
			status = statusManager.createStatus(status);
			statusId = status.getId();
		}
		return statusId;
	}

	private int getGenreId(String genreString) {
		int genreId = 0;

		GenreManager genreManager = new GenreManager();
		List<Genre> allGenre = genreManager.readAllGenre();
		for (Genre genre : allGenre) {
			if (genre.getGenre().equals(genreString)) {
				genreId = genre.getId();
				break;
			}
		}

		if (genreId == 0) {
			Genre genre = new Genre();
			genre.setGenre(genreString);
			genre = genreManager.createGenre(genre);
			genreId = genre.getId();
		}
		return genreId;
	}

	private int getCompanyId(String companyString, int moviedbCompanyId) {
		int companyId = 0;

		CompanyManager companyManager = new CompanyManager();
		List<Company> allCompany = companyManager.readAllCompany();
		for (Company company : allCompany) {
			if (company.getName().equals(companyString)) {
				companyId = company.getId();
				break;
			}
		}

		if (companyId == 0) {
			companyId = getCompanyById(moviedbCompanyId);
		}
		return companyId;
	}

	private int getCompanyById(int moviedbCompanyId) {

		int companyId = 0;

		try {

			Client client = ClientBuilder.newClient();
			Response response = client.target(Globals.API_LINK)
					.path("/company/" + moviedbCompanyId)
					.queryParam("api_key", Globals.API_KEY)
					.request(MediaType.TEXT_PLAIN_TYPE)
					.header("Accept", "application/json").get();

			JSONParser parser = new JSONParser();
			JSONObject company = (JSONObject) parser.parse(response
					.readEntity(String.class));

			CompanyManager companyManager = new CompanyManager();
			Company newCompany = new Company();
			newCompany.setDescription((String) company.get("description"));
			newCompany.setHeadquaters((String) company.get("headquaters"));
			newCompany.setHomepage((String) company.get("homepage"));
			newCompany.setLogo_path((String) company.get("logo_path"));
			newCompany.setName((String) company.get("name"));

			newCompany = companyManager.createCompany(newCompany);

			companyId = newCompany.getId();

		} catch (ParseException e) {
			e.printStackTrace();
		}
		return companyId;
	}

	public static void main(String args[]) {
		MovieAccess movieAccess = new MovieAccess();
		movieAccess.getMovieById(550);
	}

}
