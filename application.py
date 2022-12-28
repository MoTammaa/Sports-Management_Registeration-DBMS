from flask import Flask, redirect, url_for, render_template, request, flash, session
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from flask_session import Session
from functools import wraps


#                          {username,password}
#     _______________________(-SystemUser-) _______________________________________
#    /                 |               |                      |                    \
#   /                  |               |                      |                     \
# (-Fan-)       (-SystemAdmin-)   (-StadiumManager-)   (-ClubRepresentative-)   (-SportsAssociationManager-)
#{national_id,      {ID,name          {ID,name            {ID,name,username         {ID,name,username}
#name,             ,username}         ,username           ,club_id}
#birth_date,                          ,stadium_id}
#address,
#status,
#phone_no,
#username}
#               (-Stadium-)                  (-Club-)--{club_id,name,location}
#     {ID,name,location,capacity,status}
#
#                         (-Match-)------{match_ID,start_time,end_time,host_club_ID,guest_club_ID,stadium_ID}
# 
#{ID,status,match_ID}--(-Ticket-)     (-HostRequest-)--{ID,representative_ID,manager_ID,match_ID,status}
#
#			    (-TicketBuyingTransactions-)
#              {fan_national_ID,ticket_ID}
#
#
#




db = SQLAlchemy()
app = Flask(__name__)
app.secret_key = "my secret key"
app.config["SQLALCHEMY_DATABASE_URI"] = "mssql+pyodbc://db-porject"
db.init_app(app)

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)



#------------------------------ default route
@app.route("/")
def index():
    #if not logged in
    return redirect("/login")

#------------------------------ login requirement decorator

def login_required(test):
    @wraps(test)
    def wrap(*args, **kwargs):
        if 'username' in session:
            return test(*args, **kwargs)
        else:
            flash("You need to login first.")
            return redirect('login')
    return wrap

#------------------------------ home page
@app.route("/home")
@login_required
def home():
    return render_template("home.html")


    
#------------------------------ login page



@app.route("/login", methods=['GET','POST'])
def login():

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        # Ensure username was submitted
        if not username or ('--' in username):
            return render_template("login.html", logMes="must provide a valid username"), 403

        # Ensure password was submitted
        elif not password or ('--' in password):
            return render_template("login.html", logMes="must provide a valid password"), 403

        # Query database for username
        sql = f"SELECT * FROM SystemUser WHERE username = '{username}' AND password = '{password}'"
        result = db.session.execute(sql)
        result=result.mappings().all()

        # Ensure username exists and password is correct
        if len(result) != 1 :
            return render_template("login.html", logMes="invalid username and/or password"), 403

        #find the type of the user
        if len(db.session.execute(f"SELECT * FROM Fan WHERE username = '{username}'").mappings().all()) == 1:
            type = 'Fan'
        elif len(db.session.execute(f"SELECT * FROM SystemAdmin WHERE username = '{username}'").mappings().all()) == 1:
            type = 'System_Admin'
        elif len(db.session.execute(f"SELECT * FROM ClubRepresentative WHERE username = '{username}'").mappings().all()) == 1:
            type = 'Club_Representative'
        elif len(db.session.execute(f"SELECT * FROM SportsAssociationManager WHERE username = '{username}'").mappings().all()) == 1:
            type = 'Sports_Association_Manager'
        elif len(db.session.execute(f"SELECT * FROM StadiumManager WHERE username = '{username}'").mappings().all()) == 1:
            type = 'Stadium_Manager'
        else:
            type = "undefined"

        # Remember which user has logged in
        session["username"] = username
        session["user_type"] = type
        
        # Redirect user to home page
        print("login successfullllll")
        return redirect("/home")
    else:
        return render_template("login.html")

#----------------------------- logout request

@app.route("/logout")
@login_required
def logout():
    """Log user out"""
    print(session["username"])
    # Forget any username
    session.clear()

    # Redirect user to login form
    return redirect("/")


#---------------------------------------------------------------------------------------------------registeration pages
@app.route("/register")
def Register_Function():
        return render_template("register.html")

@app.route("/register_system_admin", methods = ['GET','POST'])
def Register_System_Admin_Function():
        if(request.method == 'POST'):
            username = request.form['username']
            password = request.form['password']
            name = request.form['Full Name']
            sql = f"""  SELECT *    
                        from SystemUser u
                        where u.username = '{username}'
                   """
            result = db.session.execute(sql)
            if(not isEmpty(result)):
                flash("username already taken!")
                return redirect(url_for("Register_System_Admin_Function"))
            else:           
                flash("System Admin Registeration Succesfull !")  
                sql2 = f"""INSERT INTO SystemUser(username,password) VALUES ('{username}','{password}')
                           INSERT INTO SystemAdmin(username,name) VALUES ('{username}', '{name}')
                        """
                db.session.execute(sql2)
                db.session.commit()        
                return redirect(url_for("login")) 
        else:
            return render_template('register_system_admin.html')         
 
