package com.couchflix.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;

@Entity
public class Media {

	@Id
	@SequenceGenerator( name = "mediaId", sequenceName = "MEDIA_ID", allocationSize = 1, initialValue = 1 )
	@GeneratedValue(strategy=GenerationType.IDENTITY, generator="mediaId")
	private Integer id;
	private Integer moviedb_id;

	public Media() {
		super();
	}

	public Media(Integer id, Integer moviedb_id) {
		super();
		this.id = id;
		this.setMoviedb_id(moviedb_id);
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getMoviedb_id() {
		return moviedb_id;
	}

	public void setMoviedb_id(Integer moviedb_id) {
		this.moviedb_id = moviedb_id;
	}

	

}
