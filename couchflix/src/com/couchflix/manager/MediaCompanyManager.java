package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Media_Company;

public class MediaCompanyManager {
	
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public Media_Company createCompany(Media_Company mediaCompanys) {
		em.getTransaction().begin();
		em.persist(mediaCompanys);
		em.getTransaction().commit();
		return mediaCompanys;
	}
	
	@SuppressWarnings("unchecked")
	public List<Media_Company> readMediaCompanyByMediaId(Integer id) {
		Query query = em.createQuery("select mc from Media_Company mc where mc.media_id = :id");
		query.setParameter("id", id);
		return (List<Media_Company>)query.getResultList();
	}
	
	@SuppressWarnings("unchecked")
	public List<Media_Company> readMediaCompanyByCompanyId(Integer id) {
		Query query = em.createQuery("select mc from Media_Company mc where mc.company_id = :id");
		query.setParameter("id", id);
		return (List<Media_Company>)query.getResultList();
	}
	
	@SuppressWarnings("unchecked")
	public List<Media_Company> readAllMediaCompanys() {
		
		Query query = em.createQuery("select mc from Media_Company mc");
		return (List<Media_Company>)query.getResultList();
	}
	
	public List<Media_Company> deleteCompanyByMediaId(Integer id) {
		List<Media_Company> mediaCompany = readMediaCompanyByMediaId(id);
		em.getTransaction().begin();
		for (Media_Company mc : mediaCompany) {
			em.remove(mc);
		}
		em.getTransaction().commit();
		return mediaCompany;
	}
	
	public List<Media_Company> deleteCompanyByCompanyId(Integer id) {
		List<Media_Company> mediaCompany = readMediaCompanyByCompanyId(id);
		em.getTransaction().begin();
		for (Media_Company mc : mediaCompany) {
			em.remove(mc);
		}
		em.getTransaction().commit();
		return mediaCompany;
	}

}
