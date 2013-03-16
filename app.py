# -*- coding: utf-8 -*-
from config import SITE_CONFIG
from flask import Flask, jsonify, redirect, request, session, url_for
from flask_oauth import OAuth
from flask.ext.login import (
    LoginManager,
    login_required,
    login_user,
    logout_user,
    current_user
)
from flask.ext.restless import APIManager, ProcessingException
from flask.ext.sqlalchemy import SQLAlchemy
from functools import wraps
from logging import INFO, basicConfig, getLogger
from requests import get as req_get
from os import environ
from sqlalchemy.schema import CheckConstraint, UniqueConstraint

app = Flask(__name__)
app.config.update(SITE_CONFIG)

##############################################################################

db = SQLAlchemy(app)
class User(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    scores = db.relationship('Score', lazy = 'dynamic')
    oauth_provider = db.Column(db.String(255))
    oauth_id = db.Column(db.String(255))
    oauth_token = db.Column(db.String(255))
    oauth_secret = db.Column(db.String(255))
    display_name = db.Column(db.String(255))

    def is_authenticated(self):
        return True

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def get_id(self):
        return unicode(self.id)

    def __repr__(self):
        return '<User %s/%s>' % (self.oauth_provider, self.oauth_id)

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
def setup_user(oauth_provider, oauth_id, display_name, image_url):
    key = dict(
        oauth_id = unicode(oauth_id),
        oauth_provider = oauth_provider
        )
    user = User.query.filter_by(**key).first()
    if not user:
        user = User(**key)
        db.session.add(user)
    user.display_name = display_name
    user.oauth_token, user.oauth_secret = session['oauth']
    db.session.commit()
    login_user(user, remember = True)
    # Why do i need this?
    del session['oauth']
    return redirect('/static/auth_recv.html')

@app.route('/auth/<provider>/login')
def oauth_login(provider):
    callback = url_for('%s_user_info' % provider, _external = True)
    return remote_apps[provider].authorize(callback = callback)

def tokengetter():
    token = session.get('oauth')
    if current_user.is_authenticated():
        token = current_user.oauth_token, current_user.oauth_secret
    return token

def create_oauth_authorized_handler(provider, func):
    @wraps(func)
    def wrapper(resp):
        if not resp:
            raise Exception('Unknown failure!')
        if 'oauth_token' in resp:
            # Oauth 1.0 (twitter)
            oauth = resp['oauth_token'], resp['oauth_token_secret']
        else:
            oauth = resp['access_token'], 'empty'
        session['oauth'] = oauth
        remote_app = remote_apps[provider]
        id, name, image_url = func(remote_app, resp)
        return setup_user(provider, id, name, image_url)
    return wrapper

@app.route('/logout', methods = ['POST'])
@login_required
def logout():
    logout_user()
    return jsonify(success = True)

oauth = OAuth()

def soundcloud_user_info(remote_app, resp):
    token = resp['access_token']
    headers = {'Authorization': 'OAuth ' + token}
    data = remote_app.get('/me.json', headers = headers).data
    return data['id'], data['full_name'], 'coming'

def bitbucket_user_info(remote_app, resp):
    user = remote_app.get('user').data['user']
    return user['username'], user.get('display_name') or account_name, 'soon'

def github_user_info(remote_app, resp):
    data = remote_app.get('/user').data
    return data['id'], data.get('name') or data['login'], 'soon'

def facebook_user_info(remote_app, resp):
    data = remote_app.get('/me').data
    return data['id'], data['name'], 'soon'

def google_user_info(remote_app, resp):
    token = resp['access_token']
    headers = {'Authorization': 'OAuth ' + token}
    r = req_get(
        'https://www.googleapis.com/oauth2/v1/userinfo?alt=json',
        headers = headers
    )
    data = r.json
    if callable(data):
        data = data()
    return data['id'], data['name'], 'soon'

def twitter_user_info(remote_app, resp):
    name = resp['screen_name']
    id = resp['user_id']
    image_url = 'coming soon'
    return id, name, image_url

oauth_configs = dict(
    bitbucket = dict(
        base_url = 'https://api.bitbucket.org/1.0/',
        request_token_url = 'https://bitbucket.org/!api/1.0/oauth/request_token',
        access_token_url = 'https://bitbucket.org/!api/1.0/oauth/access_token',
        authorize_url = 'https://bitbucket.org/!api/1.0/oauth/authenticate'
        ),
    github = dict(
        base_url = 'https://api.github.com/',
        request_token_url = None,
        access_token_url = 'https://github.com/login/oauth/access_token',
        authorize_url = 'https://github.com/login/oauth/authorize',
        request_token_params = {'scope' : 'user:email'}
        ),
    twitter = dict(
        base_url = 'https://api.twitter.com/1/',
        request_token_url = 'https://api.twitter.com/oauth/request_token',
        access_token_url = 'https://api.twitter.com/oauth/access_token',
        authorize_url = 'https://api.twitter.com/oauth/authenticate'
        ),
    google = dict(
        base_url = 'https://www.google.com/accounts/',
        authorize_url = 'https://accounts.google.com/o/oauth2/auth',
        request_token_url = None,
        request_token_params = {
            'scope': 'https://www.googleapis.com/auth/userinfo.profile',
            'response_type': 'code'
            },
        access_token_url = 'https://accounts.google.com/o/oauth2/token',
        access_token_method = 'POST',
        access_token_params = {'grant_type': 'authorization_code'}
        ),
    facebook = dict(
        base_url = 'https://graph.facebook.com/',
        request_token_url = None,
        access_token_url='/oauth/access_token',
        authorize_url = 'https://www.facebook.com/dialog/oauth',
        request_token_params = {'display' : 'popup'}
        ),
    soundcloud = dict(
        base_url = 'https://api.soundcloud.com',
        authorize_url = 'https://api.soundcloud.com/connect',
        access_token_url = 'https://api.soundcloud.com/oauth2/token',
        request_token_url = None,
        request_token_params = {'response_type' : 'code', 'display' : 'popup'},
        access_token_params = {'grant_type' : 'authorization_code'},
        access_token_method = 'POST'
        ),
    )

remote_apps = {}
oauth_logins = app.config['OAUTH_LOGINS']
for provider, config in oauth_configs.items():
    config.update(oauth_logins[provider])

    func_name = provider + '_user_info'
    func = globals().get(func_name)
    if not func:
        fmt = 'User info func %s for %s missing.'
        raise ValueError(fmt % func_name, provider)

    handler = create_oauth_authorized_handler(provider, func)
    remote_app = oauth.remote_app(provider, **config)
    remote_app.tokengetter(tokengetter)
    handler = remote_app.authorized_handler(handler)
    app.add_url_rule('/auth/' + provider + '/authorized', view_func = handler)
    remote_apps[provider] = remote_app


##############################################################################

manager = APIManager(app, flask_sqlalchemy_db = db)

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
    data['user_id'] = get_current_user_id()
    return data

def score_pre_post(data):
    data['user_id'] = get_current_user_id()
    return data

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

manager.create_api(User, methods = ['GET'])

##############################################################################

@app.before_first_request
def setup_db():
    pass
    #db.drop_all()
    #db.create_all()

@app.route('/')
def root():
    return redirect(url_for('static', filename = 'index.html'))

@app.route('/whoami')
def whoami():
    id = current_user.get_id()
    return jsonify(
        is_anon = id is None,
        display_name = getattr(current_user, 'display_name', None),
        oauth_provider = getattr(current_user, 'oauth_provider', None),
        id = id
    )

if __name__ == '__main__':
    # Bind to PORT if defined, otherwise default to 5000.
    port = int(environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
