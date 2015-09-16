
package com.couchflix.entity;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
public class Follows {

	@Id
	private int id;
	private String user_email;
	private String follow_email;
	
	public Follows() {
		super();
	}
	
	public Follows(int id, String user_email, String follow_email) {
		super();
		this.id = id;
		this.user_email = user_email;
		this.follow_email = follow_email;
	}
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getUser_email() {
		return user_email;
	}
	public void setUser_email(String user_email) {
		this.user_email = user_email;
	}
	public String getFollow_email() {
		return follow_email;
	}
	public void setFollow_email(String follow_email) {
		this.follow_email = follow_email;
	}
	
}
