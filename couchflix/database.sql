CREATE DATABASE couchflix;

USE couchflix;

CREATE TABLE media (
id int primary key auto_increment,
moviedb_id int not null
);

CREATE TABLE genre (
id int primary key auto_increment,
genre varchar(20) not null
);

CREATE TABLE media_genre (
id int primary key auto_increment,
media_id int not null,
genre_id int not null,
foreign key (media_id) references media(id),
foreign key (genre_id) references genre(id)
);

CREATE TABLE `status` (
id int primary key auto_increment,
status varchar(20) not null
);

CREATE TABLE company (
id int primary key auto_increment,
name varchar(100) not null,
logo_path varchar(100),
homepage varchar(100),
headquaters varchar(100),
description varchar(2000)
);

CREATE TABLE media_company (
id int primary key auto_increment,
media_id int not null,
company_id int not null,
foreign key (media_id) references media(id),
foreign key (company_id) references company(id)
);

CREATE TABLE movie (
id int not null,
backdrop_path varchar(100),
imdb_id varchar(20),
overview varchar(2000),
poster_path varchar(100),
release_date date,
status_id int,
tagline varchar(100),
title varchar(100),
foreign key (id) references media(id),
foreign key (status_id) references `status`(id)
);

CREATE TABLE tv (
id int not null,
backdrop_path varchar(100),
first_air_date date,
homepage varchar(100),
last_air_date date,
number_of_episodes int,
number_of_seasons int,
`name` varchar(100),
overview varchar(2000),
poster_path varchar(100),
status_id int,
foreign key (id) references media(id),
foreign key (status_id) references `status`(id)
);

CREATE TABLE person (
id int primary key,
`name` varchar(100),
homepage varchar(100),
birthday date,
deathday date,
biography varchar(2000),
place_of_birth varchar(100),
profile_path varchar(100)
);

CREATE TABLE cast (
id int primary key auto_increment,
person_id int,
media_id int,
`character` varchar(100),
poster_path varchar(100),
`name` varchar(100),
foreign key (media_id) references media(id)
);

CREATE TABLE crew (
id int primary key auto_increment,
person_id int,
media_id int,
department varchar(100),
job varchar(100),
poster_path varchar(100),
`name` varchar(100),
foreign key (media_id) references media(id)
);


CREATE TABLE user_info (
email varchar(50) primary key,
firstName varchar(30) not null,
lastName varchar(30),
DateOfBirth Date not null,
password_field varchar(100) not null,
enabled bool,
isAdmin bool
);


CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_comment` varchar(500) DEFAULT NULL,
  `user_time` timestamp NULL DEFAULT NULL,
  `media_id` int(11) NOT NULL,
  `comment_flag` int(11) DEFAULT NULL,
  `user_email` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `movie2comments_idx` (`media_id`),
  KEY `user2comments_idx` (`user_email`),
  CONSTRAINT `media2comments` FOREIGN KEY (`media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user2comments` FOREIGN KEY (`user_email`) REFERENCES `user_info` (`email`) ON DELETE NO ACTION ON UPDATE NO ACTION
);


CREATE TABLE ratings (
  id int(11) NOT NULL AUTO_INCREMENT,
  user_email varchar(45) NOT NULL,
  user_rating int(11) DEFAULT NULL,
  media_id int(11) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY onerate (user_email,media_id),
  KEY rating2user_idx (user_email),
  KEY ratings2movie_idx (media_id),
  CONSTRAINT rating2user FOREIGN KEY (user_email) REFERENCES user_info (email) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT ratings2media FOREIGN KEY (media_id) REFERENCES media (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `user_list` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_email` VARCHAR(45) NOT NULL,
  `media_id` INT NOT NULL,
  `list_value` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `listconstraint` (`user_email`, `media_id`),
  CONSTRAINT `movie2list`
    FOREIGN KEY (`media_id`)
    REFERENCES `couchflix`.`media` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `user2list`
    FOREIGN KEY (`user_email`)
    REFERENCES `couchflix`.`user_info` (`email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
    
CREATE TABLE follows (
id int auto_increment primary key,
user_email varchar(50) not null,
follow_email varchar(50) not null,
FOREIGN KEY (user_email) REFERENCES user_info(email) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (follow_email) REFERENCES user_info(email) ON DELETE CASCADE ON UPDATE CASCADE);