@app.route("/register_sports_association_manager", methods = ['GET','POST'])
def Register_Sports_Association_Manager_Function():
        if(request.method == 'POST'):                    
            username = request.form['username']
            password = request.form['password']
            name = request.form['Full Name']
            sql = f"""  SELECT *    
                        from SystemUser u
                        where u.username = '{username}'
                   """
            result = db.session.execute(sql)
            if(not isEmpty(result)):
                 flash("username already taken!")
                 return redirect(url_for("Register_Sports_Association_Manager_Function"))
            else:        
                flash("Sports Association Manager Registeration Successful !")     
                sql2 = f""" exec addAssociationManager '{name}', '{username}', '{password}' """                                      
                db.session.execute(sql2)
                db.session.commit()        
                return redirect(url_for("login")) 
        else:
            return render_template("register_sports_association_manager.html")        

@app.route("/register_club_representative", methods = ['GET','POST'])
def Register_ClubRepresentative_Function():
    if(request.method == 'POST'):

            username = request.form['username']
            password = request.form['password']
            name = request.form['Full Name']
            represented_club = request.form['Represented Club']
            sql = f"""  SELECT *    
                        from SystemUser u
                        where u.username = '{username}'
                   """
            result = db.session.execute(sql)
            if(not isEmpty(result)):
                 flash("username already taken!")
                 return redirect(url_for("Register_ClubRepresentative_Function"))
            else:        
                flash("Club Representative Registeration Successful !")     
                sql2 = f""" exec addRepresentative '{name}', '{represented_club}', '{username}', '{password}' """                                      
                db.session.execute(sql2)
                db.session.commit()        
                return redirect(url_for("login")) 

    else:    
        sql = """ SELECT c.club_id, c.name 
                    FROM club c LEFT OUTER JOIN ClubRepresentative rep
                    ON c.club_id = rep.club_ID
                    where rep.club_id is null             
                """                          
        clubs = db.session.execute(sql)
        return render_template("register_club_representative.html", clubs=clubs) 

@app.route("/register_stadium_manager", methods = ['GET','POST'])
def Register_Stadium_Manager_Function():
    if(request.method == 'POST'):
            username = request.form['username']
            password = request.form['password']
            name = request.form['Full Name']
            mangaed_stadium = request.form['Managed Stadium']
            sql = f"""  SELECT *    
                        from SystemUser u
                        where u.username = '{username}'
                   """
            result = db.session.execute(sql)
            if(not isEmpty(result)):
                 flash("username already taken!")
                 return redirect(url_for("Register_Stadium_Manager_Function"))
            else:        
                flash("Club Representative Registeration Successful !")     
                sql2 = f""" exec addStadiumManager '{name}', '{mangaed_stadium}', '{username}', '{password}' """                                      
                db.session.execute(sql2)
                db.session.commit()        
                return redirect(url_for("login")) 


    else:    
        sql = """select s.name 
                from Stadium s left outer join StadiumManager m  
                on s.ID = m.stadium_ID  
                where m.stadium_ID is null"""       
        Stadiums = db.session.execute(sql)
        available_stadiums = [] 
        for Stadium in Stadiums:
            available_stadiums.append(Stadium.name)
        return render_template("register_stadium_manager.html", names=available_stadiums)     

@app.route("/register_fan", methods = ['GET','POST'])
def Register_Fan_Function():
    if(request.method == 'POST'):
        username = request.form['username']
        password = request.form['password']
        name = request.form['Full Name']
        national_id = request.form['National id']
        phone_num = request.form['phone number']
        birth_date = request.form['Birth Date'] 
        address = request.form['Address']

        sql = f"""  SELECT *    
                    from SystemUser u
                    where u.username = '{username}'
               """
        result = db.session.execute(sql)
        if(not isEmpty(result)):
            flash("username already taken!")
            return redirect(url_for("Register_Fan_Function"))
        else:
            # changing time format taken from html to be compatible with python and sql           
            time_formatted = timeForSQL_without_seconds(birth_date)   
            sql2 = f""" exec addFan '{name}', '{username}', '{password}', '{national_id}', '{time_formatted}', '{address}', {phone_num} """                  
            db.session.execute(sql2)
            db.session.commit()    
            flash("Fan Registeration Successfull !")    
            return redirect(url_for("login"))
    else:    
        return render_template("register_fan.html")         


