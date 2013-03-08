from flask import Flask, redirect, url_for
from flask.ext.restless import APIManager
from flask.ext.sqlalchemy import SQLAlchemy
from logging import INFO, basicConfig, getLogger
from os import environ
from sqlalchemy.schema import CheckConstraint, UniqueConstraint

basicConfig()
getLogger('sqlalchemy.engine').setLevel(INFO)

app = Flask(__name__)
app.config['DEBUG'] = True
app.config['SQLALCHEMY_DATABASE_URI'] = environ['DATABASE_URL']
db = SQLAlchemy(app)

class Score(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    name = db.Column(db.Unicode, nullable = False)
    program_date = db.Column(db.Date, nullable = False)
    qual_score = db.Column(db.Integer, nullable = False)
    elim_score = db.Column(db.Integer, nullable = False)
    final_score = db.Column(db.Integer, nullable = False)
    __table_args__ = (
        CheckConstraint(
            'qual_score between 0 and 100 and '
            'elim_score between 0 and 100 and '
            'final_score between 0 and 100'
        ),
        CheckConstraint(
            # Must be a weekday.
            "date_part('dow', program_date) not in (6, 0)"
        ),
        UniqueConstraint('name', 'program_date'),
        {}
    )

def post_post(data):
    return {'objects' : [data]}

manager = APIManager(app, flask_sqlalchemy_db = db)
manager.create_api(
    Score,
    postprocessors = {
        'POST' : [post_post],
        'PATCH_SINGLE' : [post_post],
        },
    methods = ['DELETE', 'GET', 'POST', 'PATCH', 'PUT']
    )

@app.before_first_request
def setup_db():
    pass
    #db.drop_all()
    #db.create_all()

@app.route('/')
def hello():
    return redirect(url_for('static', filename = 'index.html'))

if __name__ == '__main__':
    # Bind to PORT if defined, otherwise default to 5000.
    port = int(environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
