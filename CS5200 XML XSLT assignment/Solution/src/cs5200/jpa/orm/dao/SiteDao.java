package cs5200.jpa.orm.dao;

import java.io.File;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import cs5200.jpa.orm.entity.Site;

public class SiteDao {
	
	EntityManagerFactory factory = Persistence.createEntityManagerFactory("Solution");
	EntityManager em = factory.createEntityManager();
	
	// CRUD - Create Read Update Delete
	// findSite
	public Site findSite(int id){
		return em.find(Site.class, id);
	}
	
	// findAllSites
	@SuppressWarnings("unchecked")
	public List<Site> findAllSites(){
		Query query = em.createQuery("select site from Site site");
		return (List<Site>) query.getResultList();
	}
	
	public void exportSiteDatabaseToXmlFile(SiteList sites, String xmlFileName) {
		File xmlFile = new File(xmlFileName);
		try {
			JAXBContext jaxb = JAXBContext.newInstance(SiteList.class);
			Marshaller marshaller = jaxb.createMarshaller();
			marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
			marshaller.marshal(sites, xmlFile);
		} catch (JAXBException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void convertXmlFileToOutputFile(
			String siteXmlFileName,
			String outputFileName,
			String xsltFileName)
	{
		File inputXmlFile = new File(siteXmlFileName);
		File outputXmlFile = new File(outputFileName);
		File xsltFile = new File(xsltFileName);
		
		StreamSource source = new StreamSource(inputXmlFile);
		StreamSource xslt    = new StreamSource(xsltFile);
		StreamResult output = new StreamResult(outputXmlFile);
		
		TransformerFactory factory = TransformerFactory.newInstance();
		try {
			Transformer transformer = factory.newTransformer(xslt);
			transformer.transform(source, output);
		} catch (TransformerConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (TransformerException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static void main(String args[]){
		SiteDao dao = new SiteDao();
		Site site = dao.findSite(1);
		System.out.println(site.getName());
		
		List<Site> allSites = dao.findAllSites();
		for(Site site1 : allSites){
			System.out.println(site1.getName());
		}
		
		SiteList theSites = new SiteList();
		theSites.setSiteList(allSites);
		
		dao.exportSiteDatabaseToXmlFile(theSites, "xml/sites.xml");
		
		dao.convertXmlFileToOutputFile("xml/sites.xml", "xml/sites.html", "xml/sites2html.xslt");
		dao.convertXmlFileToOutputFile("xml/sites.xml", "xml/equipment.html", "xml/sites2equipment.xslt");
	}
}
