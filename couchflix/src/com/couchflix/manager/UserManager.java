package com.couchflix.manager;

import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;
import javax.servlet.http.HttpServlet;
import com.couchflix.entity.User_info;

public class UserManager extends HttpServlet{
	private static final long serialVersionUID = 1L;
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager entityManager = entityManagerFactory.createEntityManager();
	
		public User_info createUser(User_info user) {
			entityManager.getTransaction().begin();
			entityManager.persist(user);
			entityManager.getTransaction().commit();
			return user;
		}
		
		public User_info readUserByEmail(String email) {
			return entityManager.find(User_info.class, email);
		}
		
		@SuppressWarnings("unchecked")
		public List<User_info> readUserByFname(String fname) {
			Query query = entityManager.createQuery("select user_info from User_info user_info where user_info.firstName LIKE :fname");
			query.setParameter("fname", "%" + fname + "%");
			return (List<User_info>)query.getResultList();
		}
		
		@SuppressWarnings("unchecked")
		public List<User_info> readAllUser() {
			
			Query query = entityManager.createQuery("select user_info from User_info user_info");
			return (List<User_info>)query.getResultList();
		}
		
		public User_info updateUser(User_info user) {
			entityManager.getTransaction().begin();
			entityManager.merge(user);
			entityManager.getTransaction().commit();
			return user;
		}
		
//		public static void main(String[] args) {
//			UserManager userManager = new UserManager();
//			if(userManager.readUserByEmail("naineel123@gmail.com") == null){
//				System.out.println("Success");
//			}
//			
//		}
}

