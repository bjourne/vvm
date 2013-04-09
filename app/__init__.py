from flask import Flask, redirect, url_for
from flask.ext.sqlalchemy import SQLAlchemy
from logging import INFO, basicConfig, getLogger


app = Flask(__name__)
app.config.from_object('config')
db = SQLAlchemy(app)

basicConfig()
#getLogger('sqlalchemy.engine').setLevel(INFO)

from app.users.views import mod as users_mod, setup_oauth
from app.restapi import setup_api

setup_oauth(app)
app.register_blueprint(users_mod, url_prefix = '/users')
setup_api(app, db)

@app.route('/')
def root():
    return redirect(url_for('static', filename = 'index.html'))

# @app.before_first_request
# def setup_db():
#     db.drop_all()
#     db.create_all()



