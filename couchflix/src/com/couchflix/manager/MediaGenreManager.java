package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Media_Genre;

public class MediaGenreManager {
	
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public Media_Genre createGenre(Media_Genre mediaGenres) {
		em.getTransaction().begin();
		em.persist(mediaGenres);
		em.getTransaction().commit();
		return mediaGenres;
	}
	
	@SuppressWarnings("unchecked")
	public List<Media_Genre> readMediaGenreByMediaId(Integer id) {
		Query query = em.createQuery("select mg from Media_Genre mg where mg.media_id = :id");
		query.setParameter("id", id);
		return (List<Media_Genre>)query.getResultList();
	}
	
	@SuppressWarnings("unchecked")
	public List<Media_Genre> readMediaGenreByGenreId(Integer id) {
		Query query = em.createQuery("select mg from Media_Genre mg where mg.genre_id = :id");
		query.setParameter("id", id);
		return (List<Media_Genre>)query.getResultList();
	}
	
	@SuppressWarnings("unchecked")
	public List<Media_Genre> readAllMediaGenres() {
		
		Query query = em.createQuery("select mg from Media_Genre mg");
		return (List<Media_Genre>)query.getResultList();
	}
	
	public List<Media_Genre> deleteGenreByMediaId(Integer id) {
		List<Media_Genre> mediaGenre = readMediaGenreByMediaId(id);
		em.getTransaction().begin();
		for (Media_Genre mg : mediaGenre) {
			em.remove(mg);
		}
		em.getTransaction().commit();
		return mediaGenre;
	}
	
	public List<Media_Genre> deleteGenreByGenreId(Integer id) {
		List<Media_Genre> mediaGenre = readMediaGenreByGenreId(id);
		em.getTransaction().begin();
		for (Media_Genre mg : mediaGenre) {
			em.remove(mg);
		}
		em.getTransaction().commit();
		return mediaGenre;
	}

}
