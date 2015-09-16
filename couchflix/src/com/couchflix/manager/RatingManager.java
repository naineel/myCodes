package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Ratings;

public class RatingManager {
	EntityManagerFactory entityManagerFactory = Persistence
			.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();

	public Ratings createRating(Ratings rating) {
		em.getTransaction().begin();
		em.persist(rating);
		em.getTransaction().commit();
		return rating;
	}

	@SuppressWarnings("unchecked")
	public List<Ratings> readRatingsByUser(String email) {
		Query query = em
				.createQuery("select ratings from Ratings ratings where ratings.user_email= :m");
		query.setParameter("m", email);
		List<Ratings> ratings = (List<Ratings>) query.getResultList();
		return ratings;
	}

	@SuppressWarnings("unchecked")
	public List<Ratings> readRatingsByMediaId(Integer id) {
		Query query = em
				.createQuery("select ratings from Ratings ratings where ratings.media_id= :m");
		query.setParameter("m", id);
		List<Ratings> ratings = (List<Ratings>) query.getResultList();
		return ratings;
	}

	@SuppressWarnings("unchecked")
	public Ratings readRatingsByMediaIdAndUser(Integer id, String email) {
		Query query = em
				.createQuery("select ratings from Ratings ratings where ratings.media_id= :m AND ratings.user_email= :em");
		query.setParameter("m", id);
		query.setParameter("em", email);
		List<Ratings> rating1 = (List<Ratings>) query.getResultList();
		if (rating1.size() == 1) {
			return rating1.get(0);
		}
		Ratings ratingZero = new Ratings();
		ratingZero.setUser_rating(0);
		return ratingZero;
	}

	public Integer averageRating(Integer id) {
		int sum = 0;
		List<Ratings> ratings = readRatingsByMediaId(id);
		for (Ratings rating : ratings) {
			sum += rating.getUser_rating();
		}
		if (ratings.size() != 0) {
			Integer avg_rating = sum / (ratings.size());
			return avg_rating;
		} else {
			return 0;
		}
	}

	public Ratings readRatingById(Integer id) {
		return em.find(Ratings.class, id);
	}

	// Update Rating for a user
	public void updateRating(Ratings rating) {
		em.getTransaction().begin();
		em.merge(rating);
		em.getTransaction().commit();
	}

	public Ratings deleteRating(Integer id) {
		Ratings rating = readRatingById(id);
		em.getTransaction().begin();
		em.remove(rating);
		em.getTransaction().commit();
		return rating;
	}

	public static void main(String[] args) {
		RatingManager ratingManager = new RatingManager();
		System.out.println(ratingManager.readRatingsByMediaIdAndUser(1,
				"naineelshah@gmail.com"));
	}

}
