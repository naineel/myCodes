package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.User_list;

public class UserListManager {
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();

	public User_list createUserList(User_list userList){
		em.getTransaction().begin();
		em.persist(userList);
		em.getTransaction().commit();
		return userList;
	}
	
	@SuppressWarnings("unchecked")
	public List<User_list> readListsByUser(String email){
		Query query = em.createQuery("select user_list from User_list user_list where user_list.user_email= :m");
		query.setParameter("m", email);
		List<User_list> userList = (List<User_list>)query.getResultList();
		return userList;
	}
	
	@SuppressWarnings("unchecked")
	public User_list readListByUserandMedia(String email, Integer media_id){
		Query query = em
				.createQuery("select user_list from User_list user_list where User_list.media_id= :m AND User_list.user_email= :em");
		query.setParameter("m", media_id);
		query.setParameter("em", email);
		List<User_list> listing = (List<User_list>) query.getResultList();
		if (listing.size() == 1) {
			return listing.get(0);
		}
		User_list listZero = new User_list();
		listZero.setList_value(null);
		return listZero;
	}
	
	@SuppressWarnings("unchecked")
	public List<User_list> readListsByUserWhere(String email, String list_value){
		Query query = em.createQuery("select user_list from User_list user_list where user_list.user_email= :m AND user_list.list_value= :c");
		query.setParameter("m", email);
		query.setParameter("c", list_value);
		List<User_list> userList = (List<User_list>)query.getResultList();
		return userList;
	}
	
	public User_list readListById(Integer id){
		return em.find(User_list.class, id);
	}
	
	public User_list deleteList(Integer id){
		User_list userList = readListById(id);
		em.getTransaction().begin();
		em.remove(userList);
		em.getTransaction().commit();
		return userList;
	}
	
	public void updateList(User_list userList){
		em.getTransaction().begin();
		em.merge(userList);
		em.getTransaction().commit();
	}
	
	public static void main(String[] args) {
		UserListManager listManager = new UserListManager();
//		User_list userList = new User_list();
//		userList.setList_value("watched");
//		userList.setMedia_id(5);
//		userList.setUser_email("naineelshah@gmail.com");
//		listManager.createUserList(userList);
		System.out.println(listManager.readListByUserandMedia("naineel_shah@hotmail.com", 5));
		
//		listManager.updateList(userList);
	}
}
