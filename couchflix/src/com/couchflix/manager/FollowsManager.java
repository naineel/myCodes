package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Follows;

public class FollowsManager {
	
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public Follows createFollows(Follows Follows) {
		em.getTransaction().begin();
		em.persist(Follows);
		em.getTransaction().commit();
		return Follows;
	}
	
	public Follows readFollowsById(Integer id) {
		return em.find(Follows.class, id);
	}
	
	@SuppressWarnings("unchecked")
	public List<Follows> readFollowsByUserEmail(String user_email) {
		Query query = em.createQuery("select c from Follows c where c.user_email = :user_email");
		query.setParameter("user_email", user_email);
		return (List<Follows>)query.getResultList();
	}
	
	@SuppressWarnings("unchecked")
	public List<Follows> readAllFollows() {
		Query query = em.createQuery("select cast from Follows cast");
		return (List<Follows>)query.getResultList();
	}
	
	public Follows deleteFollows(Integer id) {
		Follows Follows = readFollowsById(id);
		em.getTransaction().begin();
		em.remove(Follows);
		em.getTransaction().commit();
		return Follows;
	}
}
