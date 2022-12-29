  

go -- a
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

go -- b
CREATE PROC dropAllTables
AS
	DECLARE @sql NVARCHAR(MAX);
	SET @sql = N'';

	SELECT @sql = @sql + N'
	  ALTER TABLE ' + QUOTENAME(s.name) + N'.'
	  + QUOTENAME(t.name) + N' DROP CONSTRAINT '
	  + QUOTENAME(c.name) + ';'
	FROM sys.objects AS c
	INNER JOIN sys.tables AS t
	ON c.parent_object_id = t.[object_id]
	INNER JOIN sys.schemas AS s 
	ON t.[schema_id] = s.[schema_id]
	WHERE c.[type] IN ('D','C','F','PK','UQ')
	ORDER BY c.[type];

	EXEC sys.sp_executesql @sql;
	EXEC sp_msforeachtable 'DROP TABLE ?';

go -- c
create proc dropAllProceduresFunctionsViews
as
-- dropping helper functions : 

drop function dbo.getName
drop function dbo.getStadiumName
drop function dbo.getID

-- dropping all other required functions , proc and views


drop proc createAllTables				
drop proc dropAllTables					
drop proc clearAllTables				

drop view allAssocManagers				
drop view allClubRepresentatives		   
drop view allStadiumManagers			
drop view allFans						  
drop view allMatches					
drop view allTickets					  
drop view allCLubs						
drop view allStadiums					  
drop view allRequests					
		
drop proc addAssociationManager			 
drop proc addNewMatch					  
drop view clubsWithNoMatches			 
drop proc deleteMatch					   
drop proc deleteMatchesOnStadium		 
drop proc addClub						   
drop proc addTicket						 
drop proc deleteClub					   
drop proc addStadium					 
drop proc deleteStadium					   
drop proc blockFan						 
drop proc unblockFan					   
drop proc addRepresentative				 
drop function viewAvailableStadiumsOn	   
drop proc addHostRequest				 
drop function allUnassignedMatches		   
drop proc addStadiumManager				 
drop function allPendingRequests		   
drop proc acceptRequest					 
drop proc rejectRequest					   
drop proc addFan						 
drop function upcomingMatchesOfClub		   
drop function availableMatchesToAttend	 
drop proc purchaseTicket				   
drop proc updateMatchHost				 
drop view matchesPerTeam				   
drop view clubsNeverMatched			     
drop function clubsNeverPlayed             
drop function matchWithHighestAttendance 
drop function matchesRankedByAttendance    
drop function requestsFromClub           

go -- d
CREATE PROC clearAllTables 
AS
EXEC sp_MSForEachTable 'DISABLE TRIGGER ALL ON ?'
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
EXEC sp_MSForEachTable 'SET QUOTED_IDENTIFIER ON; DELETE FROM ?'
EXEC sp_MSForEachTable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'
EXEC sp_MSForEachTable 'ENABLE TRIGGER ALL ON ?'
----------------------------------------------------2.2
go -- a
create view allAssocManagers 
as 
select mn.username , u.password , mn.name
from   SportsAssociationManager mn , SystemUser u 
where mn.username = u.username

go -- b
create view allClubRepresentatives as
select u.username , u.password , c.name 
from  SystemUser u , Club c , ClubRepresentative r
where u.username = r.username
      and  r.club_ID = c.club_id 

go -- c
create view allStadiumManagers as
select u.username , u.password , m.name as manager_name, s.name as stadium_name
from  SystemUser u , StadiumManager m , Stadium s 
where u.username = m.username
      and  m.stadium_ID = s.ID

go -- d
create view allFans as
select u.username , u.password , f.name , f.national_id , f.birth_date , f.status
from SystemUser u , fan f
where u.username = f.username

go -- e
create view allMatches as
select c1.name as host_club_name , c2.name as guest_club_name , m.start_time
from Club c1 , Club c2 , Match m
where c1.club_id = m.host_club_ID
      and c2.club_id = m.guest_club_ID
		
go -- f
create view allTickets as
select c1.name as host_club_name , c2.name as guest_club_name , s.name as stadium_name, m.start_time
from Club c1 , Club c2 , Stadium s , Ticket t , Match m
where m.host_club_ID = c1.club_id
      and m.guest_club_ID = c2.club_id
	  and m.stadium_ID = s.ID
	  and m.match_ID = t.match_ID

