from flask import Flask, redirect, url_for, render_template, request, flash
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime


db = SQLAlchemy()
app = Flask(__name__)
app.secret_key = "my secret key"
app.config["SQLALCHEMY_DATABASE_URI"] = "mssql+pyodbc://db-porject"
db.init_app(app)

#------------------------------ default route
@app.route("/")
def index():
    #if not logged in
    return render_template("login.html")

#------------------------------ home page
@app.route("/home")
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

        # Remember which user has logged in
        #session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        print("login successfullllll")
        return redirect("/home")
    else:
        return render_template("login.html")


#------------------------------ registeration pages
@app.route("/register")
def Register_Function():
        return render_template("register.html")


@app.route("/register_system_admin")
def Register_System_Admin_Function():
    return render_template("register_system_admin.html")    


@app.route("/register_sports_association_manager")
def Register_Sports_Association_Manager_Function():
    return render_template("register_sports_association_manager.html") 


@app.route("/register_club_representative")
def Register_ClubRepresentative_Function():
    sql = """ SELECT c.club_id, c.name 
              FROM club c LEFT OUTER JOIN ClubRepresentative rep
              ON c.club_id = rep.club_ID
              where rep.club_id is null             
          """                          
    clubs = db.session.execute(sql)
    return render_template("register_club_representative.html", clubs=clubs) 


@app.route("/register_stadium_manager")
def Register_Stadium_Manager_Function():
    sql = """select s.name 
             from Stadium s left outer join StadiumManager m  
             on s.ID = m.stadium_ID  
             where m.stadium_ID is null"""       
    Stadiums = db.session.execute(sql)
    available_stadiums = [] 
    for Stadium in Stadiums:
        available_stadiums.append(Stadium.name)
    return render_template("register_stadium_manager.html", names=available_stadiums)     


@app.route("/register_fan")
def Register_Fan_Function():
    return render_template("register_fan.html")         


#------------------------------System admin page
@app.route("/system_admin" , methods = ['GET','POST'])
def System_Admin_Function():
    if(request.method == 'GET'):
        name = request.args.get('name')
        return render_template("system_admin.html",name = name)
    else:  
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
            sql2 = f"""INSERT INTO SystemUser(username,password) VALUES ('{username}','{password}')
                       INSERT INTO SystemAdmin(username,name) VALUES ('{username}', '{name}')
                    """
            db.session.execute(sql2)
            db.session.commit()        
            return redirect(url_for("System_Admin_Function", name = name))
        

#------------------------------Sports Association Manager page

@app.route("/sports_association_manager",methods = ['GET','POST'])
def Sports_Association_Manager_Function():
    if(request.method == 'GET'):
        name = request.args.get('name')
        return render_template("sports_association_manager.html",name = name)
    else:  
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
            sql2 = f""" exec addAssociationManager '{name}', '{username}', '{password}' """                                      
            db.session.execute(sql2)
            db.session.commit()        
            return redirect(url_for("Sports_Association_Manager_Function", name = name))
    



#------------------------------Club Representative: page







#------------------------------Stadium Manager page







#------------------------------Fan page
@app.route("/fan" , methods = ['GET','POST'])
def Fan_Function():
    if(request.method == 'GET'):
        name = request.args.get('name')
        return render_template("fan.html",name = name)
    else:  
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
            return redirect(url_for("Fan_Function", name = name))

#----------------------------------------------------------------------------------examples 
@app.route("/clubs")
def clubs():
    sql = "SELECT * FROM club"
    result = db.session.execute(sql)

    return render_template("clubs.html", result=result)
#--------------------------------------------------------------
@app.route("/clubs/add", methods=['POST'])
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
           
    