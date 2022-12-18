
/*

1 – System User (Username, Password)
                 --------
2 - System admin (ID, , name , Username)
                  ---		   ........
3 – Sports Association Manager (ID , Name , Username)
                                --			........       
4 - Club Representative (ID , Name, club_ID ,  Username)
                         --         ........   .........   
5 – Stadium Manager (ID , name , stadium_ID , username)
					 --          ..........   ........
6 - Fan(national ID , name , birth_date , address , phone_no , status , Username)
		-----------													   ..........        
7 – Club (Club_ID, Name, Location)
          -------
8 – Host request (ID , representative_ID, manager_ID , match_ID , status)
                  --   .................  ..........  .........
representative_ID references club representative
manager_ID references stadium manager

9 - Stadium (ID, Name, Location, Capacity, Status)
             --
10 - Ticket_Buying_Transactions(fan_national_ID , ticket_ID)
                                ...............   .........

10 - Match (MatchID, starting_time, ending_Time,  Host, Guest, Stadium_ID)
            -------                               ....  .....  ...........
11- Ticket (ID , status , match_ID)
			--			  ........		
*/


go
create view allAssocManagers 
as 
select mn.username , u.password , mn.name
from   SportsAssociationManager mn , SystemUser u 
where mn.username = u.username

go 
create view allClubRepresentatives as
select u.username , u.password , c.name 
from  SystemUser u , Club c , ClubRepresentative r
where u.username = r.username
      and  r.club_ID = c.club_id 

go 
create view allStadiumManagers as
select u.username , u.password , m.name as manager_name, s.name as stadium_name
from  SystemUser u , StadiumManager m , Stadium s 
where u.username = m.username
      and  m.stadium_ID = s.ID

go 
create view allFans as
select u.username , u.password , f.name , f.national_id , f.birth_date , f.status
from SystemUser u , fan f
where u.username = f.username

go 
create view allMatches as
select c1.name as host_club_name , c2.name as guest_club_name , m.start_time
from Club c1 , Club c2 , Match m
where c1.club_id = m.host_club_ID
      and c2.club_id = m.guest_club_ID
		
go
create view allTickets as
select c1.name as host_club_name , c2.name as guest_club_name , s.name as stadium_name, m.start_time
from Club c1 , Club c2 , Stadium s , Ticket t , Match m
where m.host_club_ID = c1.club_id
      and m.guest_club_ID = c2.club_id
	  and m.stadium_ID = s.ID
	  and m.match_ID = t.match_ID

go 
create view allCLubs as
select c.name , c.location
from Club c

go
create view allStadiums as
select s.name , s.location , s.capacity , s.status
from Stadium s

go
create view allRequests as
select rep.username as representative_user, m.username as stadium_manager_user, r.status
from ClubRepresentative rep , StadiumManager m , HostRequest r
where r.representative_ID = rep.ID
      and r.manager_ID = m.ID

-------------------------------------------------------------------- 2.3

go
create proc addAssociationManager 
@name varchar(20) , @username varchar(20) , @password varchar(20)
as
insert into SystemUser(username , password) values 
(@username , @password)
insert into SportsAssociationManager (name , username) values 
(@name , @username )

go
create view clubsWithNoMatches
as
select c.name
from Club c
where (c.club_id not in (select m.host_club_ID from Match m) )
      and (c.club_id not in (select m.guest_club_ID from Match m) )

go
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

go
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

go
create proc addStadium
@stadium_name varchar(20), @stadium_location varchar(20) , @stadium_capacity int
as
insert into Stadium(name , location , capacity , status) values
(@stadium_name , @stadium_location , @stadium_capacity , 1)

go
create proc blockFan
@fan_national_id varchar(20)
as
update fan
set status = 0 where national_id = @fan_national_id

go
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

go 
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
	  and mt.stadium_ID = @stadium_id
	  

insert into HostRequest(representative_ID , manager_ID , match_ID) values -- no status mentioned, left for deault value, whether 'null' or 'unhandled'
(@rep_id , @manager_id , @match_id)

go
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

go 
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
set status = 1 where representative_ID = @host_id and manager_ID = @manager_id and match_ID = @match_id
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




	/*
	WHILE @i <= 30
	BEGIN
		PRINT (@i);
		SET @i = @i + 10;
	END;
	*/



go 
create proc addFan 
@fan_name varchar(20),@fan_user_name varchar(20) , @fan_password varchar(20) , @fan_national_id varchar(20) , @fan_birth_date datetime , @fan_address varchar(20) , @fan_phone_number int 
as
insert into SystemUser(username , password ) values
(@fan_user_name , @fan_password)
insert into Fan(username ,national_id , name , birth_date , address , phone_no , status) values
(@fan_user_name , @fan_national_id , @fan_name , @fan_birth_date , @fan_address , @fan_phone_number ,1)

go
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

go 
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

go
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

go  
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

go
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



