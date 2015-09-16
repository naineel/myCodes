package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Media;

public class MediaManager {

	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();

	public Media createMedia(Media media) {
		em.getTransaction().begin();
		em.persist(media);
		em.getTransaction().commit();
		return media;
	}
	
	public Media readMediaById(Integer id) {
		return em.find(Media.class, id);
	}
	
	public Media readMediaByMovieDB(Integer movieId){
		Query query = em.createQuery("select media from Media media where Media.moviedb_id= :m");
		query.setParameter("m", movieId);
		Media media = (Media) query.getSingleResult();
		return media;
	}
	
	@SuppressWarnings("unchecked")
	public List<Media> readAllMedia() {
		
		Query query = em.createQuery("select media from Media media");
		return (List<Media>)query.getResultList();
	}
	
	public Media deleteMedia(Integer id) {
		Media media = readMediaById(id);
		em.getTransaction().begin();
		em.remove(media);
		em.getTransaction().commit();
		return media;
	}
	
//	public static void main(String[] args) {
//		MediaManager m = new MediaManager();
//		Media media = m.readMediaByMovieDB(550);
//		System.out.println(media.getId());
//		media.getMoviedb_id();
//	}
}