#---------------------------------------------------------------------------------------------------------System admin pages
@app.route("/system_admin",methods = ['GET','POST'])
def System_Admin_Function():
    sql1 = """ SELECT name FROM club  """                                                                   
    sql2 = """ SELECT name FROM Stadium  """     
    club_names = db.session.execute(sql1).mappings().all()
    stadium_names = db.session.execute(sql2).mappings().all()
    return render_template("system_admin.html", club_names=club_names , stadium_names = stadium_names) 

@app.route("/add_club",methods = ['GET','POST'])
def Add_Club_Function():
    if(request.method == 'POST'):
        club_name = request.form['Added_club_name']
        club_location = request.form['Added_club_location']
        sql = f"""exec addClub '{club_name}', '{club_location}' """
        db.session.execute(sql)
        db.session.commit()
        flash(f"Club {club_name} in {club_location} Added Successfully !")      
    return redirect(url_for("System_Admin_Function"))    

@app.route("/delete_club",methods = ['GET','POST'])
def Delete_Club_Function():
    if(request.method == 'POST'):
        club_name = request.form['deleted club']
        sql = f"""exec deleteClub '{club_name}' """
        db.session.execute(sql)
        db.session.commit()
        flash(f"Club {club_name} Deleted Successfully !")      
    return redirect(url_for("System_Admin_Function"))    

@app.route("/add_stadium",methods = ['GET','POST'])
def Add_Stadium_Function():
    if(request.method == 'POST'):
        Stadium_name = request.form['Added_stadium_name']
        Stadium_location = request.form['Added_stadium_location']
        Stadium_capacity = request.form['Added_stadium_capacity']
        sql = f"""exec addStadium '{Stadium_name}', '{Stadium_location}', '{Stadium_capacity}' """
        db.session.execute(sql)
        db.session.commit()
        flash(f"Stadium {Stadium_name} in {Stadium_location} with capacity {Stadium_capacity} Added Successfully !")      
    return redirect(url_for("System_Admin_Function"))  

@app.route("/delete_stadium",methods = ['GET','POST'])
def Delete_Stadium_Function():
    if(request.method == 'POST'):
        stadium_name = request.form['deleted Stadium']
        sql = f"""exec deleteStadium '{stadium_name}' """
        db.session.execute(sql)
        db.session.commit()
        flash(f"Stadium {stadium_name} Deleted Successfully !")      
    return redirect(url_for("System_Admin_Function"))      

@app.route("/block_fan",methods = ['GET','POST'])
def Block_Fan_Function():
    if(request.method == 'POST'):
        fan_national_ID = request.form['Blocked_Fan_national_id']
        sql1 = f""" select * from Fan f  where f.national_id = '{fan_national_ID}' """
        records = db.session.execute(sql1)
        if(isEmpty(records)):
            flash("There is no Fan with that National_ID")
            return redirect(url_for("Block_Fan_Function"))
        else:                     
            sql2 = f"""exec blockFan '{fan_national_ID}' """
            db.session.execute(sql2)
            db.session.commit()
            flash(f"Fan with National_ID {fan_national_ID} Blocked Successfully !")      
    return redirect(url_for("System_Admin_Function"))  


#--------------------------------------------------------------------------------------------------Sports Association Manager pages

@app.route("/sports_association_manager")
def Sports_Association_Manager_Function():
    sql1 = """ SELECT * FROM club  """
    sql2 = """ SELECT * FROM Stadium s""" 
    club_names1 = db.session.execute(sql1)
    club_names2 = db.session.execute(sql1)
    club_names3 = db.session.execute(sql1)
    club_names4 = db.session.execute(sql1)   
    stadiums = db.session.execute(sql2)
    return render_template("sports_association_manager.html", club_names1 = club_names1,club_names2 = club_names2,club_names3 = club_names3,club_names4 = club_names4,stadiums = stadiums)
    
@app.route("/add_match",methods = ['GET','POST'])
def Add_Match_Function():
    if(request.method == 'POST'):
        host_id = request.form['added host']
        guest_id = request.form['added Guest']
        stadium_id =  request.form['stadium']
        start_time = timeForSQL_with_seconds(request.form['New_Match_Start_Time'])       
        end_time = timeForSQL_with_seconds(request.form['New_Match_End_Time'])        
        if(host_id == guest_id):
            flash(f"in our world, a Club can't play against itself ! :) ")
            return redirect(url_for("Add_Match_Function")) 
        else:
            sql = f""" INSERT INTO Match(host_club_ID , guest_club_ID , stadium_ID , start_time , end_time) VALUES
                    ('{host_id}', '{guest_id}', '{stadium_id}', '{start_time}', '{end_time}')

                    """
            db.session.execute(sql)
            db.session.commit()
            flash("Match Added Successfully !")     
            return redirect(url_for("Add_Match_Function"))   
    else:
        return redirect(url_for("Sports_Association_Manager_Function"))
  
