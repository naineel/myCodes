package com.couchflix.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;

@Entity
public class Media_Genre {
	
	@Id
	@SequenceGenerator( name = "mediaGenreId", sequenceName = "MEDIA_GENRE_ID", allocationSize = 1, initialValue = 1 )
	@GeneratedValue(strategy=GenerationType.IDENTITY, generator="mediaGenreId")
	private int id;
	private int media_id;
	private int genre_id;
	
	public Media_Genre() {
		super();
	}

	public Media_Genre(int id, int media_id, int genre_id) {
		super();
		this.id = id;
		this.media_id = media_id;
		this.genre_id = genre_id;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getMedia_id() {
		return media_id;
	}

	public void setMedia_id(int media_id) {
		this.media_id = media_id;
	}

	public int getGenre_id() {
		return genre_id;
	}

	public void setGenre_id(int genre_id) {
		this.genre_id = genre_id;
	}
	
}
