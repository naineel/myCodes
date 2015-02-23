// This is the game called Frogger. It has been made using the applet class.Instructions 
// to the game are in the applet itself.
import java.applet.Applet;
import java.applet.AudioClip;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.net.URL;

public class Start extends Applet implements Runnable,KeyListener,MouseListener{

	float frame = 0;
	int test;
	
	boolean isPlaying = false;
	boolean isInstr = false;
	boolean isQuit = false;
	boolean isHomePage = true;
	boolean isWon = false;
	boolean isPlayAgain = true;
	
	// I have used several audio clips in the game to give sound effects.
	static AudioClip Playing;
	static AudioClip splash; 
	static AudioClip crash;
	static AudioClip gameover_out;
	static AudioClip victory;
	
	FHomePage h;
	
	Thread t;
	
	// Instantiation
	// Using 4 log lanes and 4 car lanes in the applet.
	LogLane LogLane[] = new LogLane[4];
	CarLane CarLane[] = new CarLane[4];
	int carLaneNo;
	Frog frog;
	URL url;
	int X,Y;
	int logLaneNo;
	int startLogY = 250;
	int startCarY = 500;
	Image river,frogCrashed,frogDissolved,road,friend,grass,top;
	Image i;
	Graphics dbuff;
	boolean isGameOver = false,isGameOverLog,isGameOverCar;
	FPictures p;
	
	int GOcount = 0;
	@Override
	public void init() 
	{
		p = new FPictures(this);
		addKeyListener(this);
		addMouseListener(this);
		
		h = new FHomePage();
		t = new Thread(this);
		frog = new Frog();
		url = getDocumentBase();
		
		this.setSize(800, 600);
		river = FPictures.lake;
		frogDissolved = FPictures.frogDissolved;
		frogCrashed = FPictures.frogCrashed;
		road = FPictures.road;
		grass = FPictures.grass;
		top = FPictures.top;
		
		Playing = getAudioClip(url, "theme.au");
		splash = getAudioClip(url, "splashloud.au");
		crash = getAudioClip(url, "carcrash1.au");
		gameover_out = getAudioClip(url, "gameover.au");
		victory = getAudioClip(url, "victory.au");
		
		X = frog.getX();
		Y = frog.getY();
		logLaneNo = 5;
		carLaneNo = 5;
		isGameOver = false;
		
		int y = startLogY-50;
		for(int i = 0;i < LogLane.length; i++)
		{
			LogLane[i] = new LogLane(LogLane.length-i,y,i);
			y = y-50;
		}
		
		y = startCarY-55;
		for(int i=0;i<CarLane.length;i++)
		{
			CarLane[i] = new CarLane(CarLane.length-i,y,i);
			y = y - 50;
		}
		t.start();
		
	}
	
	@Override
	public void start() 
	{
		
	}
	
