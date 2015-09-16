package com.couchflix.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;

@Entity
public class Cast {
	
	@Id
	@SequenceGenerator( name = "castId", sequenceName = "CAST_ID", allocationSize = 1, initialValue = 1 )
	@GeneratedValue(strategy=GenerationType.IDENTITY, generator="castId")
	private int id;
	private int person_id;
	private int media_id;
	@Column(name="`character`")
	private String character;
	private String poster_path;
	@Column(name="`name`")
	private String name;

	public Cast() {
		super();
	}

	public Cast(int id, int person_id, int media_id, String character,
			String poster_path, String name) {
		super();
		this.id = id;
		this.person_id = person_id;
		this.media_id = media_id;
		this.character = character;
		this.poster_path = poster_path;
		this.name = name;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getPerson_id() {
		return person_id;
	}

	public void setPerson_id(int person_id) {
		this.person_id = person_id;
	}

	public int getMedia_id() {
		return media_id;
	}

	public void setMedia_id(int media_id) {
		this.media_id = media_id;
	}

	public String getCharacter() {
		return character;
	}

	public void setCharacter(String character) {
		this.character = character;
	}

	public String getPoster_path() {
		return poster_path;
	}

	public void setPoster_path(String poster_path) {
		this.poster_path = poster_path;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

}
