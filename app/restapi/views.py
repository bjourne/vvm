from app.scores.models import Score
from app.users.models import User
from flask import current_app
from flask.ext.restless import APIManager, ProcessingException

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

def filter_user(o):
    for key in ['image', 'oauth_secret', 'oauth_token']:
        del o[key]
    return o

def user_post_get_many(res):
    map(filter_user, res['objects'])
    return res

def setup_api(app, db):
    manager = APIManager(app, flask_sqlalchemy_db = db)
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
        methods = ['GET'],
        postprocessors = {
            'GET_MANY' : [user_post_get_many],
            'GET_SINGLE' : [filter_user]
            },
        max_results_per_page = None
        )