	@Override
	public void paint(Graphics g) 
	{
		h.paint(g);
		//setBackground((new Color(128, 175, 252)));
		
		if (isPlaying)
		{
			//Drawing the layout with the top layer, the river and the grass images.
			g.drawImage(top, 0, 0, this);
			g.drawImage(grass, 0, startLogY, this);
			g.drawImage(grass, 0, startCarY, this);
			g.drawImage(river, 0, 50, this);
			
			for(int i=0;i < LogLane.length;i++)
			{
				LogLane[i].paint(g);
			}
			
			int y = startCarY - 50;
			for(int i = 0;i < 4;i++)
			{
				g.drawImage(road, 0, y, this);
				y -= 50;
			}
			
			if(isGameOverCar)
			{
				frog.updateCrashed();
				frog.paint(g);
				isPlayAgain=false;
			}
			else if (!isGameOver)
			{
				frog.paint(g);
				if (isWon)
				{
					Font sf = new Font("Arial",Font.BOLD,100);
		    	    g.setFont(sf);
					g.setColor(Color.GREEN);
					g.drawString("You Won! :)",150 , 300);
				}
			}
			else if(isGameOverLog)
			{
				if(frame < 3)
				{
					g.drawImage(frogDissolved, X, Y, X + frogDissolved.getWidth(this), Y+30, 0, 30*

(int)frame, frogDissolved.getWidth(this), 30*(int)frame + 30, this);
					frame+=.15;
				}
				
				isPlayAgain=false;
			}
			
			// slow motion game over
			if (!isGameOver)
			{
				if (isWon)
				{
					Font sf = new Font("Arial",Font.BOLD,100);
		    	    g.setFont(sf);
					g.setColor(Color.GREEN);
					g.drawString("You Won! :)",150 , 300);
					sf = new Font("Arial",Font.BOLD,30);
		    	    g.setFont(sf);
					g.drawString("Play Again?",200,startCarY+35);
					g.drawString("Quit",500,startCarY+35);
				}	
			}
			else if(GOcount <= 6 && (isGameOverCar || frame>=3 || X+30<0 || X+10>800 || (X > 400 || X < 350)))
		    {
		    	//System.out.println(GOcount+" "+(GOcount<=6));
		    	//System.out.println(frame);
		    	try 
			    	{
			    		Font sf = new Font("Arial",Font.BOLD,30+GOcount*20);
			    	    g.setFont(sf);
			    	    g.drawString("Game Over!",265-50*GOcount,295-10*GOcount);
						Thread.sleep(35);
						GOcount++;
					} 
			    	catch (InterruptedException e) 
					{
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
			    	isPlayAgain=false;
			    	//System.out.println(GOcount);
			    	//System.out.println(frame);
		    }
		    else if(isGameOverCar || frame >= 3 || X+30<0 || X+10>800 || (X > 400 || X < 350))
		    {
		    	Font sf = new Font("Arial",Font.BOLD,30+(GOcount-1)*20);
	    	    g.setFont(sf);
		    	g.drawString(" Game Over!",265-50*(GOcount-1),295-10*(GOcount-1));
		    	//play again
		    	sf = new Font("Arial",Font.BOLD,30);
	    	    g.setFont(sf);
		    	g.drawString("Play Again?",200,startCarY+35);
		    	g.drawString("Quit",500,startCarY+35);
		    	isPlayAgain=false;
		    }
			for(int i=0;i<CarLane.length;i++){
				CarLane[i].paint(g);
			}
		}
	}
	
	public void update(Graphics g)
	{
		
		if(i == null)
		{
			i = createImage(this.getWidth(), this.getHeight());
			dbuff = i.getGraphics();
		}
		
		dbuff.setColor(this.getBackground());
		dbuff.fillRect(0, 0, this.getWidth(), this.getHeight());
		
		dbuff.setColor(this.getForeground());
		paint(dbuff);
		g.drawImage(i, 0, 0, this);
	}
	
	@Override
	public void destroy() 
	{
		// TODO Auto-generated method stub
	}
	
	@Override
	public void run() 
	{
		// TODO Auto-generated method stub
		while(true)
		{
			if(!isGameOver)
				isGameOverLog = true;
			
			for(int i = 0;i < LogLane.length;i++)
			{
				LogLane[i].update(frog,this,logLaneNo);
				if(!isGameOver)
					isGameOverLog = isGameOverLog && !(LogLane[i].getIsFrogOn());
			}    
			
			X = frog.getX();
			Y = frog.getY();
			//System.out.println(Y);
			
			if(!isGameOver)
			{
				isGameOverLog = (isGameOverLog && Y < startLogY) && Y!=10;
				isGameOverCar = false;
			}
			
			for(int i = 0;i < CarLane.length;i++)
			{
				CarLane[i].update(frog,this,carLaneNo);
				//System.out.print(CarLane[i].getIsFrogSafe()+" ");
				if(!isGameOver)
					isGameOverCar = isGameOverCar || !(CarLane[i].getIsFrogSafe());
			}
			
			//System.out.println();
			
			if(!isGameOver)
			{
				isGameOverCar = (isGameOverCar && Y < startCarY);
				isGameOver = isGameOverLog || isGameOverCar;
				if(X + 30 < 0 || X + 10 > 800)
				{
					Playing.stop();
					isGameOver = true;
				}
				else if(isGameOverCar)
				{
					Playing.stop();
					crash.play();
					gameover_out.play();
				}
				else if(isGameOverLog)
				{
					Playing.stop();
					splash.play();
					gameover_out.play();
				}
			}
			
			//winning
			if (!isWon && Y == 10 && X >= 350 && X <= 400)
			{
				isWon = true;
				Playing.stop();
				victory.play();
			}
			else if(!isWon && Y == 10 )
				{	
					
					isGameOver = true;
					isWon = false;
					Playing.stop();
				}
				
			repaint();
			
			try 
			{
				Thread.sleep(35);
			} 
			catch (InterruptedException e) 
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			//System.out.println(isGameOverCar+" "+isGameOverLog);
		}	
	}
	
	@Override
	public void mouseClicked(MouseEvent e) {
		// TODO Auto-generated method stub
		int mouseX = e.getX();
		int mouseY = e.getY();
		System.out.println(e.getX()+" "+e.getY());
		if(isHomePage)
		{
			//Play
			if(mouseX > 52 && mouseX < 126 || mouseX > 151 && mouseX < 227 )
				if(mouseY > 297 && mouseY < 324 || mouseY > 496 && mouseY < 532)
				{
					isHomePage = false;
					h.update(false,false,false);
					isPlaying = true;
					//Starting.stop();
					Playing.loop();
				}
			
			//Rules
			if(mouseX > 52 && mouseX < 149)
				if(mouseY > 195 && mouseY < 225)
				{
					isInstr = true;
					h.update(false, true, false);
				}
			 
			//Quit
			if(mouseX > 55 && mouseX < 123 || mouseX > 297 && mouseX < 364)
				if(mouseY > 395 && mouseY < 424 || mouseY > 495 && mouseY < 525)
				{
					isHomePage = false;
					System.exit(0);
				}
		}
		else
		{
			//Play again
			if(isGameOver || isWon)
			{
				if(mouseX > 201 && mouseX < 369)
					if(mouseY > 510 && mouseY < 535)
					{
						isPlayAgain = true;
						isGameOver = false;
						frog.resetFrog();
						isGameOverLog = false;
						isGameOverCar = false;
						logLaneNo = 5;
						carLaneNo = 5;
						GOcount = 0;
						isWon = false;
						Playing.loop();
						frame = 0;
					}
				
				if(mouseX > 499 && mouseX < 560)
					if(mouseY > 510 && mouseY < 535)
					{
						System.exit(0);
					}
			}
		}
	}

	@Override
	public void mouseEntered(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseExited(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mousePressed(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void keyPressed(KeyEvent e) {
		// TODO Auto-generated method stub
		if(!isGameOver && !isWon && isPlayAgain)
		{
			switch(e.getKeyCode()){
			
			case KeyEvent.VK_UP:
				if(Y >= 360 && Y <= 510)
				{
					carLaneNo--;
					
				}
				else if(Y >= 110 && Y <= 260)
				{
					logLaneNo--;
				}
				frog.moveUp();
				
				break;
				
			case KeyEvent.VK_DOWN:
				
				if(Y>=310&&Y<=460)
				{
					carLaneNo++;
					
				}
				else if(Y>=60&&Y<=210)
				{
					logLaneNo++;
				}
				
				frog.moveDown();
				break;
				
			case KeyEvent.VK_LEFT:
				frog.moveLeft();
				break;
				
			case KeyEvent.VK_RIGHT:
				frog.moveRight();
				break;
		
			}
		}
	}

	@Override
	public void keyReleased(KeyEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void keyTyped(KeyEvent arg0) {
		// TODO Auto-generated method stub
		
	}

}
