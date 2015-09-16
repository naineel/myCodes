package com.couchflix.entity;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;

@Entity
public class Media_Company {

	@Id
	@SequenceGenerator( name = "mediaCompanyId", sequenceName = "MEDIA_COMPANY_ID", allocationSize = 1, initialValue = 1 )
	@GeneratedValue(strategy=GenerationType.IDENTITY, generator="mediaCompanyId")
	private int id;
	private int media_id;
	private int company_id;

	public Media_Company() {
		super();
	}

	public Media_Company(int id, int media_id, int company_id) {
		super();
		this.id = id;
		this.media_id = media_id;
		this.company_id = company_id;
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

	public int getCompany_id() {
		return company_id;
	}

	public void setCompany_id(int company_id) {
		this.company_id = company_id;
	}

}
