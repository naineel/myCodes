<!DOCTYPE html>
<html lang="en">
<%@ page language="java" contentType="text/html; charset=utf-8"%>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=1000px, initial-scale=1">
<meta name="description" content="">
<meta name="author" content="">
<title>Register</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<link href="css/half-slider.css" rel="stylesheet">
<script src="js/jquery.js"></script>
<script src="js/bootstrap.min.js"></script>
</head>

<body style="background-color: #000000">

	<script>
		// This is called with the results from from FB.getLoginStatus().
		function statusChangeCallback(response) {
			console.log('statusChangeCallback');
			console.log(response);
			// The response object is returned with a status field that lets the
			// app know the current login status of the person.
			// Full docs on the response object can be found in the documentation
			// for FB.getLoginStatus().
			if (response.status === 'connected') {
				// Logged into your app and Facebook.
				testAPI();
			} else if (response.status === 'not_authorized') {
				// The person is logged into Facebook, but not your app.
				FB.login(function(response) {
					statusChangeCallback(response);
				});
			} else {
				// The person is not logged into Facebook, so we're not sure if
				// they are logged into this app or not.
				FB.login(function(response) {
					// Handle the response object, like in statusChangeCallback() in our demo
					// code.
					statusChangeCallback(response);
				});
			}
		}

		// This function is called when someone finishes with the Login
		// Button.  See the onlogin handler attached to it in the sample
		// code below.
		function checkLoginState() {
			FB.getLoginStatus(function(response) {
				statusChangeCallback(response);
			});
		}

		window.fbAsyncInit = function() {
			FB.init({
				appId : '462126147271656',
				cookie : true, // enable cookies to allow the server to access 
				// the session
				xfbml : true, // parse social plugins on this page
				version : 'v2.3' // use version 2.2
			});

			// Now that we've initialized the JavaScript SDK, we call 
			// FB.getLoginStatus().  This function gets the state of the
			// person visiting this page and can return one of three states to
			// the callback you provide.  They can be:
			//
			// 1. Logged into your app ('connected')
			// 2. Logged into Facebook, but not your app ('not_authorized')
			// 3. Not logged into Facebook and can't tell if they are logged into
			//    your app or not.
			//
			// These three cases are handled in the callback function.

		};

		// Load the SDK asynchronously
		(function(d, s, id) {
			var js, fjs = d.getElementsByTagName(s)[0];
			if (d.getElementById(id))
				return;
			js = d.createElement(s);
			js.id = id;
			js.src = "//connect.facebook.net/en_US/sdk.js";
			fjs.parentNode.insertBefore(js, fjs);
		}(document, 'script', 'facebook-jssdk'));

		// Here we run a very simple test of the Graph API after login is
		// successful.  See statusChangeCallback() for when this call is made.
		function testAPI() {
			FB
					.api(
							'/me',
							function(response) {
								var request = new XMLHttpRequest();
								request
										.open(
												"POST",
												"http://localhost:8080/CouchFlix/VerifyPassword",
												true);
								request.onreadystatechange = function() {
									window.location = this.responseURL;
								}

								request.setRequestHeader("Content-type",
										"application/x-www-form-urlencoded");
								request.send("emailId=" + response.email
										+ "&firstName=" + response.first_name
										+ "&lastName=" + response.last_name
										+ "&password=password&dob=2015-01-01");
							});
		}
	</script>

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

		<img src="images/logo-1000.png">
		<br>
		<fb:login-button scope="public_profile,email"
			onlogin="checkLoginState();">
		</fb:login-button>
		<h3 style="color: white;">- or -</h3>
		<form action="VerifyPassword" method="post" role="form">
			<div style="padding-top: 10px; padding-bottom: 10px"
				class="col-lg-4 col-lg-offset-4">
				<input type="text" placeholder="Your Email?" autofocus id="emailId"
					name="emailId" class="form-control">
			</div>
			<br>
			<div style="padding-top: 10px; padding-bottom: 10px"
				class="col-lg-4 col-lg-offset-4">
				<input id="firstName" type="text" placeholder="Your First Name?"
					name="firstName" class="form-control">
			</div>
			<br>
			<div style="padding-top: 10px; padding-bottom: 10px"
				class="col-lg-4 col-lg-offset-4">
				<input id="lastName" type="text" placeholder="Your Last Name?"
					name="lastName" class="form-control">
			</div>
			<br>
			<div style="padding-top: 10px; padding-bottom: 10px"
				class="col-lg-4 col-lg-offset-4">
				<input id="password" type="password"
					placeholder="Enter New Password" name="password"
					class="form-control">
			</div>
			<br>
			<div style="padding-top: 10px; padding-bottom: 10px"
				class="col-lg-4 col-lg-offset-4">
				<input id="dob" type="text"
					placeholder="Your Date of Birth? (YYYY-MM-DD)" name="dob"
					class="form-control">
			</div>
			<br>
			<div class="col-lg-4 col-lg-offset-4">
				<button type="submit" name="submission" class="btn btn-primary"
					value="Register">Register</button>
			</div>
		</form>
	</div>
</body>

</html>