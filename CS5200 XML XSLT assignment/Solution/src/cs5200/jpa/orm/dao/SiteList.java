package cs5200.jpa.orm.dao;

import java.util.List;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;
import cs5200.jpa.orm.entity.Site;

@XmlRootElement
@XmlAccessorType(value = XmlAccessType.FIELD)
public class SiteList {
	@javax.xml.bind.annotation.XmlElement(name="site")
	private List<Site> sites;

	public List<Site> getSiteList() {
		return sites;
	}

	public void setSiteList(List<Site> siteList) {
		this.sites = siteList;
	}

	public SiteList(List<Site> siteList) {
		super();
		this.sites = siteList;
	}

	public SiteList() {
		super();
	}
	

}
