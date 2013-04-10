import re
from unidecode import unidecode

_punct_re = re.compile(r'[\t !"#$%&\'()*\-/<=>?@\[\\\]^_`{|},.]+')


def slugify(text, delim = u'-'):
    """Generates an ASCII-only slug."""
    result = []
    for word in _punct_re.split(text.lower()):
        result.extend(unidecode(word).split())
    return unicode(delim.join(result))

def slugify_unique(text, existing, delim = u'-'):
    slug = orig_slug = slugify(text, delim)
    idx = 2
    while slug in existing:
        slug = '%s-%d' % (orig_slug, idx)
        idx += 1
    return slug

