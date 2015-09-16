package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Person;

public class PersonManager {

	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();

	public Person createPerson(Person person) {
		em.getTransaction().begin();
		em.persist(person);
		em.getTransaction().commit();
		return person;
	}
	
	public Person readPersonById(Integer id) {
		return em.find(Person.class, id);
	}
	
	@SuppressWarnings("unchecked")
	public List<Person> readAllPerson() {
		
		Query query = em.createQuery("select person from Person person");
		return (List<Person>)query.getResultList();
	}
	
	public Person deletePerson(Integer id) {
		Person person = readPersonById(id);
		em.getTransaction().begin();
		em.remove(person);
		em.getTransaction().commit();
		return person;
	}
}
