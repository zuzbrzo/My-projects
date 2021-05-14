import unittest
from Character import Character
from Pet import Pet
from House import House


class Test(unittest.TestCase):
    def setUp(self):
        self.pet = Pet('kitten', Character('owner', 30, 'w', House()))

    def test_hunger_down(self):
        self.pet.hunger_down()
        self.assertEqual(self.pet.hunger, 9)

    def test_act(self):
        self.pet.owner.needs['fun'] = 7
        self.pet.owner.needs['comfort'] = 7
        self.pet.act()
        self.assertIn(self.pet.owner.needs['fun'], (6, 10))
        self.assertIn(self.pet.owner.needs['fun'], (5, 10))


if __name__ == "__main__":
    unittest.main()
