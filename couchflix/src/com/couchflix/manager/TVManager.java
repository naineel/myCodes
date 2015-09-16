package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Media;
import com.couchflix.entity.TV;

public class TVManager {

	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();

	public TV createTV(TV tv) {
		em.getTransaction().begin();
		em.persist(tv);
		em.getTransaction().commit();
		return tv;
	}
	
	public TV readTVById(Integer id) {
		return em.find(TV.class, id);
	}
	
	@SuppressWarnings("unchecked")
	public List<TV> readAllTV() {
		
		Query query = em.createQuery("select tv from TV tv");
		return (List<TV>)query.getResultList();
	}
	
	public TV deleteTV(Integer id) {
		TV tv = readTVById(id);
		em.getTransaction().begin();
		em.remove(tv);
		em.getTransaction().commit();
		return tv;
	}

	@SuppressWarnings("unchecked")
	public TV readTVByMovieDBId(Integer movieDBId) {
		int mediaId = 0;
		Query query = em.createQuery("select media from Media media where media.moviedb_id = :id ");
		query.setParameter("id", movieDBId);
		List<Media> allMedia = (List<Media>)query.getResultList();
		for(Media media : allMedia) {
			if(media.getMoviedb_id().intValue() == movieDBId.intValue()) {
				mediaId = media.getId();
				break;
			}
		}
		System.out.println("MediaId - " + mediaId);
		TV tv = null;
		if(mediaId != 0) {
			tv = readTVById(mediaId);
		}
		return tv;
	}
	
}