go -- g
create view allCLubs as
select c.name , c.location
from Club c

go -- h
create view allStadiums as
select s.name , s.location , s.capacity , s.status
from Stadium s

go -- i
create view allRequests as
select rep.username as representative_user, m.username as stadium_manager_user, r.status
from ClubRepresentative rep , StadiumManager m , HostRequest r
where r.representative_ID = rep.ID
      and r.manager_ID = m.ID
----------------------------------------------------------- Helpers
GO
CREATE FUNCTION getName(@club_id INT)
RETURNS VARCHAR(20)
AS
BEGIN
DECLARE @name VARCHAR(20)
	SELECT @name = Club.name FROM Club 
			WHERE Club.club_id = @club_id
RETURN @name
END

GO
CREATE FUNCTION getStadiumName(@stad_id INT)
RETURNS VARCHAR(20)
AS
BEGIN
DECLARE @name VARCHAR(20)
	SELECT @name = S.name FROM Stadium S
			WHERE S.ID = @stad_id
RETURN @name
END

GO
CREATE FUNCTION getID(@club_name VARCHAR(20))
RETURNS INT
AS
BEGIN
DECLARE @clubID INT
	SELECT TOP 1 @clubID = club_id FROM Club 
		WHERE Club.name = @club_name
RETURN @clubID
END
-------------------------------------------------------- 2.3

go -- i
create proc addAssociationManager 
@name varchar(20) , @username varchar(20) , @password varchar(20)
as
insert into SystemUser(username , password) values 
(@username , @password)
insert into SportsAssociationManager (name , username) values 
(@name , @username )

go -- ii
CREATE PROC addNewMatch
@host_club VARCHAR(20), @guest_club VARCHAR(20), 
@start DATETIME, @end DATETIME
AS
	DECLARE @guest_id INT, @host_id INT

	SELECT TOP 1 @host_id = club_id FROM Club 
		WHERE Club.name = @host_club
	SELECT TOP 1 @guest_id = club_id FROM Club 
		WHERE Club.name = @guest_club

	INSERT INTO Match VALUES (@start, @end, @host_id, @guest_id, NULL)

go -- iii
create view clubsWithNoMatches
as
select c.name
from Club c
where (c.club_id not in (select m.host_club_ID from Match m) )
      and (c.club_id not in (select m.guest_club_ID from Match m) )

go -- iv
CREATE PROC deleteMatch
@host_club VARCHAR(20), @guest_club VARCHAR(20) --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<inputs edited
AS
	DECLARE @guest_id INT, @host_id INT

	SELECT TOP 1 @host_id = club_id FROM Club 
		WHERE Club.name = @host_club
	SELECT TOP 1 @guest_id = club_id FROM Club 
		WHERE Club.name = @guest_club

	DELETE FROM Match WHERE
		Match.host_club_ID = @host_id
		AND Match.guest_club_ID = @guest_id

go -- v
create proc deleteMatchesOnStadium
@stadium_name varchar(20)
as
declare @id_of_deleted_stadium int
select @id_of_deleted_stadium = s.ID
from Stadium s
where s.name = @stadium_name

delete from Match ---error because of hostRequest foreign key
where Match.stadium_ID = @id_of_deleted_stadium  
      and match.start_time > CURRENT_TIMESTAMP

go -- vi
CREATE PROC addClub
@club VARCHAR(20), @location VARCHAR(20)
AS
	INSERT INTO Club VALUES (@club, @location)

go -- vii
create proc addTicket
@host_name varchar(20) , @guest_name varchar(20) , @start_Time datetime
as
declare @id_of_match int
select @id_of_match = m.match_ID
from Match m , Club host , Club guest
where m.host_club_ID = host.club_id
      and m.guest_club_ID = guest.club_id
	  and host.name = @host_name
	  and guest.name = @guest_name

insert into Ticket(match_ID , status) values
(@id_of_match,1)

