package edu.neu.cs5200.msn.ds.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import edu.neu.cs5200.msn.ds.entity.Cast;

public class CastManager {
DataSource ds;
	
	public CastManager()
	{
	  try {
		Context ctx = new InitialContext();
		ds = (DataSource)ctx.lookup("java:comp/env/jdbc/MovieSocialNetworkDB");
		System.out.println(ds);
	  } catch (NamingException e) {
		e.printStackTrace();
	  }
	}	
	
	public void createComment(Cast newCast){
		String sql = "insert into cast values (null,?,?,?)";
		try {
			Connection connection = ds.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setString(1, newCast.getCharacterName());
			statement.setInt(2, newCast.getActorId());
			statement.setInt(3, newCast.getMovieId());
			statement.executeUpdate();
			
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	public List<Cast> readAllCast()
	{
		List<Cast> casts = new ArrayList<Cast>();
		String sql = "select * from cast";
		try {
			Connection connection = ds.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
			ResultSet results = statement.executeQuery();
			while(results.next())
			{
				Cast cast = new Cast();
				cast.setCastId(results.getInt("castId"));
				cast.setCharacterName(results.getString("characterName"));
				cast.setActorId(results.getInt("actorId"));
				cast.setMovieId(results.getInt("movieId"));
				casts.add(cast);
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return casts;
	}
	
	public Cast readCastForId(int castId)
	{
		Cast cast = new Cast();
		
		String sql = "select * from cast where castId = ?";
		try {
			Connection connection = ds.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setInt(1, castId);
			ResultSet result = statement.executeQuery();
			if(result.next())
			{
				cast.setCastId(result.getInt("castId"));
				cast.setCharacterName(result.getString("characterName"));
				cast.setActorId(result.getInt("actorId"));
				cast.setMovieId(result.getInt("movieId"));
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}		
		return cast;
	}
	
	public void updateComment(int castId, Cast newCast)
	{
		String sql = "update cast set characterName=?, actorId=?, movieId=? where castId=?";
		try {
			Connection connection = ds.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setString(1, newCast.getCharacterName());
			statement.setInt(2, newCast.getActorId());
			statement.setInt(3, newCast.getMovieId());
			statement.setInt(4, castId);
			statement.executeUpdate();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}		
	}
	
	public void deleteComment(int castId)
	{
		String sql = "delete from cast where castId = ?";
		try {
			Connection connection = ds.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setInt(1, castId);
			statement.executeUpdate();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public List<Cast> readAllCastForActor(int actorId)
	{
		List<Cast> casts = new ArrayList<Cast>();
		String sql = "select * from cast where actorId=?";
		try {
			Connection connection = ds.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setInt(1, actorId);
			ResultSet results = statement.executeQuery();
			while(results.next())
			{
				Cast cast = new Cast();
				cast.setCastId(results.getInt("castId"));
				cast.setCharacterName(results.getString("characterName"));
				cast.setActorId(results.getInt("actorId"));
				cast.setMovieId(results.getInt("movieId"));
				casts.add(cast);
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return casts;
	}
	
	public List<Cast> readAllCastForMovie(int movieId)
	{
		List<Cast> casts = new ArrayList<Cast>();
		String sql = "select * from cast where movieId=?";
		try {
			Connection connection = ds.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setInt(1, movieId);
			ResultSet results = statement.executeQuery();
			while(results.next())
			{
				Cast cast = new Cast();
				cast.setCastId(results.getInt("castId"));
				cast.setCharacterName(results.getString("characterName"));
				cast.setActorId(results.getInt("actorId"));
				cast.setMovieId(results.getInt("movieId"));
				casts.add(cast);
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return casts;
	}

}
