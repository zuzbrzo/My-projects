import unittest
from Character import Character
from House import House


class Test(unittest.TestCase):
    def setUp(self):
        self.house = House()
        self.bathroom = self.house.bathrooms[0]
        self.bedroom = self.house.bedrooms[0]
        self.kitchen = self.house.kitchen
        self.livingroom = self.house.livingroom
        self.sim = Character('sim', 25, 'm', self.house)
        self.sim.needs_down()

    def test_bathroom_use(self):
        self.bathroom.use_shower(self.sim)
        self.bathroom.use_toilet(self.sim)
        self.assertEqual((self.sim.needs['hygiene'], self.sim.needs['bladder']), (10, 10))

    def test_bathroom_queue(self):
        self.sim.use_toilet()
        self.sim.use_shower()
        self.bathroom.check_queue()
        self.assertEqual(self.sim.needs['bladder'], 10)
        self.bathroom.check_queue()
        self.assertEqual(self.sim.needs['hygiene'], 10)

    def test_kitchen(self):
        self.sim.needs['hunger'] = 5
        self.sim.use_fridge()
        self.kitchen.check_queue()
        self.assertEqual(self.sim.needs['hunger'], 7)
        self.sim.use_oven()
        self.kitchen.check_queue()
        self.assertEqual(self.kitchen.current_oven_user, self.sim)
        self.assertEqual(self.sim.needs['hunger'], 7)
        self.kitchen.check_queue()
        self.assertEqual(self.sim.needs['hunger'], 10)

    def test_livingroom(self):
        self.sim.use_tv()
        self.sim.use_couch()
        self.livingroom.check_queue()
        self.assertEqual((self.sim.needs['fun'], self.sim.needs['comfort']), (10, 10))

    def test_bedroom(self):
        self.sim.needs_down()
        self.sim.use_bed()
        self.bedroom.check_queue()
        self.assertEqual((self.sim.needs['energy'], self.sim.needs['comfort']), (8, 8))
        self.assertEqual(self.bedroom.current_users[self.sim], 2)
        self.bedroom.check_queue()
        self.assertEqual((self.sim.needs['energy'], self.sim.needs['comfort']), (8, 8))
        self.assertEqual(self.bedroom.current_users[self.sim], 1)
        self.bedroom.check_queue()
        self.assertEqual((self.sim.needs['energy'], self.sim.needs['comfort']), (8, 8))
        self.assertEqual(self.bedroom.current_users[self.sim], 0)
        self.bedroom.check_queue()
        self.assertEqual((self.sim.needs['energy'], self.sim.needs['comfort']), (10, 10))


if __name__ == "__main__":
    unittest.main()
