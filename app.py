# -*- coding: utf-8 -*-
from flask import Flask, jsonify, redirect, request, url_for
from flask.ext.login import (
    LoginManager,
    login_required,
    login_user,
    logout_user,
    current_user
)
from flask.ext.restless import APIManager, ProcessingException
from flask.ext.sqlalchemy import SQLAlchemy
from logging import INFO, basicConfig, getLogger
from os import environ
from os.path import join
from sqlalchemy.schema import CheckConstraint, UniqueConstraint

basicConfig()
getLogger('sqlalchemy.engine').setLevel(INFO)

app = Flask(__name__)
app.config['DEBUG'] = True
app.config['SQLALCHEMY_DATABASE_URI'] = environ['DATABASE_URL']
app.config['SECRET_KEY'] = 'hejsan'

db = SQLAlchemy(app)
class User(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    email = db.Column(db.String(120), unique = True)
    scores = db.relationship('Score', lazy = 'dynamic')

    def is_authenticated(self):
        return True

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def get_id(self):
        return unicode(self.id)

    def __repr__(self):
        return '<User %r>' % (self.email)

    __table_args__ = (
        CheckConstraint("email like '%@%'", name = 'email/format'),
        CheckConstraint('trim(email) = email', name = 'email/spaces')
    )

class Score(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    program_date = db.Column(db.Date, nullable = False)
    qual_score = db.Column(db.Integer, nullable = False)
    qual_questions = db.Column(db.Integer, nullable = False)
    elim_score = db.Column(db.Integer, nullable = False)
    elim_questions = db.Column(db.Integer, nullable = False)
    final_score = db.Column(db.Integer, nullable = False)
    final_questions = db.Column(db.Integer, nullable = False)
    __table_args__ = (
        CheckConstraint(
            # Must be a weekday.
            "date_part('dow', program_date) not in (6, 0)",
            name = "program_date/weekday"
        ),
        CheckConstraint(
            'program_date <= current_date',
            name = 'program_date/future'
        ),
        CheckConstraint(
            'qual_score between 0 and qual_questions',
            name = 'qual_score/oob'
        ),
        CheckConstraint(
            'elim_score between 0 and elim_questions',
            name = 'elim_score/oob'
        ),
        CheckConstraint(
            'final_score between 0 and final_questions',
            name = 'final_score/oob'
        ),
        CheckConstraint(
            'qual_questions between 1 and 100',
            name = 'qual_questions/oob'
        ),
        CheckConstraint(
            'elim_questions between 1 and 100',
            name = 'elim_questions/oob'
        ),
        CheckConstraint(
            'final_questions between 1 and 100',
            name = 'final_questions/oob'
        ),
        UniqueConstraint(
            'user_id',
            'program_date',
            name = 'user_id/uq-program_date'
        ),
        {}
    )

##############################################################################

lm = LoginManager()
lm.setup_app(app)
@lm.user_loader
def load_user(id):
    return User.query.get(int(id))

def get_current_user_id():
    return int(current_user.get_id() or 0)

##############################################################################

manager = APIManager(app, flask_sqlalchemy_db = db)

def score_auth(data):
    posted_user_id = int(data.get('user_id', 0))
    if get_current_user_id() != posted_user_id:
        raise ProcessingException('Not authorized: Cant change owner', 401)
    return data

def score_check_owner(instid):
    try:
        instid = int(instid)
    except ValueError:
        return
    score = Score.query.get(instid)
    if not score:
        return
    if get_current_user_id() != score.user_id:
        raise ProcessingException('Not authorized: Not the owner', 401)
    
def score_pre_patch(instid, data):
    score_check_owner(instid)
    return score_auth(data)

def score_pre_post(data):
    return score_auth(data)

def score_pre_delete(instid):
    score_check_owner(instid)

def post_post(data):
    return {'objects' : [data]}

manager.create_api(
    Score,
    preprocessors = {
        'DELETE' : [score_pre_delete],
        'PATCH_SINGLE' : [score_pre_patch],
        'POST' : [score_pre_post]
    },     
    postprocessors = {
        'PATCH_SINGLE' : [post_post],
        'POST' : [post_post]
    },
    methods = [
        'DELETE', 'GET', 'PATCH', 'POST', 'PUT']
)

manager.create_api(
    User,
    methods = ['GET', 'POST']
)

##############################################################################

@app.before_first_request
def setup_db():
    pass
    #db.drop_all()
    #db.create_all()

@app.route('/')
def root():
    return redirect(url_for('static', filename = 'index.html'))

@app.route('/login', methods = ['POST'])
def login():
    form = request.form
    email = form.get('email', '')
    password = form.get('password', '')
    user = User.query.filter_by(email = email).first()
    if not user:
        return jsonify(error = 'user-invalid')
    if not login_user(user, remember = True):
        return jsonify(error = 'user-inactive')
    return jsonify(success = True)

@app.route('/logout', methods = ['POST'])
@login_required
def logout():
    logout_user()
    return jsonify(success = True, email = 'okÃ¤nd')

@app.route('/whoami')
def whoami():
    id = current_user.get_id()
    isAnon = id is None
    email = getattr(current_user, 'email', 'okÃ¤nd')
    return jsonify(isAnon = isAnon, email = email, id = id)

if __name__ == '__main__':
    # Bind to PORT if defined, otherwise default to 5000.
    port = int(environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
