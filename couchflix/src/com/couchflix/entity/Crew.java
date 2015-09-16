package com.couchflix.entity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;

@Entity
public class Crew {

	@Id
	@SequenceGenerator( name = "crewId", sequenceName = "CREW_ID", allocationSize = 1, initialValue = 1 )
	@GeneratedValue(strategy=GenerationType.IDENTITY, generator="crewId")
	private int id;
	private int person_id;
	private int media_id;
	private String department;
	private String job;
	private String poster_path;
	@Column(name="`name`")
	private String name;

	public Crew() {
		super();
	}

	public Crew(int id, int person_id, int media_id, String department, String job,
			String poster_path, String name) {
		super();
		this.id = id;
		this.person_id = person_id;
		this.media_id = media_id;
		this.department = department;
		this.job = job;
		this.poster_path = poster_path;
		this.setName(name);
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

	public String getDepartment() {
		return department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}

	public String getJob() {
		return job;
	}

	public void setJob(String job) {
		this.job = job;
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
