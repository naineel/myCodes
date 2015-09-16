package com.couchflix.entity;


import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
public class User_info {
	
	@Id
	private String email;
	private String firstName;
	private String lastName;
	@Temporal(TemporalType.DATE)
	private Date DateOfBirth;
	private String password_field;
	private boolean enabled;
	private boolean isAdmin;
	
	public String getEmail() {
		return email;
	}
	
	public void setEmail(String email) {
		this.email = email;
	}
	
	public String getFirstName() {
		return firstName;
	}
	
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	
	public String getLastName() {
		return lastName;
	}
	
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	
	public Date getDateOfBirth() {
		return DateOfBirth;
	}
	
	public void setDateOfBirth(Date dateOfBirth) {
		this.DateOfBirth = dateOfBirth;
	}
	
	public String getPassword() {
		return password_field;
	}
	
	public void setPassword(String password) {
		this.password_field = password;
	}

	
	public User_info(String email, String firstName, String lastName,
			Date dateOfBirth, String password_field, boolean enabled, boolean isAdmin) {
		super();
		this.email = email;
		this.firstName = firstName;
		this.lastName = lastName;
		DateOfBirth = dateOfBirth;
		this.password_field = password_field;
		this.enabled = false;
		this.isAdmin = isAdmin;
	}

	public User_info() {
		super();
	}

	public boolean isEnabled() {
		return enabled;
	}

	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public boolean isAdmin() {
		return isAdmin;
	}

	public void setAdmin(boolean isAdmin) {
		this.isAdmin = isAdmin;
	}
	
}