go -- viii
CREATE PROC deleteClub
@club VARCHAR(20)
AS
	-----//FIRST BRANCH
	--handling cascade alternatives
	UPDATE Match	SET Match.guest_club_id = NULL
		WHERE Match.guest_club_id IN 
			(SELECT club_id FROM CLUB WHERE Club.name = @club)

	--deleting corresponding requests to matches
	DELETE FROM HostRequest WHERE HostRequest.match_ID = ANY (SELECT M.match_id FROM MATCH M WHERE M.guest_club_id IS NULL OR M.host_club_id IS NULL)
	
	
	-----//SECOND BRANCH
	--|checking which Club Representative will be deleted and deleting corresponding Username and his/her requests before deleting club
	--|*Username
	DELETE FROM SystemUser WHERE SystemUser.username IN 
		(SELECT  R.username FROM ClubRepresentative R WHERE R.club_ID IN 
				(SELECT club_id FROM CLUB WHERE Club.name = @club))
	--|*Requests
	--I guess unnecassary
	DELETE FROM HostRequest WHERE HostRequest.representative_ID = 
		ANY (SELECT R.ID FROM ClubRepresentative R WHERE R.club_ID IN 
				(SELECT club_id FROM CLUB WHERE Club.name = @club))

	--|delete club finally
	DELETE FROM Club WHERE Club.name = @club

go -- ix
create proc addStadium
@stadium_name varchar(20), @stadium_location varchar(20) , @stadium_capacity int
as
insert into Stadium(name , location , capacity , status) values
(@stadium_name , @stadium_location , @stadium_capacity , 1)

go -- x
CREATE PROC deleteStadium
@stadium VARCHAR(20)
AS
	--The stadium Manager will be automatically deleted using the cascading calls BUT,
	-- - - - - We'll delete the corresponding username and pass from System User
	DELETE FROM SystemUser WHERE SystemUser.username IN 
		(SELECT username FROM StadiumManager SM INNER JOIN Stadium S
				ON SM.stadium_ID = S.ID
			WHERE S.name = @stadium
		)
	
	DELETE FROM Stadium WHERE Stadium.name = @stadium

go -- xi
create proc blockFan
@fan_national_id varchar(20)
as
update fan
set status = 0 where national_id = @fan_national_id

go -- xii
CREATE PROC unblockFan
@national_ID VARCHAR(20)
AS
	UPDATE Fan
		SET Fan.status = 1
		WHERE Fan.national_id = @national_ID

go -- xiii
create proc addRepresentative 
@rep_name varchar(20) , @club_name varchar(20) , @user varchar(20) , @pass varchar(20)
as
insert into SystemUser(username , password ) values
(@user , @pass)
declare @id_of_given_club int
select @id_of_given_club = c.club_id
from club c
where c.name = @club_name
insert into ClubRepresentative(username,name , club_ID) values
(@user,@rep_name , @id_of_given_club)

go -- xiv
CREATE FUNCTION viewAvailableStadiumsOn(@date_time DATETIME)
RETURNS @stadiums TABLE(
					name VARCHAR(20),
					location VARCHAR(20),
					capacity INT)
AS
BEGIN
	INSERT INTO @stadiums
		SELECT S.name,S.location,S.capacity FROM Stadium S
			WHERE S.status = 1
	RETURN
END

go -- xv 

--DROP PROCEDURE addHostRequest
create proc addHostRequest
@club_name varchar(20) , @stadium_name varchar(20), @start_time datetime
as 

declare @club_id int
select @club_id = c.club_id 
from Club c
where c.name = @club_name 

declare @rep_id int
select @rep_id = rep.ID
from ClubRepresentative rep
where rep.club_ID = @club_id

declare @stadium_id int
select @stadium_id = s.ID
from Stadium s
where s.name = @stadium_name

declare @manager_id int
select @manager_id = m.ID
from StadiumManager m
where m.stadium_ID = @stadium_id

declare @match_id int
select @match_id = mt.match_ID
from Match mt
where mt.host_club_ID = @club_id
      and mt.start_time = @start_time
	  

insert into HostRequest(representative_ID , manager_ID , match_ID) values -- no status mentioned, left for deault value, whether 'null' or 'unhandled'
(@rep_id , @manager_id , @match_id)

go -- xvi
CREATE FUNCTION  allUnassignedMatches(@club VARCHAR(20))
RETURNS @matches TABLE(
					guestClubName VARCHAR(20),
					start_time DATETIME)
AS
BEGIN
	INSERT INTO @matches
		SELECT C.name, M.start_time FROM Match M INNER JOIN Club C
				ON M.guest_club_ID = C.club_id
			WHERE M.stadium_ID IS NULL

	RETURN
