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
			CONSTRAINT C_FK FOREIGN KEY(club_ID) REFERENCES Club
				ON DELETE CASCADE		ON UPDATE CASCADE,
		username VARCHAR(20),
			CONSTRAINT CR_U_FK FOREIGN KEY(username) REFERENCES SystemUser
				ON DELETE CASCADE		ON UPDATE CASCADE
	)

	CREATE TABLE StadiumManager (
		ID  INT PRIMARY KEY IDENTITY,
		name VARCHAR(20),
		stadium_ID INT,
			CONSTRAINT SM_S_FK FOREIGN KEY(stadium_ID) REFERENCES Stadium
				 ON DELETE CASCADE		ON UPDATE CASCADE,
		username VARCHAR(20),
			CONSTRAINT SM_U_FK FOREIGN KEY(username) REFERENCES SystemUser 
				ON DELETE CASCADE		ON UPDATE CASCADE
	)

	--Others ---------------------

	CREATE TABLE Match (
		match_ID  INT PRIMARY KEY IDENTITY,
		start_time DATETIME,
		end_time DATETIME,
		host_club_ID INT, 
			CONSTRAINT H_FK FOREIGN KEY(host_club_ID) REFERENCES Club  
				ON DELETE SET NULL		ON UPDATE SET NULL,
		guest_club_ID INT, 
			CONSTRAINT G_FK FOREIGN KEY(guest_club_ID) REFERENCES Club
				 ON DELETE NO ACTION	ON UPDATE NO ACTION,
		stadium_ID INT,
			CONSTRAINT M_S_FK FOREIGN KEY(stadium_ID) REFERENCES Stadium
				 ON DELETE CASCADE		ON UPDATE CASCADE
	)

	CREATE TABLE HostRequest (
		ID  INT PRIMARY KEY IDENTITY,
		representative_ID INT,
			CONSTRAINT R_FK FOREIGN KEY (representative_id) REFERENCES ClubRepresentative
				ON DELETE NO ACTION		ON UPDATE NO ACTION,
		manager_ID INT,
			CONSTRAINT MAN_FK FOREIGN KEY(manager_id) REFERENCES StadiumManager
				 ON DELETE CASCADE		ON UPDATE CASCADE,
		match_ID INT,
			CONSTRAINT MAT_FK FOREIGN KEY(match_id) REFERENCES Match
				 ON DELETE NO ACTION	ON UPDATE NO ACTION,
		status VARCHAR(20) NOT NULL DEFAULT 'Unhandled'	 CHECK (status IN ('Unhandled','Accepted','Rejected'))	--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<edited
	)


	CREATE TABLE Ticket (
		ID  INT PRIMARY KEY IDENTITY,
		status BIT,
		match_ID INT, 
			CONSTRAINT T_M_FK	FOREIGN KEY(match_id) REFERENCES Match
				 ON DELETE CASCADE		ON UPDATE CASCADE
	)

	CREATE TABLE TicketBuyingTransactions (
		fan_national_ID VARCHAR(20),
			CONSTRAINT F_FK FOREIGN KEY(fan_national_ID) REFERENCES Fan
				 ON DELETE CASCADE		ON UPDATE CASCADE,
		ticket_ID INT,
			CONSTRAINT T_FK FOREIGN KEY(ticket_ID) REFERENCES Ticket
				 ON DELETE CASCADE		ON UPDATE CASCADE,

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

