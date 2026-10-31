"""Layout tolerance must not remove semantic safety requirements."""
import unittest

from doc_assertions import assert_prose_in, assert_prose_not_in


class DocumentClaims(unittest.TestCase):
    def test_layout_whitespace_is_ignored(self):
        assert_prose_in(self, 'keine neue Installation', 'Hinweis: keine\n  neue Installation.')
        assert_prose_in(self, '| not-run | n/a |', '| not-run    |   n/a |')

    def test_missing_negation_is_still_a_failure(self):
        with self.assertRaises(AssertionError):
            assert_prose_in(self, 'keine neue Installation', 'neue Installation')

    def test_negative_claims_cover_wrapped_text(self):
        with self.assertRaises(AssertionError):
            assert_prose_not_in(self, 'automatische Installation', 'automatische\nInstallation')


if __name__ == '__main__':
    unittest.main()
