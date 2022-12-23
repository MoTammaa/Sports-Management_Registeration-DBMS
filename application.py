from flask import Flask, redirect, url_for, render_template, request, flash
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()
app = Flask(__name__)
app.secret_key = "my secret key"
app.config["SQLALCHEMY_DATABASE_URI"] = "mssql+pyodbc://db-porject"
db.init_app(app)

@app.route("/")
def home():
    return render_template("home.html")

@app.route("/clubs")
def clubs():
    sql = "SELECT * FROM club"
    result = db.session.execute(sql)

    return render_template("clubs.html", result=result)

@app.route("/clubs/add", methods=['POST'])
def add_club():
    name = request.form['name']
    location = request.form['location']

    sql = f"exec addClub '{name}', '{location}'"
    db.session.execute(sql)
    db.session.commit()

    flash(f"Club {name} in {location} added successfully!")

    return redirect(url_for('home'))

@app.route("/clubs/delete", methods=['POST'])
def delete_club():
    name = request.form['name']

    sql = f"DELETE FROM club WHERE name='{name}'"
    db.session.execute(sql)
    db.session.commit()

    flash(f"Club {name} deleted successfully!")

    return redirect(url_for('home'))