package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Crew;

public class CrewManager {
	
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public Crew createCrew(Crew Crew) {
		em.getTransaction().begin();
		em.persist(Crew);
		em.getTransaction().commit();
		return Crew;
	}
	
	public Crew readCrewById(Integer id) {
		return em.find(Crew.class, id);
	}
	
	@SuppressWarnings("unchecked")
	public List<Crew> readCrewByMediaId(Integer mediaId) {
		Query query = em.createQuery("select crew from Crew crew where crew.media_id = :id");
		query.setParameter("id", mediaId);
		return (List<Crew>)query.getResultList();
	}
	
	@SuppressWarnings("unchecked")
	public List<Crew> readAllCrew() {
		
		Query query = em.createQuery("select crew from Crew crew");
		return (List<Crew>)query.getResultList();
	}
	
	public Crew deleteCrew(Integer id) {
		Crew Crew = readCrewById(id);
		em.getTransaction().begin();
		em.remove(Crew);
		em.getTransaction().commit();
		return Crew;
	}
}
