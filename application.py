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
            type = 'System Admin'
        elif len(db.session.execute(f"SELECT * FROM ClubRepresentative WHERE username = '{username}'").mappings().all()) == 1:
            type = 'Club Representative'
        elif len(db.session.execute(f"SELECT * FROM SportsAssociationManager WHERE username = '{username}'").mappings().all()) == 1:
            type = 'Sports Association Manager'
        elif len(db.session.execute(f"SELECT * FROM StadiumManager WHERE username = '{username}'").mappings().all()) == 1:
            type = 'Stadium Manager'
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


#------------------------------ registeration pages
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

        print("lala")

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

       print("lala")

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
            stage1 = birth_date.replace('T', ' ')                   
            stage2 = datetime.strptime(stage1, '%Y-%m-%d %H:%M')       
            stage3 = stage2.strftime("%Y-%m-%d %H:%M:%S")
    
            sql2 = f""" exec addFan '{name}', '{username}', '{password}', '{national_id}', '{stage3}', '{address}', {phone_num} """                  
            db.session.execute(sql2)
            db.session.commit()    
            flash("Fan Registeration Successfull !")    
            return redirect(url_for("login"))
    else:    
        return render_template("register_fan.html")         


#------------------------------System admin page
@app.route("/system_admin")
@login_required
def System_Admin_Function():
    return render_template("system_admin.html")
#------------------------------Sports Association Manager page

@app.route("/sports_association_manager")
@login_required
def Sports_Association_Manager_Function():
    return render_template("sports_association_manager.html")
    



#------------------------------Club Representative: page







#------------------------------Stadium Manager page







#------------------------------Fan page
@app.route("/fan")
@login_required
def Fan_Function():
    return render_template("fan.html")

#----------------------------------------------------------------------------------examples 
@app.route("/clubs")
@login_required
def clubs():
    sql = "SELECT * FROM club"
    result = db.session.execute(sql)

    return render_template("clubs.html", result=result)
#--------------------------------------------------------------
@app.route("/clubs/add", methods=['POST'])
@login_required
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
@login_required
def delete_club():
    name = request.form['name']

    sql = f"DELETE FROM club WHERE name='{name}'"
    db.session.execute(sql)
    db.session.commit()

    flash(f"Club {name} deleted successfully!")

    return redirect(url_for('home'))
# some helper functions
def isEmpty(SQL_SET):
    numOfRows = 0
    for row in SQL_SET:
        return False
    return True    
           
    