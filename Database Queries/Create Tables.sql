--CREATE DATABASE Project;
--USE Project;
--DROP DATABASE Project;
--DROP PROCEDURE createAllTables;

GO
CREATE PROC createAllTables AS
	CREATE TABLE Club (
		club_id INT PRIMARY KEY IDENTITY,
		name VARCHAR(20),
		location VARCHAR(20)
	)

	CREATE TABLE Stadium (
		ID INT PRIMARY KEY IDENTITY,
		name VARCHAR(20),
		location VARCHAR(20),
		capacity INT,
		status BIT
	)

	--SuperEntity

	CREATE TABLE SystemUser (
		username VARCHAR(20) PRIMARY KEY,
		password VARCHAR(20)
	)

	--Subclasses

	CREATE TABLE Fan (
		national_id VARCHAR(20) PRIMARY KEY,
		name VARCHAR(20),
		birth_date DATE,
		address VARCHAR(20),
		phone_no INT,		--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<edited
		status BIT,
		username VARCHAR(20),
			CONSTRAINT F_U_FK FOREIGN KEY(username) REFERENCES SystemUser ON DELETE CASCADE		ON UPDATE CASCADE
	)


	CREATE TABLE SystemAdmin (
		ID  INT PRIMARY KEY IDENTITY,
		name VARCHAR(20),
		username VARCHAR(20),
			CONSTRAINT SA_U_FK FOREIGN KEY(username) REFERENCES SystemUser ON DELETE CASCADE		ON UPDATE CASCADE
	)

	CREATE TABLE SportsAssociationManager (
		ID  INT PRIMARY KEY IDENTITY,
		name VARCHAR(20),
		username VARCHAR(20),
			CONSTRAINT SAM_U_FK FOREIGN KEY(username) REFERENCES SystemUser ON DELETE CASCADE		ON UPDATE CASCADE
	)

	CREATE TABLE ClubRepresentative (
		ID  INT PRIMARY KEY IDENTITY,
		name VARCHAR(20),
		club_ID INT, 
			CONSTRAINT C_FK FOREIGN KEY(club_ID) REFERENCES Club,
		username VARCHAR(20),
			CONSTRAINT CR_U_FK FOREIGN KEY(username) REFERENCES SystemUser ON DELETE CASCADE		ON UPDATE CASCADE
	)

	CREATE TABLE StadiumManager (
		ID  INT PRIMARY KEY IDENTITY,
		name VARCHAR(20),
		stadium_ID INT,
			CONSTRAINT SM_S_FK FOREIGN KEY(stadium_ID) REFERENCES Stadium,
		username VARCHAR(20),
			CONSTRAINT SM_U_FK FOREIGN KEY(username) REFERENCES SystemUser ON DELETE CASCADE		ON UPDATE CASCADE
	)

	--Others ---------------------

	CREATE TABLE Match (
		match_ID  INT PRIMARY KEY IDENTITY,
		start_time DATETIME,
		end_time DATETIME,
		host_club_ID INT, 
			CONSTRAINT H_FK FOREIGN KEY(host_club_ID) REFERENCES Club,
		guest_club_ID INT, 
			CONSTRAINT G_FK FOREIGN KEY(guest_club_ID) REFERENCES Club,
		stadium_ID INT,
			CONSTRAINT M_S_FK FOREIGN KEY(stadium_ID) REFERENCES Stadium
	)

	CREATE TABLE HostRequest (
		ID  INT PRIMARY KEY IDENTITY,
		representative_ID INT,
			CONSTRAINT R_FK FOREIGN KEY (representative_id) REFERENCES ClubRepresentative,
		manager_ID INT,
			CONSTRAINT MAN_FK FOREIGN KEY(manager_id) REFERENCES StadiumManager,
		match_ID INT,
			CONSTRAINT MAT_FK FOREIGN KEY(match_id) REFERENCES Match,
		status VARCHAR(20) NOT NULL DEFAULT 'Unhandled'	 CHECK (status IN ('Unhandled','Accepted','Rejected'))	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<edited
	)


	CREATE TABLE Ticket (
		ID  INT PRIMARY KEY IDENTITY,
		status BIT,
		match_ID INT, 
			CONSTRAINT T_M_FK	FOREIGN KEY(match_id) REFERENCES Match
	)

	CREATE TABLE TicketBuyingTransactions (
		fan_national_ID VARCHAR(20),
			CONSTRAINT F_FK FOREIGN KEY(fan_national_ID) REFERENCES Fan,
		ticket_ID INT,
			CONSTRAINT T_FK FOREIGN KEY(ticket_ID) REFERENCES Ticket,

		CONSTRAINT PK_ID PRIMARY KEY(fan_national_ID, ticket_ID)
	)

