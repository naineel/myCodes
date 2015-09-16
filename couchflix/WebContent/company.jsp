<!DOCTYPE html>
<%@page import="com.couchflix.Utils"%>
<%@page import="com.couchflix.entity.Company"%>
<%@page import="com.couchflix.api.CompanyAPI"%>
<html lang="en">
<%@ page language="java" contentType="text/html; charset=utf-8"%>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=1000px, initial-scale=1">
<meta name="description" content="">
<meta name="author" content="">
<title>Company</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link href="css/half-slider.css" rel="stylesheet">
<script src="js/jquery.js"></script>
<script src="js/bootstrap.min.js"></script>
</head>

<body style="background-color: #000000">

	<%
		CompanyAPI api = new CompanyAPI();
		String companyId = request.getParameter("companyId");
		Company company = api.getCompanyByID(Integer.parseInt(companyId));
	%>

	<!-- Navigation -->
	<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
		<div class="container">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle" data-toggle="collapse"
					data-target="#bs-example-navbar-collapse-1">
					<span class="icon-bar"></span> <span class="icon-bar"></span> <span
						class="icon-bar"></span>
				</button>
			</div>
			<div class="collapse navbar-collapse"
				id="bs-example-navbar-collapse-1">
				<ul class="nav navbar-nav">
					<li><a href="http://localhost:8080/CouchFlix/index.jsp"><img
							src="images/logo-100.png"></a></li>
					<li><a href="http://localhost:8080/CouchFlix/aboutUs.jsp">About Us</a></li>

					<%
						if(session.getAttribute("user") == null) {
					%>
					<li><img width="100px"></li>
					<li><img width="100px"></li>
					<li><img width="100px"></li>
					<li><img width="100px"></li>
					<li><a href="http://localhost:8080/CouchFlix/login.jsp">Login</a></li>
					<li><a href="http://localhost:8080/CouchFlix/register.jsp">Register</a></li>
					<%
						} else {
					%>
					<%
						if(session.getAttribute("admin") != null) {
					%>

					<li><a
						href="http://localhost:8080/CouchFlix/commentManager.jsp">Comment
							Manager</a></li>

					<%
						} else {
					%>
					<li><img width="100px"></li>
					<%
						}
					%>
					<li><a
						href="http://localhost:8080/CouchFlix/profile.jsp?action=view&email=<%=(String)session.getAttribute("user")%>">Timeline</a>
					<li><a href="http://localhost:8080/CouchFlix/Lists.jsp">My
							Lists</a></li>
					<li><a href="http://localhost:8080/CouchFlix/following.jsp">Following</a></li>
					<li><a href="http://localhost:8080/CouchFlix/update.jsp">Update
							Profile</a></li>
					<li><a href="http://localhost:8080/CouchFlix/index.jsp">Welcome,
							<%=session.getAttribute("userFname")%></a></li>

					<li><a
						href="http://localhost:8080/CouchFlix/index.jsp?action=logout">Logout</a></li>
					<%
						}
					%>
				</ul>
			</div>
		</div>
	</nav>

	<div class="container" align="center" style="padding-top: 70px">

		<h1 style="color: white;"><%=company.getName()%></h1>

		<table class="table">

			<tr>
				<td width="50%" align="center">
				<% if(company.getLogo_path() != null) { %>
				<img
					src='http://image.tmdb.org/t/p/w300<%=company.getLogo_path()%>'
					width="300" height="300" class="img-rounded">
					<% } else { %>
					<img
					src='http://placehold.it/300x300&amp;text=Image+Unavailable'
					width="300" height="300" class="img-rounded">
					<% } %>
					</td>
				<td width="50%">

					<% if(company.getHomepage() != null) { %>
					<h4 style="color: white;">Homepage</h4>
					<p style="color: #A5A5A5;">
						<a href="<%=company.getHomepage()%>"><%=company.getHomepage()%></a>
					</p>
					<% } %>

					<% if(company.getHeadquaters() != null) { %>
					<h4 style="color: white;">Headquaters</h4>
					<p style="color: #A5A5A5;">
						<%=company.getHeadquaters()%>
					</p>
					<% } %>

					<% if(company.getDescription() != null) { %>
					<h4 style="color: white;">Description</h4>
					<p style="color: #A5A5A5; text-align: justify;">
						<%=company.getDescription()%>
					</p>
					<% } %>
				</td>
			</tr>
		</table>
	</div>

	<div class="container">

		<hr>
		<footer>
			<div class="row">
				<div class="col-lg-12">
					<p style="color: white;">Copyright &copy; CouchFlix 2015</p>
				</div>
			</div>
		</footer>
	</div>

</body>

</html>
