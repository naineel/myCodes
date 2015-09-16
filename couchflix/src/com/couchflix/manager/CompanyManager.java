package com.couchflix.manager;

import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;

import com.couchflix.entity.Company;

public class CompanyManager {
	
	EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory("CouchFlix");
	EntityManager em = entityManagerFactory.createEntityManager();
	
	public Company createCompany(Company Company) {
		em.getTransaction().begin();
		em.persist(Company);
		em.getTransaction().commit();
		return Company;
	}
	
	public Company readCompanyById(Integer id) {
		return em.find(Company.class, id);
	}
	
	@SuppressWarnings("unchecked")
	public List<Company> readAllCompany() {
		
		Query query = em.createQuery("select company from Company company");
		return (List<Company>)query.getResultList();
	}
	
	public Company deleteCompany(Integer id) {
		Company Company = readCompanyById(id);
		em.getTransaction().begin();
		em.remove(Company);
		em.getTransaction().commit();
		return Company;
	}
}
