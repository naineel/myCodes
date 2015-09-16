package com.couchflix.api;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.couchflix.entity.Company;
import com.couchflix.manager.CompanyManager;

@Path("/company")
public class CompanyAPI {

	@GET
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Company getCompanyByID(@PathParam("id") int id) {

		CompanyManager manager = new CompanyManager();
		Company company = manager.readCompanyById(id);
		
		return company;
	}

}