@app.route("/delete_match",methods = ['GET','POST'])
def Delete_Match_Function():
    if(request.method == 'POST'):
        host_name = request.form['deleted host']
        guest_name = request.form['deleted guest']
        start_time = timeForSQL_with_seconds(request.form['Deleted_Match_Start_Time'])       
        end_time = timeForSQL_with_seconds(request.form['Deleted_Match_End_Time']) 
        sql1 =     f""" select * 
                        from Match m , Club c1 , Club c2
                        where m.host_club_ID = c1.club_id 
                        and m.guest_club_ID = c2.club_id
                        and m.start_time = '{start_time}'
	                    and m.end_time = '{end_time}'
                    """   
        result = db.session.execute(sql1)
        if(isEmpty(result)):            
            flash("There is No Match With The Given Information !")
            return redirect(url_for("Delete_Match_Function"))
        else:
            sql2 = f""" exec deleteMatch '{host_name}', '{guest_name}' """                  
            db.session.execute(sql2)
            db.session.commit()
            flash("Match Deleted Successfully !")     
            return redirect(url_for("Delete_Match_Function"))   
    else:
        return redirect(url_for("Sports_Association_Manager_Function"))
      
# ---views
@app.route("/all_upcoming_matches")
def Show_All_Upcoming_Matches_Function():
    sql = f""" select c1.name as host_club_name, c2.name as guest_club_name , m.start_time as start_Time , m.end_time as end_Time
               from match m , club c1 , club c2
               where m.host_club_ID = c1.club_id
	                and m.guest_club_ID = c2.club_id
	                and m.start_time > CURRENT_TIMESTAMP

            """
    data =  db.session.execute(sql).fetchall()
    headers = ["Host Name" , "Guest Name" , "Start Time" , "End Time"]
    return render_template("table.html" , viewName = "All Upcoming Matches", headers = headers, data = data )

@app.route("/already_played_matches")
def Show_All_Already_Played_Matches_Function():
    sql = f""" select c1.name as host_club_name, c2.name as guest_club_name , m.start_time as start_Time , m.end_time as end_Time
               from match m , club c1 , club c2
               where m.host_club_ID = c1.club_id
	                 and m.guest_club_ID = c2.club_id
	                 and m.end_time < CURRENT_TIMESTAMP
            """
    data =  db.session.execute(sql).fetchall()
    headers = ["Host Name" , "Guest Name" , "Start Time" , "End Time"]
    return render_template("table.html" , viewName = "Already Played Matches", headers = headers, data = data )

@app.route("/pairs_never_matched")
def Show_Clubs_Never_Matched_Function():
    sql = f""" select * from clubsNeverMatched """
    data =  db.session.execute(sql).fetchall()
    headers = ["First Club" , "Second Club"]
    return render_template("table.html" , viewName = "Clubs Never Competed Against Each Other", headers = headers, data = data )



#------------------------------Club Representative: page

@app.route('/Club_Representative',methods=['GET', 'POST'])
def CRep():
    if session['user_type'] != 'Club_Representative':
        return redirect('/home')

    if request.method == 'GET':
        sql = f"SELECT * FROM Club WHERE club_id = (SELECT club_id FROM ClubRepresentative WHERE username = '{session['username']}')"                  
        club = db.session.execute(sql).mappings().all()

        sql = f"SELECT * FROM dbo.upcomingMatchesOfClub('{club[0].name}')"                
        matches = db.session.execute(sql).mappings().all()

        return render_template("Club_Representative.html", club=club, matches=matches)

    else:
        if 'datee' in request.form:
            date = request.form['datee']
            sql = f"SELECT name,location,capacity FROM Stadium WHERE status = 1 AND start_time >= '{date}')"                  
            stadiums = db.session.execute(sql).mappings().all()
            return render_template("Club_Representative.html", stadiums=stadiums)
            
        





#------------------------------Stadium Manager page







#----------------------------------------------------------------------------------Fan pages
@app.route("/fan")
def Fan_Function():
    sql = """ SELECT name FROM club  """ 
    club_names1 = db.session.execute(sql).mappings().all()
    club_names2 = db.session.execute(sql).mappings().all()
    return render_template("fan.html", club_names1 = club_names1,club_names2 = club_names2)

