github_apps = dict(
    local = dict(
        consumer_key = 'af302866ef9902879f20',
        consumer_secret = '7ad1950118a745992a3bef25218596ce76e622ab'
        ),
    heroku = dict(
        consumer_key = 'ac93be6617ae133e4a9d',
        consumer_secret = '4eabd7668e80696803b400369a407d8c9ba5dfd9'
        )
    )
facebook_apps = dict(
    local = dict(
        consumer_key = '547798668585267',
        consumer_secret = 'f0fc004b924b0e8a5ff4587e85f045a4'
        ),
    heroku = dict(
        consumer_key = '110481785679205',
        consumer_secret = '65c29562d54e17d948e54d80ea7710f5'
        )
    )


DEBUG = True
SECRET_KEY = 'tjaba'
SQLALCHEMY_DATABASE_URI = 'postgres://nkputojaszhzjb:HCPWHC17MOyTbM-63PuJjxJWmz@ec2-54-243-235-100.compute-1.amazonaws.com:5432/dbsp24qcc7pckt'

#SQLALCHEMY_DATABASE_URI = 'postgres://outsider:gogostop@94.247.168.187:5432/vvm'


OAUTH_LOGINS = dict(
    twitter = dict(
        consumer_key = 'D2mdQG7HdYGE1E7yEL6q0A',
        consumer_secret = 'sRnp32fvkGa8tTphjSdWvLT7RX6rWiExxnsef84ID0'
        ),
    google = dict(
        consumer_key = '58907700008.apps.googleusercontent.com',
        consumer_secret = 'qHQgPUT5c9n6TBLZl6pjgieD'
        ),
    facebook = facebook_apps['local'],
    bitbucket = dict(
        consumer_key = 'X8PrGqhdtDBM9Tvb73',
        consumer_secret = 'uEc2Fz9dhzXxk3gFtKRXZpJnhnBw3MuC'
        ),
    soundcloud = dict(
        consumer_key = 'a4c71d2505b367331dd51a3664f77f48',
        consumer_secret = '948aef0304317eeed2625eb0ba7a6dd8'
        ),
    github = github_apps['local']
    )