END

go -- xvii
create proc addStadiumManager 
@manager_name varchar(20) , @stadium_name varchar(20), @user varchar(20) , @pass varchar(20) 
as
insert into SystemUser(username , password ) values
(@user , @pass)

declare @stadium_id int
select @stadium_id = s.id
from Stadium s
where s.name = @stadium_name

insert into StadiumManager(name , stadium_ID , username ) values
(@manager_name , @stadium_id , @user)

go -- xviii
CREATE FUNCTION allPendingRequests(@manager_username VARCHAR(20)) 
RETURNS @requests TABLE(
					clubRepresentativeName VARCHAR(20),
					guestClubName VARCHAR(20),
					start_time DATETIME)
AS
BEGIN
	
	INSERT INTO @requests
		SELECT CR.name, C.name,M.start_time FROM HostRequest R
			INNER JOIN ClubRepresentative CR ON R.representative_ID = CR.ID
			INNER JOIN Match M ON M.match_ID = R.match_ID
			INNER JOIN Club C ON M.guest_club_ID = C.club_id
			WHERE R.status IS NULL

RETURN
END

go -- xix

--DROP PROCEDURE acceptRequest
create proc acceptRequest
@manager_username varchar(20) , @host_name varchar(20) , @guest_name varchar(20) , @start_time datetime
as

declare @host_id int
select @host_id = c.club_id
from Club c
where c.name = @host_name

declare @rep_id int
select @rep_id = rep.ID
from ClubRepresentative rep
where rep.club_ID = @host_id

declare @manager_id int
select @manager_id = m.ID
from StadiumManager m
where m.username = @manager_username

declare @guest_id int
select @guest_id = cl.club_id
from Club cl
where cl.name = @guest_name

declare @stadium_id int
select @stadium_id = s.ID
from stadium s , StadiumManager mn
where s.ID = mn.stadium_ID 
      and mn.ID = @manager_id

declare @match_id int
select @match_id = mtch.match_ID
from match mtch
where mtch.start_time = @start_time 
      and mtch.host_club_ID = @host_id
	  and mtch.guest_club_ID = @guest_id
	  and mtch.stadium_ID = @stadium_id

update HostRequest
set status = 'Accepted' where representative_ID = @host_id and manager_ID = @manager_id and match_ID = @match_id
update Match
set stadium_ID = @stadium_id where match_ID = @match_id

-- inserting tickets for the match
declare @numOfTickets int
select @numOfTickets = s.capacity
from stadium s
where s.ID = @stadium_id

declare @counter int = 0;
WHILE  @counter < @numOfTickets
begin
	exec dbo.addTicket @host_name , @guest_name , @start_time
	set @counter = @counter + 1
end

go -- xx

--DROP PROCEDURE rejectRequest
CREATE PROC rejectRequest
@manager_username VARCHAR(20),
@host_club VARCHAR(20), @guest_club VARCHAR(20), 
@start DATETIME
AS
	DECLARE @guest_id INT, @host_id INT, @match_id INT, @manager_id INT

	SELECT TOP 1 @host_id = club_id FROM Club 
		WHERE Club.name = @host_club
	SELECT TOP 1 @guest_id = club_id FROM Club 
		WHERE Club.name = @guest_club
	SELECT TOP 1 @match_id = match_ID FROM Match M
		WHERE M.guest_club_ID = @guest_id
			AND M.host_club_ID = @host_id
			AND M.start_time = @start

	SELECT TOP 1 @manager_id = SM.ID FROM StadiumManager SM
		WHERE SM.username = @manager_username

	UPDATE HostRequest 
		SET status = 'Rejected'
		WHERE HostRequest.match_ID = @match_id
			AND HostRequest.manager_ID = @manager_id

go -- xxi
create proc addFan 
@fan_name varchar(20),@fan_user_name varchar(20) , @fan_password varchar(20) , @fan_national_id varchar(20) , @fan_birth_date datetime , @fan_address varchar(20) , @fan_phone_number int 
as
insert into SystemUser(username , password ) values
(@fan_user_name , @fan_password)
insert into Fan(username ,national_id , name , birth_date , address , phone_no , status) values
(@fan_user_name , @fan_national_id , @fan_name , @fan_birth_date , @fan_address , @fan_phone_number ,1)

