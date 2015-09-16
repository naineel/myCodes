package com.couchflix.entity;

import java.util.Date;

public class Discover {

	private int id;
	private String title;
	private String poster_path;
	private String backdrop_path;
	private Date releaseDate;
	private String type;

	public Discover() {
		super();
	}

	public Discover(int id, String title, String poster_path,
			String backdrop_path, Date releaseDate, String type) {
		super();
		this.id = id;
		this.title = title;
		this.poster_path = poster_path;
		this.backdrop_path = backdrop_path;
		this.releaseDate = releaseDate;
		this.type = type;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getPoster_path() {
		return poster_path;
	}

	public void setPoster_path(String poster_path) {
		this.poster_path = poster_path;
	}

	public String getBackdrop_path() {
		return backdrop_path;
	}

	public void setBackdrop_path(String backdrop_path) {
		this.backdrop_path = backdrop_path;
	}

	public Date getReleaseDate() {
		return releaseDate;
	}

	public void setReleaseDate(Date releaseDate) {
		this.releaseDate = releaseDate;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

}