@app.route("/Purchase_Ticket",methods = ['GET','POST'])
def Purchase_Ticket_Function():
    if(request.method == 'POST'):
        host_name = request.form['host name']
        guest_name = request.form['guest name']
        start_time = timeForSQL_with_seconds(request.form['start_time'])   
        sql1 = f"""
                    select *
                    from match m ,club c1, club c2
                    where m.host_club_ID = c1.club_id
                    and m.guest_club_ID = c2.club_id
                    and m.start_time = '{start_time}'
                    and c1.name = '{host_name}'
                    and c2.name = '{guest_name}'
                 """    
        there_is_match = db.session.execute(sql1)     
        if(isEmpty(there_is_match)):
            flash("There is NO Match With The Given Information !")
            return redirect(url_for("Purchase_Ticket_Function"))
        else:    
             sql2 =  f""" select *
                          from match m ,club c1, club c2, Ticket t
                          where m.host_club_ID = c1.club_id
                          and m.guest_club_ID = c2.club_id
                          and m.match_ID = t.match_ID
                          and t.status = 1

                        """   
             there_is_available_tickets  = db.session.execute(sql2)
             if(isEmpty(there_is_available_tickets)):            
                flash("All Tickets Are Sold !")
                return redirect(url_for("Purchase_Ticket_Function"))
             else:
                  fan_National_ID = getID(session["username"])
                  sql3 = f"""exec purchaseTicket '{fan_National_ID}', '{host_name}', '{guest_name}', '{start_time}' """ 
                  db.session.execute(sql3)
                  db.session.commit()
                  flash("Ticket Purchased Successfully !")
                  return redirect(url_for("Purchase_Ticket_Function"))
    else:
        return redirect(url_for("Fan_Function"))

#view
@app.route("/view_all_matches_that_have_tickets_starting_at_a_given_time",methods = ['GET','POST'])
def View_Matches_Function():
    if(request.method == 'POST'):
        
        time = timeForSQL_without_seconds(request.form['m_start_time'])
        sql = f"""select c1.name as hostName, c2.name as guestName , s.name as stadiumName , s.location as loc
                  from Club c1 , Club c2 , Match m , Stadium s
                  where c1.club_id = m.host_club_ID
                        and c2.club_id = m.guest_club_ID
                        and m.stadium_ID = s.ID
                        and m.start_time = '{time}'
                        and exists (select *
                                     from Ticket t
                                     where t.status = 1
                                           and t.match_ID = m.match_ID)        
                 """
        data = db.session.execute(sql).fetchall()
        headers = ["Host Club", "Guest Club", "Stadium Name", "Stadium Location"]
        return render_template("/table.html" ,viewName = "All Matches That Have Available Tickets Starting At The Given Time ", headers = headers , data = data)
    else:
        return redirect(url_for("Fan_Function"))    
    
#----------------------------------------------------------------------------------examples 
@app.route("/clubs")
#@login_required
def clubs():
    sql = "SELECT * FROM club"
    result = db.session.execute(sql)

    return render_template("clubs.html", result=result)
#--------------------------------------------------------------
@app.route("/clubs/add", methods=['POST'])
#@login_required
def add_club():
    name = request.form['name']
    location = request.form['location']

    sql = f"exec addClub '{name}', '{location}'"
    db.session.execute(sql)
    db.session.commit()

    flash(f"Club {name} in {location} added successfully!")

    return redirect(url_for('home'))
#-----------------------------------------------
@app.route("/clubs/delete", methods=['POST'])
#@login_required
def delete_club():
    name = request.form['name']

    sql = f"DELETE FROM club WHERE name='{name}'"
    db.session.execute(sql)
    db.session.commit()

    flash(f"Club {name} deleted successfully!")

    return redirect(url_for('home'))
# ---------------------------------------------------some helper functions
def isEmpty(SQL_SET):   
    for row in SQL_SET:
        return False
    return True    

def timeForSQL_without_seconds(time):
    stage1 = time.replace('T', ' ')                   
    stage2 = datetime.strptime(stage1, '%Y-%m-%d %H:%M')       
    stage3 = stage2.strftime("%Y-%m-%d %H:%M:%S")
    return stage3

def timeForSQL_with_seconds(time):
    stage1 = time.replace('T', ' ')     
    stage2 = datetime.strptime(stage1, '%Y-%m-%d %H:%M')    
    stage3 = stage2.replace(second=0)     
    stage4 = stage3.strftime("%Y-%m-%d %H:%M:%S")
    return stage4

def getID(username):
    sql = f"""select f.national_id
              from fan f
              where f.username = '{username}'
            """        
    result = db.session.execute(sql)
    for row in result :
        return row.national_id 


               
    