package com.couchflix.entity;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
public class TV {

	@Id
	private int id;
	private String backdrop_path;
	@Temporal(TemporalType.DATE)
	private Date first_air_date;
	private String homepage;
	@Temporal(TemporalType.DATE)
	private Date last_air_date;
	private int number_of_episodes;
	private int number_of_seasons;
	private String name;
	private String overview;
	private String poster_path;
	private int status_id;


	public TV() {
		super();
	}

	public TV(int id, String backdrop_path, Date first_air_date,
			String homepage, Date last_air_date, int number_of_episodes,
			int number_of_seasons, String name, String overview,
			String poster_path, int status_id) {
		super();
		this.id = id;
		this.backdrop_path = backdrop_path;
		this.first_air_date = first_air_date;
		this.homepage = homepage;
		this.last_air_date = last_air_date;
		this.number_of_episodes = number_of_episodes;
		this.number_of_seasons = number_of_seasons;
		this.name = name;
		this.overview = overview;
		this.poster_path = poster_path;
		this.status_id = status_id;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getBackdrop_path() {
		return backdrop_path;
	}

	public void setBackdrop_path(String backdrop_path) {
		this.backdrop_path = backdrop_path;
	}

	public Date getFirst_air_date() {
		return first_air_date;
	}

	public void setFirst_air_date(Date first_air_date) {
		this.first_air_date = first_air_date;
	}

	public String getHomepage() {
		return homepage;
	}

	public void setHomepage(String homepage) {
		this.homepage = homepage;
	}

	public Date getLast_air_date() {
		return last_air_date;
	}

	public void setLast_air_date(Date last_air_date) {
		this.last_air_date = last_air_date;
	}

	public int getNumber_of_episodes() {
		return number_of_episodes;
	}

	public void setNumber_of_episodes(int number_of_episodes) {
		this.number_of_episodes = number_of_episodes;
	}

	public int getNumber_of_seasons() {
		return number_of_seasons;
	}

	public void setNumber_of_seasons(int number_of_seasons) {
		this.number_of_seasons = number_of_seasons;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getOverview() {
		return overview;
	}

	public void setOverview(String overview) {
		this.overview = overview;
	}

	public String getPoster_path() {
		return poster_path;
	}

	public void setPoster_path(String poster_path) {
		this.poster_path = poster_path;
	}

	public int getStatus_id() {
		return status_id;
	}

	public void setStatus_id(int status_id) {
		this.status_id = status_id;
	}


}
