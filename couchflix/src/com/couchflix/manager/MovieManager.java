package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Media;
import com.couchflix.entity.Movie;

public class MovieManager {

	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();

	public Movie createMovie(Movie movie) {
		em.getTransaction().begin();
		em.persist(movie);
		em.getTransaction().commit();
		return movie;
	}
	
	public Movie readMovieById(Integer id) {
		return em.find(Movie.class, id);
	}
	
	@SuppressWarnings("unchecked")
	public Movie readMovieByMovieDBId(Integer movieDbId) {
		int mediaId = 0;
		Query query = em.createQuery("select media from Media media where media.moviedb_id = :id ");
		query.setParameter("id", movieDbId);
		List<Media> allMedia = (List<Media>)query.getResultList();
		for(Media media : allMedia) {
			System.out.println("Media - " + media.getId() + "," + media.getMoviedb_id() + "," + movieDbId);
			if(media.getMoviedb_id().intValue() == movieDbId.intValue()) {
				System.out.println("Inside if");
				mediaId = media.getId();
				break;
			}
		}
		System.out.println("MediaId - " + mediaId);
		Movie movie = null;
		
		if(mediaId != 0) {
			movie = readMovieById(mediaId);
		}
		return movie;
	}
	
	@SuppressWarnings("unchecked")
	public List<Movie> readAllMovie() {
		Query query = em.createQuery("select movie from Movie movie");
		return (List<Movie>)query.getResultList();
	}
	
	public Movie deleteMovie(Integer id) {
		Movie movie = readMovieById(id);
		em.getTransaction().begin();
		em.remove(movie);
		em.getTransaction().commit();
		return movie;
	}
	
	
//	public static void main(String args[]){
//		MovieManager mm = new MovieManager();
//		
//		Movie movie = mm.readMovieById(1);
//		Comments com = new Comments(null, "Brilliant Movie!", new Date(),1,"naineelshah@gmail.com",null);
//		mm.addComment(1, com);
//		List<Comments> comments = movie.getComments();
//		for(Comments comment : comments){
//			System.out.println(comment.getUser_comment());
//		}
//		
//	}
	
}
