import requests
from flask import Flask, render_template, request, flash

app = Flask(__name__)
app.secret_key = "wor1dh3ll0_z1z0"

@app.route("/hello")
def index():
	flash("Enter your Hello World API")
	return render_template("index.html")

@app.route("/greet", methods=['GET', 'POST'])
def greeter():
	url = str(request.form['name_input'])
	# flash("Hi " + str(request.form['name_input']) + ", great to see you!")
	result = ("API Result: " + requests.get(url).text)
	flash(result)
	return render_template("index.html")
