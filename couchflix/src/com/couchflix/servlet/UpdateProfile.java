package com.couchflix.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jasypt.util.password.BasicPasswordEncryptor;

import com.couchflix.Utils;
import com.couchflix.entity.User_info;
import com.couchflix.manager.UserManager;

public class UpdateProfile extends HttpServlet{
	private static final long serialVersionUID = 1L;
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		UserManager userManager = new UserManager();
		String emailId = request.getParameter("emailId");
		User_info user = userManager.readUserByEmail(emailId);
		response.setContentType("text/html;charset=UTF-8");
		String fName = request.getParameter("firstName");
		String lName = request.getParameter("lastName");
		String password = request.getParameter("password");
		BasicPasswordEncryptor passwordEncryptor = new BasicPasswordEncryptor();
		
		String dob = request.getParameter("dob");
		
		if (!fName.isEmpty()){
			user.setFirstName(fName);
		}
		
		if(!lName.isEmpty()){
			user.setLastName(lName);
		}
		
		if(!password.isEmpty()){
			String encryptedPassword = passwordEncryptor.encryptPassword(password);
			user.setPassword(encryptedPassword);
		}
		
		if(!dob.isEmpty()){
			user.setDateOfBirth(Utils.stringToDate(dob));
		}
		
		userManager.updateUser(user);
		response.sendRedirect("update.jsp?action=updateProfile");
		
		
		
	}
	
}
