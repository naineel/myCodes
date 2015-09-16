package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Cast;

public class CastManager {
	
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public Cast createCast(Cast Cast) {
		em.getTransaction().begin();
		em.persist(Cast);
		em.getTransaction().commit();
		return Cast;
	}
	
	public Cast readCastById(Integer id) {
		return em.find(Cast.class, id);
	}
	
	@SuppressWarnings("unchecked")
	public List<Cast> readCastByMediaId(Integer mediaId) {
		Query query = em.createQuery("select c from Cast c where c.media_id = :id");
		query.setParameter("id", mediaId);
		return (List<Cast>)query.getResultList();
	}
	
	@SuppressWarnings("unchecked")
	public List<Cast> readAllCast() {
		
		Query query = em.createQuery("select cast from Cast cast");
		return (List<Cast>)query.getResultList();
	}
	
	public Cast deleteCast(Integer id) {
		Cast Cast = readCastById(id);
		em.getTransaction().begin();
		em.remove(Cast);
		em.getTransaction().commit();
		return Cast;
	}
}
