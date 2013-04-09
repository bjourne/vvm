from app import app, db
from app.users.models import User
from flask import (
    Blueprint,
    abort,
    jsonify,
    redirect,
    send_file,
    session,
    url_for
    )
from flask_oauth import OAuth
from flask.ext.login import (
    LoginManager,
    login_required,
    login_user,
    logout_user,
    current_user
    )
from functools import wraps
from requests import get as req_get
from Image import open as im_open, ANTIALIAS
from StringIO import StringIO

# Login Manager stuff
lm = LoginManager()
lm.setup_app(app)

@lm.user_loader
def load_user(id):
    return User.query.get(int(id))

# Views

mod = Blueprint('users', __name__)

@mod.route('/whoami')
def whoami():
    id = current_user.get_id()
    return jsonify(
        is_anon = id is None,
        display_name = getattr(current_user, 'display_name', None),
        oauth_provider = getattr(current_user, 'oauth_provider', None),
        id = id
    )

@mod.route('/show_image/<user_id>.jpg')
def show_image(user_id):
    try:
        uid = int(user_id)
    except ValueError:
        return abort(404)
    u = User.query.get(uid)
    if not u:
        return abort(404)
    return send_file(StringIO(u.image), mimetype = 'image/jpeg')

@mod.route('/logout', methods = ['POST'])
@login_required
def logout():
    logout_user()
    return jsonify(success = True)

# Oauth views
@mod.route('/auth/<provider>/login')
def oauth_login(provider):
    remote_app = remote_apps[provider]
    callback = url_for('.%s_user_info' % provider, _external = True)
    return remote_app.authorize(callback = callback)

def tokengetter():
    token = session.get('oauth')
    if current_user.is_authenticated():
        token = current_user.oauth_token, current_user.oauth_secret
    return token

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

    # Load image
    s = StringIO()
    im = im_open(StringIO(req_get(image_url).content))
    im.thumbnail((128, 128), ANTIALIAS)
    im.save(s, 'JPEG')
    user.image = s.getvalue()

    db.session.commit()
    login_user(user, remember = True)
    # Why do i need this?
    del session['oauth']
    return redirect('/static/auth_recv.html')

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
        #id, name, image_url = 
        return setup_user(provider, *func(remote_app, resp))
    return wrapper

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

oauth = OAuth()

def soundcloud_user_info(remote_app, resp):
    token = resp['access_token']
    headers = {'Authorization': 'OAuth ' + token}
    data = remote_app.get('/me.json', headers = headers).data
    return data['id'], data['full_name'], data['avatar_url']

def bitbucket_user_info(remote_app, resp):
    user = remote_app.get('user').data['user']
    return user['username'], user['display_name'], user['avatar']

def github_user_info(remote_app, resp):
    data = remote_app.get('/user').data
    return data['id'], data.get('name') or data['login'], data['avatar_url']

def facebook_user_info(remote_app, resp):
    data = remote_app.get('/me').data
    id = data['id']
    image_url = 'http://graph.facebook.com/' + id + '/picture?type=small'
    return id, data['name'], image_url

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
    return data['id'], data['name'], data['picture']

def twitter_user_info(remote_app, resp):
    name = resp['screen_name']
    id = resp['user_id']
    data = remote_app.get('users/show.json?user_id=' + id).data
    return id, name, data['profile_image_url']

# This isn't very nice.
remote_apps = {}

def setup_oauth(app):
    global remote_apps    
    oauth_logins = app.config['OAUTH_LOGINS']
    for provider, config in oauth_configs.items():
        config.update(oauth_logins[provider])

        func_name = provider + '_user_info'
        func = globals().get(func_name)
        if not func:
            fmt = 'User info func %s for %s missing.'
            raise ValueError(fmt % (func_name, provider))

        handler = create_oauth_authorized_handler(provider, func)
        remote_app = oauth.remote_app(provider, **config)
        remote_app.tokengetter(tokengetter)
        handler = remote_app.authorized_handler(handler)
        mod.add_url_rule('/auth/' + provider + '/authorized', view_func = handler)
        remote_apps[provider] = remote_app

