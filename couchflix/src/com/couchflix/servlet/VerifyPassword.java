package com.couchflix.servlet;

import java.io.IOException;
import java.math.BigInteger;
import java.util.Date;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jasypt.util.password.BasicPasswordEncryptor;

import com.couchflix.Utils;
import com.couchflix.entity.User_info;
import com.couchflix.manager.UserManager;
import com.couchflix.Globals;

import java.security.SecureRandom;

public class VerifyPassword extends HttpServlet{
	private static final long serialVersionUID = 1L;

		protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
			UserManager userManager = new UserManager();
			response.setContentType("text/html;charset=UTF-8");
			String email = request.getParameter("emailId");
			String fName = request.getParameter("firstName");
			String lName = request.getParameter("lastName");
			
			if(userManager.readUserByEmail(email) == null){
				BasicPasswordEncryptor passwordEncryptor = new BasicPasswordEncryptor();
				String password = request.getParameter("password");
				String encryptedPassword = passwordEncryptor.encryptPassword(password);
				String dateOfBirth = request.getParameter("dob"); 
				Date dob = Utils.stringToDate(dateOfBirth);
				// Send verification Email from couchflix91@gmail.com
				sendEmail(Globals.adminEmail, Globals.adminUsername, Globals.adminPassword, email);
				User_info user = new User_info(email, fName, lName,dob , encryptedPassword, false, false);
				user = userManager.createUser(user);
			
//				Check to display Email of the user added
//				out.println(user.getEmail());
				response.sendRedirect("login.jsp?action=verifyEmail");
			}
			else{
				response.sendRedirect("login.jsp?action=emailExists");
			}
		}

		private void sendEmail(String adminEmail, String adminUsername,
				String adminPassword, String email) {
			// TODO Auto-generated method stub
			Properties props = System.getProperties();
	    	props.put("mail.smtp.starttls.enable", "true");
	    	props.put("mail.smtp.ssl.enable", "true");
	    	props.put("mail.smtp.auth", "true");
	    	props.put("mail.smtp.port", "465");
	    	props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
	    	props.put("mail.smtp.socketFactory.port", "465");
	    	props.put("mail.smtp.socketFactory.fallback", "false");
	    	
	    	Session mailSession = Session.getDefaultInstance(props, null);
	    	mailSession.setDebug(true);
	    	SecureRandom random = new SecureRandom();
	    	MimeMessage mailMessage = new MimeMessage(mailSession);
	    	
	    	try {
				mailMessage.setFrom(new InternetAddress(adminEmail));
				mailMessage.setRecipient(Message.RecipientType.TO, new InternetAddress(email));
				mailMessage.setSubject("Welcome to Couchflix.com!");
				String x = "Thank you for registering with Couchflix.com. "
						+ "To complete the sign up process you must click the"
						+ " validation link below and then activate the "
						+ "service :\n"
						+ "http://localhost:8080/CouchFlix/" + "login.jsp?action=validate&email=" + email
						+ "&checksum=" + new BigInteger(130, random).toString(32)
						+ "\n\n\n Thank you,\n Couchflix team";
				mailMessage.setText(x);
				
				Transport transport = mailSession.getTransport("smtp");
				transport.connect("smtp.gmail.com", adminEmail, adminPassword);
				transport.sendMessage(mailMessage, mailMessage.getAllRecipients());
				transport.close();
				
			} catch (AddressException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (MessagingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    }
}