GO


--JUST CHECKING ALL TABLES ARE THERE
---------------------- higlight and press ctrl+K+U to remove comment,
----------------------- and ctrl+K+C to comment all lines again
--SELECT * FROM SystemAdmin;
--SELECT * FROM SystemUser;
--SELECT * FROM Fan;
--SELECT * FROM StadiumManager;
--SELECT * FROM ClubRepresentative;
--SELECT * FROM SportsAssociationmanager;
--SELECT * FROM Club;
--SELECT * FROM HostRequest;
--SELECT * FROM Stadium;
--SELECT * FROM TicketBuyingTransactions;
--SELECT * FROM Match;
--SELECT * FROM Ticket;



--go
--DROP PROCEDURE insertRecords
go
create proc insertRecords as -- just for us,will delete it before submission


insert into Club values
('club name 1' , 'club location 1'),
('club name 2' , 'club location 2'),
('club name 3' , 'club location 3'),
('club name 4' , 'club location 4'),
('club name 5' , 'club location 5'),
('club name 6' , 'club location 6'),
('club name 7' , 'club location 7'),
('club name 8' , 'club location 8'),
('club name 9' , 'club location 9'),
('club name 10' , 'club location 10')



insert into Stadium (name , location , capacity , status) values
('stadium name 1' , 'stadium location 1' , 1000 , 0),
('stadium name 2' , 'stadium location 2' , 2000 , 0),
('stadium name 3' , 'stadium location 3' , 3000 , 0),
('stadium name 4' , 'stadium location 4' , 4000 , 0),
('stadium name 5' , 'stadium location 5' , 5000 , 1)



insert into SystemUser(username , password) values
('user1' , 'pass1'),
('user2' , 'pass2'),
('user3' , 'pass3'),
('user4' , 'pass4'),
('user5' , 'pass5'),
('user6' , 'pass6'),
('user7' , 'pass7'),
('user8' , 'pass8'),
('user9' , 'pass9'),
('user10' , 'pass10'),
('user11' , 'pass11'),
('user12' , 'pass12'),
('user13' , 'pass13'),
('user14' , 'pass14'),
('user15' , 'pass15'),
('user16' , 'pass16'),
('user17' , 'pass17'),
('user18' , 'pass18'),
('user19' , 'pass19'),
('user20' , 'pass20'),
('user21' , 'pass21'),
('user22' , 'pass22'),
('user23' , 'pass23'),
('user24' , 'pass24'),
('user25' , 'pass25'),
('user26' , 'pass26'),
('user27' , 'pass27'),
('user28' , 'pass28'),
('user29' , 'pass29'),
('user30' , 'pass30'),
('user31' , 'pass31'),
('user32' , 'pass32'),
('user33' , 'pass33'),
('user34' , 'pass34'),
('user35' , 'pass35'),
('user36' , 'pass36'),
('user37' , 'pass37'),
('user38' , 'pass38'),
('user39' , 'pass39'),
('user40' , 'pass40')

insert into SystemAdmin (name , username) values
('admin name 1', 'user1'),
('admin name 2', 'user2'),
('admin name 3', 'user3'),
('admin name 4', 'user4'),
('admin name 5', 'user5')

insert into SportsAssociationManager(name , username) values
('assoc manager name 1' , 'user6'),
('assoc manager name 2' , 'user7'),
('assoc manager name 3' , 'user8'),
('assoc manager name 4' , 'user9'),
('assoc manager name 5' , 'user10')


insert into ClubRepresentative (name , club_ID , username) values
('club rep name 1' , 1 , 'user11'),
('club rep name 2' , 2 , 'user12'),
('club rep name 3' , 3 , 'user13'),
('club rep name 4' , 4 , 'user14'),
('club rep name 5' , 5 , 'user15'),
('club rep name 6' , 6 , 'user16'),
('club rep name 7' , 7 , 'user17'),
('club rep name 8' , 8 , 'user18'),
('club rep name 9' , 9 , 'user19'),
('club rep name 10' , 10 , 'user20')

