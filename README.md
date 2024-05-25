# Sports-Management-System
## Description:

An application with its SQL Database implemented for managing Sport events and matches and abstracting complications of handling requests between teams, match making and so on, as well as handling users and Fans of the system by allowing matches' ticket purchasing and reservations.

The project uses and depends on mainly Flask, Flask-SQLAlchemy, Flask-Session, Werkzeug, Jinja as templating language/engine that lets its user generate HTML with something similar to python syntax, pyodbc, colorama, greenlet, MarkupSafe and not much on gunicorn.

-----------------------
## Folder Structure
- The structure of the folders and project is chosen based on the default structure of Flask apps where there is the main python application file which is run when the whole web app runs and controls other classes and is in the root path of the project, there is also templates folder which contains all HTML pages and the bone structure of the app, and finally the static folder that contains all additional css, and javascript files used and imported in the HTML files.

- The main (backend) file is application.py controls all the logic represented in the project, as rendering pages, verifications redirecting of pages and others.

- Database Queries folder just contains the functions and queries used in the Microsoft SQL Server, that is called directly in the python app.

- Templates folder contains all the HTML pages handeled and used in our project, in which there's a page for each of the Fan, Admin, Stadium Manager, Sports Association Manager, Club Representitves, with all there functions and other registeration pages for each of them. There are also a register page, payment and home pages. There are also a default layout page, table layout page, and clubs layout page, and these pages are mainly just layout and handeled dynamically for multi-purposes by Jinja. Also the layout page is used in all pages in our project to include the headers, stylesheets, JS files, navigation bar, and all the common things.

- "static" folder contains all CSS and JavaScript files used in this project including a bootstrap folder for reliability because sometimes their server is down.

- Finally, the "requirements.txt" file include all the libraries required for this project to run and to be imported with their names and version. This file is used by venv to activate its script and help running this project and install required files in a folder by its name.
--------------------------------
## Running Notes
This project requires a local MS SQL server with pyodbc to be able to run.. and to run the database functions in it. Other than that the Project will throw an error and wouldn't connect to the Database. As there isn't a remote one.

There is a website preview available without a database connected, thus logging in and some functions are not available: 
> https://sporty-management.onrender.com/home


Thank You and hope you Enjoy!

------------------------
## Installation guide

> ### Steps to install venv , and to install required libraries:

- delete venv folder from the project folder if it exists
- open the start menu
- run cmd.exe
- cd to the project folder(e.g.: cd C:\Users\Dell\Desktop\db-project)
- create venv directory (python3 -m venv venv)
- install required libraries (pip install -r requirements.txt)


> ### Steps to run the application:

- open the start menu
- run cmd.exe
- cd to the project folder(e.g.: cd C:\Users\Dell\Desktop\db-project)
- activate venv (e.g venv\Scripts\activate)
- run flask server (flask --app application --debug run)
- open the browser, go to http://127.0.0.1:5000
