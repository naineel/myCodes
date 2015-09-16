package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Comments;

public class CommentManager {
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public Comments createComment(Comments comment){
		em.getTransaction().begin();
		em.persist(comment);
		em.getTransaction().commit();
		return comment;
	}
	
	@SuppressWarnings("unchecked")
	public List<Comments> readAllComments(){
		Query query = em.createQuery("select comments from Comments comments");
		List<Comments> comments = (List<Comments>)query.getResultList();
		return comments;
	}
	
	@SuppressWarnings("unchecked")
	public List<Comments> readCommentsByUser(String email){
		Query query = em.createQuery("select comments from Comments comments where comments.user_email= :m");
		query.setParameter("m", email);
		List<Comments> comments = (List<Comments>)query.getResultList();
		return comments;
	}
	
	@SuppressWarnings("unchecked")
	public List<Comments> readCommentsByMediaId(Integer id){
		Query query = em.createQuery("select comments from Comments comments where comments.media_id= :m ORDER BY comments.id DESC");
		query.setParameter("m", id);
		List<Comments> comments = (List<Comments>)query.getResultList();
		return comments;
	}
	
	
	public Comments readCommentById(Integer id){
		return em.find(Comments.class, id);
	}
	
	public Comments updateComment(Comments comment){
		em.getTransaction().begin();
		em.merge(comment);
		em.getTransaction().commit();
		return comment;
	}
	
	public Comments deleteComment(Integer id){
		Comments comment = readCommentById(id);
		em.getTransaction().begin();
		em.remove(comment);
		em.getTransaction().commit();
		return comment;
	}
	
//	public static void main(String[] args) {
//		CommentManager cm = new CommentManager();
//		List<Comments> comments = cm.readCommentsByUser("naineelshah@gmail.com");
//		for(Comments com : comments){
//			
//			System.out.println(com.getUser_comment());
//		}
//		
////		System.out.println(comment.getMovie().getTitle());
//	}
	
}
