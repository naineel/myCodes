package com.couchflix.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;

@Entity
public class User_list {
	@Id
	@SequenceGenerator( name = "userListId", sequenceName = "USERLIST_ID", allocationSize = 1, initialValue = 1 )
	@GeneratedValue(strategy=GenerationType.IDENTITY, generator="userListId")
	private Integer id;
	private String user_email;
	private Integer media_id;
	private String list_value;
	
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
	public Integer getMedia_id() {
		return media_id;
	}
	public void setMedia_id(Integer media_id) {
		this.media_id = media_id;
	}
	public String getList_value() {
		return list_value;
	}
	public void setList_value(String list_value) {
		this.list_value = list_value;
	}
	public User_list(Integer id, String user_email, Integer media_id,
			String list_value) {
		super();
		this.id = id;
		this.user_email = user_email;
		this.media_id = media_id;
		this.list_value = list_value;
	}
	public User_list() {
		super();
	}
	
	
}
