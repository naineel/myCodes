package com.couchflix.api;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.couchflix.apiaccess.PersonAccess;
import com.couchflix.entity.Person;
import com.couchflix.manager.PersonManager;

@Path("/person")
public class PersonAPI {

	@GET
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Person getPersonByID(@PathParam("id") int id) {

		PersonManager manager = new PersonManager();
		Person person = manager.readPersonById(id);
		
		if (person == null) {
			PersonAccess personAccess = new PersonAccess();
			person = personAccess.getPersonById(id);
		}
		return person;
	}

}
