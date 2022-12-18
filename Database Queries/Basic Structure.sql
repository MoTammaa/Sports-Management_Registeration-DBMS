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

