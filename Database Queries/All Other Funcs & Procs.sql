---HELPERS
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

GO

---ii

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
GO
---iv
--needs to be checked in terms of input variables

--DROP PROCEDURE deleteMatch
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
GO
---vi

CREATE PROC addClub
@club VARCHAR(20), @location VARCHAR(20)
AS
	INSERT INTO Club VALUES (@club, @location)
GO
---viii

CREATE PROC deleteClub
@club VARCHAR(20)
AS
	DELETE FROM Club WHERE Club.name = @club
GO
---x

CREATE PROC deleteStadium
@stadium VARCHAR(20)
AS
	DELETE FROM Stadium WHERE Stadium.name = @stadium
GO
---xii

CREATE PROC unblockFan
@national_ID VARCHAR(20)
AS
	UPDATE Fan
		SET Fan.status = 1
		WHERE Fan.national_id = @national_ID
GO
---xiv

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
	
GO
---xvi

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
	
GO
---xviii

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

GO
---xx

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
		SET status = 0
		WHERE HostRequest.match_ID = @match_id
			AND HostRequest.manager_ID = @manager_id

GO
---xxii

CREATE FUNCTION upcomingMatchesOfClub(@club_name VARCHAR(20)) 
RETURNS @upcomingMatches TABLE(host_club VARCHAR(20),
						guest_club VARCHAR(20),
						start_time DATETIME,
						stadium VARCHAR(20)
						)
AS
BEGIN
	DECLARE @cid INT

	SELECT @cid = dbo.getID(@club_name)

	INSERT INTO @upcomingMatches
		SELECT dbo.getName(M.host_club_ID) AS Host 
			 , dbo.getName(M.guest_club_ID) AS Guest
			 , M.start_time, dbo.getStadiumName(M.stadium_ID) AS Stadium
		FROM Match M
			WHERE M.start_time >= CURRENT_TIMESTAMP
				AND (M.host_club_ID = @cid OR M.guest_club_ID = @cid)
RETURN
END
GO
---xxiv

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

GO
--xxvi

CREATE VIEW matchesPerTeam AS
	SELECT C.name, COUNT(M.match_ID) AS matches FROM Club C 
		INNER JOIN Match M ON M.guest_club_ID = C.club_id 
							OR M.host_club_ID = C.club_id
		WHERE CURRENT_TIMESTAMP >= M.end_time
		GROUP BY C.name 

GO
---xxviii

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
GO
---xxx

--DROP FUNCTION matchesRankedByAttendance
CREATE FUNCTION matchesRankedByAttendance()--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<edited
RETURNS @matches TABLE(rank INT IDENTITY(1,1),host VARCHAR(20), guest VARCHAR(20))
AS
BEGIN
	INSERT INTO @matches
		SELECT host_team, guest_team FROM
			(
				SELECT dbo.getName(M.host_club_ID) AS host_team, dbo.getName(M.guest_club_ID) AS guest_team, M.match_ID,COUNT(T.ID) AS tickets 
				FROM Match M INNER JOIN Ticket T ON T.match_ID = M.match_ID AND T.status = 0
				GROUP BY dbo.getName(M.host_club_ID), dbo.getName(M.guest_club_ID), M.match_ID
			) AS match_ticket
			ORDER BY tickets DESC

RETURN
END
	
GO

