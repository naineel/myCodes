package com.couchflix.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;

@Entity
public class Ratings {
	@Id
	@SequenceGenerator( name = "ratingId", sequenceName = "RATING_ID", allocationSize = 1, initialValue = 1 )
	@GeneratedValue(strategy=GenerationType.IDENTITY, generator="ratingId")
	private Integer id;
	private String user_email;
	private Integer user_rating;
	private Integer media_id;
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getUser_email() {
		return user_email;
	}
	public void setUser_email(String user_email) {
		this.user_email = user_email;
	}
	public Integer getUser_rating() {
		return user_rating;
	}
	public void setUser_rating(Integer user_rating) {
		this.user_rating = user_rating;
	}
	public Integer getMedia_id() {
		return media_id;
	}
	public void setMedia_id(Integer media_id) {
		this.media_id = media_id;
	}
	public Ratings(Integer id, String user_email, Integer user_rating,
			Integer media_id) {
		super();
		this.id = id;
		this.user_email = user_email;
		this.user_rating = user_rating;
		this.media_id = media_id;
	}
	public Ratings() {
		super();
	}
	
	
}
