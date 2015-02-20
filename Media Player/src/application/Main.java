// Designed a media player using Java FX with the ability to play video and audio files.
// There is a menu bar on top which contains file and Help. File has Open and Exit within 
// them.
// Help has the about tab.
// 'Open' opens a window to select which file to be played next from the system.
// Exit exits the window.
// About tab opens a tab to show the creator of the media player :)
// At the bottom there is a play button, Stop button, Time Duration bar and volume bar.
// Time duration can be changed by dragging the button.Also volume can be changed.

package application;
	
import java.io.File;
import java.net.MalformedURLException;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.control.Menu;
import javafx.scene.control.MenuBar;
import javafx.scene.control.MenuItem;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Text;


public class Main extends Application {
	
	Player player;
	FileChooser filechooser;
	public void start(final Stage primaryStage) {
		
		MenuItem open = new MenuItem("Open");
		MenuItem exit = new MenuItem("Exit");
		MenuItem about = new MenuItem("About");
		Menu file = new Menu("File");
		Menu help = new Menu("Help");
		MenuBar menu = new MenuBar();
		
		primaryStage.setTitle("SIMPLE MEDIA PLAYER");
		
		filechooser = new FileChooser();
		
		file.getItems().add(open);
		file.getItems().add(exit);
		menu.getMenus().add(file);
		help.getItems().add(about);
		menu.getMenus().add(help);
		
		// Functionality of  the open button
		open.setOnAction(new EventHandler<ActionEvent>(){
			public void handle(ActionEvent arg0) {
				player.player.pause();
				File file = filechooser.showOpenDialog(primaryStage);
				if (file != null){
					try {
						player = new Player(file.toURI().toURL().toExternalForm());
						player.setTop(menu);
						Scene scene = new Scene(player, player.getWidth(), player.getHeight(), Color.BLACK);
						primaryStage.setScene(scene);
					} catch (MalformedURLException e) {
						e.printStackTrace();
					}
					
				}
			}
			
		});
		
		// Functionality of the exit button
		exit.setOnAction(new EventHandler<ActionEvent>(){

			public void handle(ActionEvent event) {
				Platform.exit();
			}
			
		});
		
		// Functionality of the about button
		about.setOnAction(new EventHandler<ActionEvent>(){
			
			public void handle(ActionEvent e1){
				final Stage stage = new Stage(); 
				stage.setTitle("About");
				stage.initOwner(primaryStage);
                VBox dialogVbox = new VBox(0);// Argument sets the spacing between two horizontal lines.
                dialogVbox.getChildren().add(new Text("Version 1"));
                dialogVbox.getChildren().add(new Text("Created by Naineel Shah"));
                dialogVbox.getChildren().add(new Text("Contact at naineelshah@gmail.com"));
                Scene dialogScene = new Scene(dialogVbox, 300, 200);
                stage.setScene(dialogScene);
                stage.show();
			}
		});
		
		// Put any address from your own computer to make this work.
		// Make sure its the correct address.
		player = new Player("file:///C:/manali.mp4");
//		player = new Player("");
		player.setTop(menu);
		Scene scene = new Scene(player,568,395,Color.BLACK);
		primaryStage.setScene(scene);
		primaryStage.show();
	}
	
	public static void main(String[] args) {
		launch(args);
	}
}
