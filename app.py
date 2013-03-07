from flask import Flask
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
            'qual_score >= 0 and elim_score >= 0 and final_score >= 0'
        ),
        UniqueConstraint('name', 'program_date'),
        {}
    )

manager = APIManager(app, flask_sqlalchemy_db = db)
manager.create_api(Score, methods = ['GET', 'POST'])

@app.before_first_request
def setup_db():
    db.drop_all()
    db.create_all()

@app.route('/')
def hello():
    print Score.query.all()
    return 'Hello World!'

if __name__ == '__main__':
    # Bind to PORT if defined, otherwise default to 5000.
    port = int(environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
