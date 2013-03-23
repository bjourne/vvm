from datetime import date
from random import randint, sample
from string import lowercase
from unicodedata import category, name


def char_stats(ch):
    try:
        n = name(ch)
    except ValueError:
        n = None
    c = category(ch)
    return {'name' : n, 'category' : c}

def generate_name():
    categories = ('Lo', 'Lu', 'Ll')
    chars = [unichr(randint(1, 0x1fff)) for x in range(100)]
    chars = [ch for ch in chars if char_stats(ch)['category'] in categories]
    length = randint(5, 15)
    return u''.join(chars[:length])

def generate_ascii():
    return u''.join(sample(lowercase, randint(5, 15)))

def generate_date():
    while True:
        today = date.today()
        year = randint(1000, today.year - 1)
        month = randint(1, 12)
        day = randint(1, 31)
        try:
            return date(year, month, day)
        except ValueError:
            pass

if __name__ == '__main__':
    print generate_date()
