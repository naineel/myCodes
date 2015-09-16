package com.couchflix.entity;

import java.sql.Timestamp;
import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
public class Comments {
	
	@Id
	@SequenceGenerator( name = "commentId", sequenceName = "COMMENT_ID", allocationSize = 1, initialValue = 1 )
	@GeneratedValue(strategy=GenerationType.IDENTITY, generator="commentId")
	private Integer id;
	private String user_comment;
	@Temporal(TemporalType.TIMESTAMP)
	private Date user_time;
	private Integer comment_flag;
	private String user_email;
	private Integer media_id;
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getUser_comment() {
		return user_comment;
	}
	public void setUser_comment(String user_comment) {
		this.user_comment = user_comment;
	}
	public Date getUser_time() {
		return user_time;
	}
	public void setUser_time(Timestamp user_time) {
		this.user_time = user_time;
	}
	public Integer getComment_flag() {
		return comment_flag;
	}
	public void setComment_flag(Integer comment_flag) {
		this.comment_flag = comment_flag;
	}
	public String getUser_email() {
		return user_email;
	}
	public void setUser_email(String user_email) {
		this.user_email = user_email;
	}
	
	public void setUser_time(Date user_time) {
		this.user_time = user_time;
	}

	public Comments() {
		super();
	}
	public Integer getMedia_id() {
		return media_id;
	}
	public void setMedia_id(Integer media_id) {
		this.media_id = media_id;
	}
	public Comments(Integer id, String user_comment, Date user_time,
			Integer comment_flag, String user_email, Integer media_id) {
		super();
		this.id = id;
		this.user_comment = user_comment;
		this.user_time = user_time;
		this.comment_flag = comment_flag;
		this.user_email = user_email;
		this.media_id = media_id;
	}
	
}
