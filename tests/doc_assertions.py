"""Document claims ignore layout whitespace, never words or negations."""
import re


def prose(value):
    return re.sub(r'\s+', ' ', value).strip()


def assert_prose_in(case, expected, actual, msg=None):
    case.assertIn(prose(expected), prose(actual), msg)


def assert_prose_not_in(case, expected, actual, msg=None):
    case.assertNotIn(prose(expected), prose(actual), msg)