go -- xxii

--DROP FUNCTION upcomingMatchesOfClub
CREATE FUNCTION upcomingMatchesOfClub(@club_name VARCHAR(20)) 
RETURNS @upcomingMatches TABLE(host_club VARCHAR(20),
						guest_club VARCHAR(20),
						start_time DATETIME,
						end_time DATETIME,
						stadium VARCHAR(20)
						)
AS
BEGIN
	DECLARE @cid INT

	SELECT @cid = dbo.getID(@club_name)

	INSERT INTO @upcomingMatches
		SELECT dbo.getName(M.host_club_ID) AS Host 
			 , dbo.getName(M.guest_club_ID) AS Guest
			 , M.start_time,M.end_time, dbo.getStadiumName(M.stadium_ID) AS Stadium
		FROM Match M
			WHERE M.start_time >= CURRENT_TIMESTAMP
				AND (M.host_club_ID = @cid OR M.guest_club_ID = @cid)
RETURN
END
GO
 -- xxiii
create function availableMatchesToAttend 
(@start_time datetime)
RETURNS @result TABLE(host varchar(20) , guest varchar(20) , start_tim datetime , stadName varchar(20))
AS 
begin
insert into @result
		select c1.name as hostName, c2.name as guestName, m.start_time , s.name as stadiumName
        from Club c1 , Club c2 , Match m , Stadium s
		where c1.club_id = m.host_club_ID
		      and c2.club_id = m.guest_club_ID
			  and m.stadium_ID = s.ID
			  and m.start_time > @start_time
			  and exists (select * from Ticket t
			              where t.status = 1
						  and t.match_ID = m.match_ID)
return
end

go -- xxiv
CREATE PROC purchaseTicket
@national_id VARCHAR(20),@host_club VARCHAR(20), @guest_club VARCHAR(20), 
@start DATETIME
AS
	DECLARE @guest_id INT, @host_id INT, @match_id INT, @ticket_id INT

	SELECT TOP 1 @host_id = club_id FROM Club 
		WHERE Club.name = @host_club
	SELECT TOP 1 @guest_id = club_id FROM Club 
		WHERE Club.name = @guest_club
	SELECT TOP 1 @match_id = match_ID FROM Match M
		WHERE M.guest_club_ID = @guest_id
			AND M.host_club_ID = @host_id
			AND M.start_time = @start
	-- find a ticket that's not bought already
	IF EXISTS( SELECT T.ID FROM Ticket T WHERE T.status = 1 AND T.match_ID = @match_id)
	BEGIN
		--get the first available ticket for that match
		SELECT TOP 1 @ticket_id = T.ID 
			FROM Ticket T WHERE T.status = 1 AND T.match_ID = @match_id
		--mark the ticket as sold
		UPDATE Ticket SET status = 0 WHERE Ticket.ID = @ticket_id
		--insert the ticket into the transactions table
		INSERT INTO TicketBuyingTransactions VALUES(@national_id, @ticket_id)
	END

	ELSE
	BEGIN
		PRINT 'No available Tickets to buy'
	END

go -- xxv
create proc updateMatchHost
@host_name varchar(20) , @guest_name varchar(20) , @start_time datetime
as

declare @old_host_id int
select @old_host_id = c1.club_id
from club c1
where c1.name = @host_name

declare @old_guest_id int
select @old_guest_id = c2.club_id
from club c2
where c2.name = @guest_name

declare @match_id int
select @match_id = m.match_ID
from Match m
where m.host_club_ID = @old_host_id
      and m.guest_club_ID = @old_guest_id
	  and m.start_time = @start_time

update Match
set host_club_ID = @old_guest_id where match_ID = @match_id
update Match
set guest_club_ID = @old_host_id where match_ID = @match_id

go -- xxvi
CREATE VIEW matchesPerTeam AS
	SELECT C.name, COUNT(M.match_ID) AS matches FROM Club C 
		INNER JOIN Match M ON M.guest_club_ID = C.club_id 
							OR M.host_club_ID = C.club_id
		WHERE CURRENT_TIMESTAMP >= M.end_time
		GROUP BY C.name 

