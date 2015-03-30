package edu.neu.cs5200.msn.ds.entity;

import java.sql.Date;

public class Comment {
	private int commentId;
	private String comment;
	private Date date;
	private String username;
	private int movieId;
	
	public int getCommentId() {
		return commentId;
	}
	
	public void setCommentId(int commentId) {
		this.commentId = commentId;
	}
	
	public String getComment() {
		return comment;
	}
	
	public void setComment(String comment) {
		this.comment = comment;
	}
	
	public Date getDate() {
		return date;
	}
	
	public void setDate(Date date) {
		this.date = date;
	}
	
	public String getUsername() {
		return username;
	}
	
	public void setUsername(String username) {
		this.username = username;
	}
	
	public int getMovieId() {
		return movieId;
	}
	
	public void setMovieId(int movieId) {
		this.movieId = movieId;
	}
	
	public Comment(int commentId, String comment, Date date, String username,
			int movieId) {
		super();
		this.commentId = commentId;
		this.comment = comment;
		this.date = date;
		this.username = username;
		this.movieId = movieId;
	}
	
	public Comment() {
		super();
	}
	
	
}
