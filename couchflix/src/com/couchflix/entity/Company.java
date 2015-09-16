package com.couchflix.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;

@Entity
public class Company {

	@Id
	@SequenceGenerator( name = "companyId", sequenceName = "COMPANY_ID", allocationSize = 1, initialValue = 1 )
	@GeneratedValue(strategy=GenerationType.IDENTITY, generator="companyId")
	private int id;
	private String name;
	private String logo_path;
	private String homepage;
	private String headquaters;
	private String description;

	public Company() {
		super();
	}

	public Company(int id, String name, String logo_path, String homepage,
			String headquaters, String description) {
		super();
		this.id = id;
		this.name = name;
		this.logo_path = logo_path;
		this.homepage = homepage;
		this.headquaters = headquaters;
		this.description = description;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getLogo_path() {
		return logo_path;
	}

	public void setLogo_path(String logo_path) {
		this.logo_path = logo_path;
	}

	public String getHomepage() {
		return homepage;
	}

	public void setHomepage(String homepage) {
		this.homepage = homepage;
	}

	public String getHeadquaters() {
		return headquaters;
	}

	public void setHeadquaters(String headquaters) {
		this.headquaters = headquaters;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

}