insert into StadiumManager (name , stadium_ID , username ) values
('stad manager name 1' , 1 , 'user21'),
('stad manager name 2' , 2 , 'user22'),
('stad manager name 3' , 3 , 'user23'),
('stad manager name 4' , 4 , 'user24'),
('stad manager name 5' , 5 , 'user25')

insert into fan(national_id , name , birth_date , address , phone_no , status , username) values
(12345, 'fan name 1' , '1995-1-1' , 'fan address 1' , 'fan phone num 1' , 1 , 'user26'),
(49871, 'fan name 2' , '1995-2-12' , 'fan address 2' , 'fan phone num 2' , 1 , 'user27'),
(28456, 'fan name 3' , '1995-3-3' , 'fan address 3' , 'fan phone num 3' , 1 , 'user28'),
(98563, 'fan name 4' , '1995-4-4' , 'fan address 4' , 'fan phone num 4' , 1 , 'user29'),
(67349, 'fan name 5' , '1995-5-13' , 'fan address 5' , 'fan phone num 5' , 1 , 'user30'),
(87340, 'fan name 6' , '1996-6-14' , 'fan address 6' , 'fan phone num 6' , 1 , 'user31'),
(98778, 'fan name 7' , '1996-7-15' , 'fan address 7' , 'fan phone num 7' , 1 , 'user32'),
(24908, 'fan name 8' , '1996-8-22' , 'fan address 8' , 'fan phone num 8' , 1 , 'user33'),
(32598, 'fan name 9' , '1996-9-17' , 'fan address 9' , 'fan phone num 9' , 1 , 'user34'),
(10987, 'fan name 10' , '1996-10-19' , 'fan address 10' , 'fan phone num 10' , 1 , 'user35'),
(34587, 'fan name 11' , '1997-11-20' , 'fan address 11' , 'fan phone num 11' , 1 , 'user36'),
(24567, 'fan name 12' , '1997-12-2' , 'fan address 12' , 'fan phone num 12' , 1 , 'user37'),
(24769, 'fan name 13' , '1997-1-7' , 'fan address 13' , 'fan phone num 13' , 1 , 'user38'),
(25879, 'fan name 14' , '1997-2-4' , 'fan address 14' , 'fan phone num 14' , 0 , 'user39'),
(10485, 'fan name 15' , '1997-3-1' , 'fan address 15' , 'fan phone num 15' , 0 , 'user40')


insert into match (start_time , end_time , host_club_ID , guest_club_ID , stadium_ID) values
('10/15/2004 10:00:00' , '10/15/2004 11:30:00' , 1 , 2 , 1),
('9/14/2005 10:00:00' , '9/14/2005 11:30:00' , 3 , 4 , 2),
('8/13/2006 10:00:00' , '8/13/2006 11:30:00' , 5 , 6 , 3),
('7/12/2023 10:00:00' , '7/12/2023 11:30:00' , 7 , 8 , 4),
('6/11/2024 10:00:00' , '6/11/2024 11:30:00' , 1 , 3 , 1),
('5/10/2024 10:00:00' , '5/10/2024 11:30:00' , 2 , 4 , 2),
('4/9/2025 10:00:00' , '4/9/2025 11:30:00' , 3 , 1 , 4),
('3/8/2025 10:00:00' , '3/8/2025 11:30:00' , 5 , 8 , 4),

('5/12/2010 10:00:00' , '5/12/2010 11:30:00' , 1 , 3 , null),
('7/6/2010 10:00:00' , '7/6/2010 11:30:00' , 3 , 2 , null)


insert into HostRequest(representative_ID , manager_ID , match_ID , status) values
(1 , 1 , 1 ,1), -- 1 : accepted , 0 : rejected , null : unhandled
(3 , 2 , 2 ,1),
(5 , 3 , 3 ,1),
(7 , 4 , 4 ,1),
(1 , 1 , 5 ,1),
(2 , 2 , 6 ,1),
(3 , 4 , 7 ,1),
(5 , 4 , 8 ,1),

(1 , 1 , 9 ,0),
(3 , 2 , 10 ,null)

insert into Ticket(status , match_ID ) values
(0 , 1),
(0 , 1),
(0 , 2),
(0 , 3),
(0 , 3),
(1 , 3),
(1 , 4),
(1 , 5),
(1 , 6),
(1 , 6)

insert into TicketBuyingTransactions(fan_national_ID , ticket_ID) values
(12345, 1 ),
(49871, 2),
(28456,  3),
(98563,  4),
(67349,  5)

go
