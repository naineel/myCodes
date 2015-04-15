package cs5200.jpa.orm.dao;

import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import cs5200.jpa.orm.entity.Site;

@Path("/site")
public class SiteDao {
	
	EntityManagerFactory factory = Persistence.createEntityManagerFactory("Solution");
	EntityManager em = factory.createEntityManager();
	
	// CRUD - Create Read Update Delete
	// CreateSite
	@POST
	@Path("/")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public List<Site> createSite(Site site){
		em.getTransaction().begin();
		em.persist(site);
		em.getTransaction().commit();
		return findAllSites();

	}
	// findSite
	@GET
	@Path("/{siteId}")
	@Produces(MediaType.APPLICATION_JSON)
	public Site findSite(@PathParam("siteId") int id){
		return em.find(Site.class, id);
	}
	
	// findAllSites
	@GET
	@Path("/")
	@Produces(MediaType.APPLICATION_JSON)
	public List<Site> findAllSites(){
		Query query = em.createQuery("select site from Site site");
		return (List<Site>) query.getResultList();
	}
	
	// updateSite
	@PUT
	@Path("/{siteId}")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public List<Site> updateSite(@PathParam("siteId") int id, Site site){
		em.getTransaction().begin();
		site.setId(id);
		em.merge(site);
		em.getTransaction().commit();
		return findAllSites();
	}
	
	// removeSite
	@DELETE
	@Path("/{siteId}")
	@Produces(MediaType.APPLICATION_JSON)
	public List<Site> removeSite(@PathParam("siteId") int id){
		em.getTransaction().begin();
		Site site = em.find(Site.class, id);
		em.remove(site);
		em.getTransaction().commit();
		return findAllSites();
	}
	
	public static void main(String args[]){
		SiteDao dao = new SiteDao();
		Site site = new Site();
//		site.setName("site 3");
//		site.setLatitude(14.15);
//		site.setLongitude(15.16);
//		List<Site> allSites = dao.createSite(site);
//		for(Site site1 : allSites){
//			System.out.println(site1.getName());
//		}
//		
		site.setLatitude(25.89);
		dao.updateSite(1, site);
//		
//		dao.removeSite(3);
//		dao.removeSite(4);
//		dao.removeSite(5);
		
		List<Site> allSites = dao.findAllSites();
		for(Site site1 : allSites){
			System.out.println(site1.getName());
		}
	}
}
