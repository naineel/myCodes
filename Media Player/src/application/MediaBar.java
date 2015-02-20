package application;

import javafx.application.Platform;
import javafx.beans.InvalidationListener;
import javafx.beans.Observable;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.Slider;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.media.MediaPlayer;
import javafx.scene.media.MediaPlayer.Status;

public class MediaBar extends HBox{
	Slider time = new Slider();
	Slider vol = new Slider();
	
	Button playButton = new Button("||");
	Button stopButton = new Button("Stop");
	
	Label volume = new Label("Volume: ");
	
	MediaPlayer player;
	
	public MediaBar(MediaPlayer play){
		player = play;
		
		setAlignment(Pos.CENTER);
		setPadding(new Insets(5,10,5,10)); // Insets(Top, right, bottom, left)
		
		vol.setPrefWidth(70);
		vol.setMinWidth(30);
		vol.setValue(100);
		stopButton.setPadding(new Insets(5,5,5,5));
		HBox.setHgrow(time, Priority.ALWAYS);
		
		playButton.setPrefWidth(50); // Sets width of the play button
		stopButton.setPrefWidth(50);
		// Children need to be set in order they have to be in on the screen
		getChildren().add(playButton);
		getChildren().add(stopButton);
		getChildren().add(time);
		getChildren().add(volume);
		getChildren().add(vol);
		
		// Functionality of the play button
		playButton.setOnAction(new EventHandler<ActionEvent>(){
			//implementing the abstract method handle(ActionEvent e)
			public void handle(ActionEvent e){
				Status status = player.getStatus();
				
				if(status == status.PLAYING){
					if(player.getCurrentTime().greaterThanOrEqualTo(player.getTotalDuration())){
						player.seek(player.getStartTime());
						player.play();
					}
					else{
						player.pause();
						playButton.setText(">");
					}
				}
				
				if(status == status.PAUSED || status == status.HALTED || status == status.STOPPED){
					player.play();
					playButton.setText("||");
				}
			}
		});
		
		// Functionality of the stop button
		stopButton.setOnAction(new EventHandler<ActionEvent>(){
			public void handle(ActionEvent event) {
				player.stop();
			}
		});
		
		
		player.currentTimeProperty().addListener(new InvalidationListener(){
			public void invalidated(Observable ov){
				updateValues();
			}
		});
		
		
		time.valueProperty().addListener(new InvalidationListener(){
			public void invalidated(Observable ov) {
				if (time.isPressed()){
					player.seek(player.getMedia().getDuration().multiply(time.getValue()/100));
				}
			}
			
		});
		
		// Increase or decrease volume as the volume slider is increased or decreased.
		vol.valueProperty().addListener(new InvalidationListener(){
			public void invalidated(Observable arg0) {
				if(vol.isPressed()){
					player.setVolume(vol.getValue()/100);
				}
			}
			
		});
		
	}
	
// Updating values for the time slider so the slider moves as the video progresses. 
		protected void updateValues(){
			Platform.runLater(new Runnable(){
				public void run(){
					time.setValue(player.getCurrentTime().toMillis()/player.getTotalDuration().toMillis()*100);
				}
			});
		}
	}
