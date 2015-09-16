package com.couchflix.entity;

import java.util.Date;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
public class Movie {

	@Id
	private int id;
	private String backdrop_path;
	private String imdb_id;
	private String overview;
	private String poster_path;
	@Temporal(TemporalType.DATE)
	private Date release_date;
	private int status_id;
	private String tagline;
	private String title;

	public Movie() {
		super();
	}

	public Movie(int id, String backdrop_path, String imdb_id, String overview,
			String poster_path, Date release_date, int status_id,
			String tagline, String title) {
		super();
		this.id = id;
		this.backdrop_path = backdrop_path;
		this.imdb_id = imdb_id;
		this.overview = overview;
		this.poster_path = poster_path;
		this.release_date = release_date;
		this.status_id = status_id;
		this.tagline = tagline;
		this.title = title;
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

	public String getImdb_id() {
		return imdb_id;
	}

	public void setImdb_id(String imdb_id) {
		this.imdb_id = imdb_id;
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

	public Date getRelease_date() {
		return release_date;
	}

	public void setRelease_date(Date release_date) {
		this.release_date = release_date;
	}

	public int getStatus_id() {
		return status_id;
	}

	public void setStatus_id(int status_id) {
		this.status_id = status_id;
	}

	public String getTagline() {
		return tagline;
	}

	public void setTagline(String tagline) {
		this.tagline = tagline;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}


}
