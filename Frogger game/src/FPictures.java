import java.awt.Image;
import java.net.URL;

public class FPictures  
{

	static Image log,carleft,carright,redcarleft,redcarright,frog,gameOver2,gameOver1;
	static Image frogCrashed,frogDissolved;
	static Image grass,top;
	static Image hpage, instructions;
	static Image road;
	static Image lake;
	static Image friend;
	static Start m;
	URL url;
	
	public FPictures(Start s) {
		// TODO Auto-generated constructor stub
		try
		{
			url=s.getDocumentBase();
		}
		catch (Exception e)
		{
			// TODO: handle exception
		}
		
		FPictures.m = s;
		log = m.getImage(url, "log.png");
		carleft = m.getImage(url, "carleft.png");
		carright = m.getImage(url, "carright.png");
		redcarleft = m.getImage(url, "redcarleft.png");
		redcarright = m.getImage(url, "redcarright.png");
		frog = m.getImage(url, "frog.png");
		road = m.getImage(url, "road.png");
		lake = m.getImage(url, "lake.png");
		frogDissolved = m.getImage(url, "GameOverFrog.png");
		frogCrashed = m.getImage(url,"frogCrashed.png");
		friend = m.getImage(url,"pinkie.png");
		grass = m.getImage(url, "grass.png");
		hpage = m.getImage(url, "background.png");
		instructions = m.getImage(url,"instructions.png");
		top = m.getImage(url,"top.png");
	}

	// Function to test if the photos are displaying or not.
	/*void testPictures(Graphics g)
	{
		System.out.println("In testPictures()");
		g.drawImage(frog, 100, 500, m);
	}*/
	
}