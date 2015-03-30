package edu.neu.cs5200.msn.ds.entity;

public class Cast {
	private int castId;
	private String characterName;
	private int actorId;
	private int movieId;
	
	public int getCastId() {
		return castId;
	}
	
	public void setCastId(int castId) {
		this.castId = castId;
	}
	
	public String getCharacterName() {
		return characterName;
	}
	
	public void setCharacterName(String characterName) {
		this.characterName = characterName;
	}
	
	public int getActorId() {
		return actorId;
	}
	
	public void setActorId(int actorId) {
		this.actorId = actorId;
	}
	
	public int getMovieId() {
		return movieId;
	}
	
	public void setMovieId(int movieId) {
		this.movieId = movieId;
	}
	
	public Cast(int castId, String characterName, int actorId, int movieId) {
		super();
		this.castId = castId;
		this.characterName = characterName;
		this.actorId = actorId;
		this.movieId = movieId;
	}
	
	public Cast() {
		super();
	}
	
}
