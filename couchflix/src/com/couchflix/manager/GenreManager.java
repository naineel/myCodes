package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Genre;

public class GenreManager {
	
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public Genre createGenre(Genre genre) {
		em.getTransaction().begin();
		em.persist(genre);
		em.getTransaction().commit();
		return genre;
	}
	
	public Genre readGenreById(Integer id) {
		return em.find(Genre.class, id);
	}
	
	@SuppressWarnings("unchecked")
	public List<Genre> readAllGenre() {
		
		Query query = em.createQuery("select genre from Genre genre");
		return (List<Genre>)query.getResultList();
	}
	
	public Genre deleteGenre(Integer id) {
		Genre genre = readGenreById(id);
		em.getTransaction().begin();
		em.remove(genre);
		em.getTransaction().commit();
		return genre;
	}
}
