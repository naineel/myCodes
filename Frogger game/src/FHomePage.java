import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Image;


public class FHomePage 
{
	boolean isHome = true,isInstr = false,isQuit = false;
	Image home,instr;
	public FHomePage() 
	{
		// TODO Auto-generated constructor stub
		home = FPictures.hpage;
		instr = FPictures.instructions;
	}
	public void update(boolean isHome,boolean Instr,boolean quit)
	{
		this.isHome = isHome;
		isInstr = Instr;
		isQuit = quit;
	}
	public void paint(Graphics g)
	{
		
		if(isHome)
		{
			g.drawImage(home, 0, 0, FPictures.m);
			//Rules 80 in width 
			Font sf = new Font("Arial",Font.ITALIC,40);
		    g.setFont(sf);
		    g.setColor(Color.BLACK);
		  	g.drawString("Rules",50 , 225);
		  	//Play 60 in width
		  	g.drawString("Play",50 , 325);
		  	//Quit 60
		  	g.drawString("Quit",50 , 425);
		}
			
		else
			if(isInstr)
			{
				g.drawImage(instr, 0, 0, FPictures.m);
				Font sf = new Font("Arial",Font.ITALIC,40);
			    g.setFont(sf);
			    g.setColor(Color.BLACK);
			  	//Play 60 in width
			  	g.drawString("Play",150 , 525);
			  	//Quit 60
			  	g.drawString("Quit",290 , 525);
			}
				
	}
	
	
}
