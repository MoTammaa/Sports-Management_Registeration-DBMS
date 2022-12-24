from flask import Flask, redirect, url_for, render_template, request, flash
from flask_sqlalchemy import SQLAlchemy

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

        # Ensure username exists and password is correct
        if len(result) != 1 :
            return render_template("login.html", logMes="invalid username and/or password"), 403

        # Remember which user has logged in
        #session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")
    else:
        return render_template("login.html")


#------------------------------ registeration page




#------------------------------System admin page
@app.route("/System_admin")
def SystemAdminFunction():
    return render_template("System_admin.html")

#------------------------------Sports Association Manager page

@app.route("/Sports_Association_Manager")
def AssocManagerFunction():
    return render_template("Sports_Association_Manager.html")


#------------------------------Club Representative: page







#------------------------------Stadium Manager page







#------------------------------Fan page
@app.route("/Fan")
def FanFunction():
    return render_template("Fan.html")





#------------------------------examples 
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
