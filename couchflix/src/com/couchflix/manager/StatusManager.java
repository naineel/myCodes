package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Status;

public class StatusManager {

	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();

	public Status createStatus(Status status) {
		em.getTransaction().begin();
		em.persist(status);
		em.getTransaction().commit();
		return status;
	}
	
	public Status readStatusById(Integer id) {
		return em.find(Status.class, id);
	}
	
	@SuppressWarnings("unchecked")
	public List<Status> readAllStatus() {
		
		Query query = em.createQuery("select status from Status status");
		return (List<Status>)query.getResultList();
	}
	
	public Status deleteStatus(Integer id) {
		Status status = readStatusById(id);
		em.getTransaction().begin();
		em.remove(status);
		em.getTransaction().commit();
		return status;
	}
}
