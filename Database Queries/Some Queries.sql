
--JUST CHECKING ALL TABLES ARE THERE
---------------------- higlight and press ctrl+K+U to remove comment,
----------------------- and ctrl+K+C to comment all lines again
SELECT * FROM SystemAdmin;
SELECT * FROM SystemUser;
SELECT * FROM Fan;
SELECT * FROM StadiumManager;
SELECT * FROM ClubRepresentative;
SELECT * FROM SportsAssociationmanager;
SELECT * FROM Club;
SELECT * FROM HostRequest;
SELECT * FROM Stadium;
SELECT * FROM TicketBuyingTransactions;
SELECT * FROM Match;
SELECT * FROM Ticket;

---------------------------

EXEC createAllTables;


EXEC clearAllTables;


EXEC insertRecords






INSERT INTO Club VALUES ('Barcelona', 'Spain');
INSERT INTO Club VALUES ('Liverpool', 'England');
INSERT INTO Club VALUES ('PSG', 'France');
INSERT INTO Club VALUES ('Real Madrid', 'Spain');
INSERT INTO Club VALUES ('Napoli', 'Italy');

EXEC addNewMatch 'Real Madrid', 'Liverpool', '2021-6-26 09:00:00', '2021-6-26 11:00:00' 
EXEC addNewMatch 'Real Madrid', 'Barcelona', '2023-9-15 09:00:00', '2023-9-15 11:00:00'



SELECT * FROM dbo.upcomingMatchesOfClub('Real Madrid')

SELECT * FROM dbo.clubsNeverPlayed('Liverpool')
SELECT * FROM Club
SELECT * FROM Match;
SELECT * FROM dbo.matchesPerTeam
SELECT * FROM dbo.matchesRankedByAttendance()

EXEC purchaseTicket '232323', 'Real Madrid', 'Barcelona','2023-9-15 09:00:00'





EXEC dropAllTables;
EXEC createAllTables;
EXEC clearAllTables;



--- hahh