from app import db
from sqlalchemy.orm import deferred
from sqlalchemy.schema import CheckConstraint, UniqueConstraint

class User(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    scores = db.relationship('Score', lazy = 'dynamic')
    display_name = db.Column(db.String(255), nullable = False)
    display_slug = db.Column(db.String(255), nullable = False, unique = True)
    image = deferred(
        db.Column(db.LargeBinary(length = 128 * 1024), nullable = False)
        )

    # These are not to be exposed.
    oauth_provider = db.Column(db.String(255), nullable = False)
    oauth_id = db.Column(db.String(255), nullable = False)
    oauth_token = db.Column(db.String(255), nullable = False)
    oauth_secret = db.Column(db.String(255), nullable = False)

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
