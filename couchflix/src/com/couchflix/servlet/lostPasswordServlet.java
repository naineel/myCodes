package com.couchflix.servlet;

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

import com.couchflix.Globals;
import com.couchflix.entity.User_info;
import com.couchflix.manager.UserManager;

public class lostPasswordServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html;charset=UTF-8");
		String email = request.getParameter("emailId");
		try{
			sendPasswordRecoveryEmail(Globals.adminEmail, Globals.adminUsername, Globals.adminPassword, email);
			response.sendRedirect("login.jsp?action=verifyEmail");
		}
		catch(NullPointerException e){
			response.sendRedirect("login.jsp?action=invalidEmail");
		}
		
	}
	
	private void sendPasswordRecoveryEmail(String adminEmail, String adminUsername,
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
    	String newPassword = new BigInteger(40, random).toString(16);
    	BasicPasswordEncryptor passwordEncryptor = new BasicPasswordEncryptor();
    	String encryptedPassword = passwordEncryptor.encryptPassword(newPassword);
    	
    	try {
			mailMessage.setFrom(new InternetAddress(adminEmail));
			mailMessage.setRecipient(Message.RecipientType.TO, new InternetAddress(email));
			mailMessage.setSubject("Password recovery @ Couchflix.com!");
			String x = "We got a request from you for changing your password "
					+ "Here is your new password:\n"
					+ newPassword
					+ "\n\n\n Thank you,\n Couchflix team";
			mailMessage.setText(x);
			
			UserManager usermanager = new UserManager();
			User_info user = usermanager.readUserByEmail(email);
			user.setPassword(encryptedPassword);
			usermanager.updateUser(user);
			
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
