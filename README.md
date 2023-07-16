# Sports-Management-System
#### Video Demo:  https://youtu.be/C2E-M9_AsMg
#### Description:

An application with its SQL Database implemented for managing Sport events and matches and abstracting complications of handling requests between teams, match making and so on, as well as handling users and Fans of the system by allowing matches' ticket purchasing and reservations.

The main (backend) file is application.py controlls all the logic represented in the project, as rendering pages, verifications redirecting of pages and others.

Database Queries folder just contains the functions and queries used in the Microsoft SQL Server, that is called directly in the python app.

Templates folder contains all the HTML pages handeled and used in our project, in which there's a page for each of the Fan, Admin, Stadium Manager, Sports Association Manager, Club Representitves, with all there functions and other registeration pages for each of them. There are also a register page, payment and home pages. There are also a default layout page, table layout page, and clubs layout page, and these pages are mainly just layout and handeled dynamically for multi-purposes by Jinja. Also the layout page is used in all pages in our project to include the headers, stylesheets, JS files, navigation bar, and all the common things.

"static" folder contains all CSS and JavaScript files used in this project including a bootstrap folder for reliability because sometimes their server is down.

Finally, the "requirements.txt" file include all the libraries required for this project to run and to be imported with their names and version. This file is used by venv to activate its script and help running this project and install required files in a folder by its name.

This project requires a local MS SQL server with pyodbc to be able to run.. and to run the database functions in it. Other than that the Project will throw an error and wouldn't connect to the Databse. as there isn't a remote one.

Thank You and hope you Enjoy!