go -- xxvii
create view clubsNeverMatched
as
select c1.name as first_club_name , c2.name as second_club_name
from Club c1 , Club c2
where not exists (select m.match_ID
                 from Match m
			     where( (m.host_club_ID = c1.club_id and m.guest_club_ID = c2.club_id) 	or (m.host_club_ID = c2.club_id and m.guest_club_ID = c1.club_id)  )									 
				  and m.start_time < CURRENT_TIMESTAMP
				 ) 
      and c1.club_id > c2.club_id

go -- xxviii
CREATE FUNCTION clubsNeverPlayed(@club_name VARCHAR(20))
RETURNS @clubs TABLE(club_name VARCHAR(20))
AS
BEGIN
	
	DECLARE @cid INT

	SELECT TOP 1 @cid = club_id FROM Club 
		WHERE Club.name = @club_name

	INSERT INTO @clubs
		SELECT C.name FROM Club C
		WHERE C.name <> @club_name
		EXCEPT(
			(
				SELECT C2.name FROM 
				Match M INNER JOIN Club C2 
						ON C2.club_id = M.host_club_ID
					WHERE M.guest_club_ID = @cid
			)UNION (
				SELECT C3.name FROM 
				Match M1 INNER JOIN Club C3 
						ON C3.club_id = M1.guest_club_ID
					WHERE M1.host_club_ID = @cid
			)

		)

RETURN
END

go -- xxix  
CREATE FUNCTION matchWithHighestAttendance()
RETURNS @matches TABLE(host VARCHAR(20), guest VARCHAR(20))
AS
BEGIN
     insert into @matches	    

			  select innerTable.host_team , innerTable.guest_team 
			  from (
					SELECT dbo.getName(M.host_club_ID) AS host_team, dbo.getName(M.guest_club_ID) AS guest_team, M.start_time,COUNT(T.ID) AS tickets 
					FROM Match M INNER JOIN Ticket T ON T.match_ID = M.match_ID AND T.status = 0
					GROUP BY dbo.getName(M.host_club_ID), dbo.getName(M.guest_club_ID), M.start_time
				   )as innerTable 
		      where tickets >= all
							    (
		   						select innerTable2.tickets2
								from (
									SELECT dbo.getName(M2.host_club_ID) AS host_team2, dbo.getName(M2.guest_club_ID) AS guest_team2, M2.start_time,COUNT(T2.ID) AS tickets2 
									FROM Match M2 INNER JOIN Ticket T2 ON T2.match_ID = M2.match_ID AND T2.status = 0
									GROUP BY dbo.getName(M2.host_club_ID), dbo.getName(M2.guest_club_ID), M2.start_time
									)as innerTable2 
								)
RETURN
END

go -- xxx
CREATE FUNCTION matchesRankedByAttendance()
RETURNS @matches TABLE(host VARCHAR(20), guest VARCHAR(20))
AS
BEGIN
	INSERT INTO @matches
		SELECT host_team, guest_team FROM
			(
				SELECT dbo.getName(M.host_club_ID) AS host_team, dbo.getName(M.guest_club_ID) AS guest_team, M.match_ID,COUNT(T.ID) AS tickets 
				FROM Match M INNER JOIN Ticket T ON T.match_ID = M.match_ID AND T.status = 0
				where M.end_time < CURRENT_TIMESTAMP -- edited
				GROUP BY dbo.getName(M.host_club_ID), dbo.getName(M.guest_club_ID), M.match_ID
			) AS match_ticket
			ORDER BY tickets DESC
			offset 0 rows

RETURN
END
	
go -- xxxi
create function requestsFromClub
(@stadium_name varchar(20) ,  @host_name varchar(20) )
returns table
as
return( with match_ids (ids)
        as
		(select hr.match_ID
		 from HostRequest hr , ClubRepresentative rep ,StadiumManager mn , Club c ,Stadium s  
		 where (hr.representative_ID = rep.ID
		        and hr.manager_ID = mn.ID
		        and rep.club_ID = c.club_id
				and mn.stadium_ID = s.ID
			    and c.name = @host_name
				and s.name = @stadium_name
		       )
		)
        select c1.name as host , c2.name as guest
        from Club c1 , Club c2 , Match m , match_ids mt
		where c1.club_id = m.host_club_ID
		      and c2.club_id = m.guest_club_ID
			  and m.match_ID = mt.ids
        )



