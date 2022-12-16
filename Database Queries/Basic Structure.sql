-- Basic Structure of the database


GO 
CREATE PROC clearAllTables 
AS
EXEC sp_MSForEachTable 'DISABLE TRIGGER ALL ON ?'
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
EXEC sp_MSForEachTable 'SET QUOTED_IDENTIFIER ON; DELETE FROM ?'
EXEC sp_MSForEachTable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'
EXEC sp_MSForEachTable 'ENABLE TRIGGER ALL ON ?'

go
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

go
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

