from House import House
import unittest


class TestHouse(unittest.TestCase):
    def setUp(self):
        self.house = House()
        self.sim1 = self.house.move_in_sim('sim1', 20, 'w')
        self.sim2 = self.house.move_in_sim('sim2', 45, 'm')

    def test_move_in(self):
        self.house.move_in_sim('sim3', 4, 'w')
        self.assertEqual(self.house.family['sim3'].name, 'sim3')
        self.assertEqual(self.house.family['sim3'].age, 4)
        self.assertEqual(self.house.family['sim3'].sex, 'w')
        self.assertEqual(len(self.house.family), 3)

    def test_add_bathroom(self):
        self.house.add_bathroom()
        self.assertEqual(len(self.house.bathrooms), 2)

    def test_add_bedroom(self):
        self.house.add_bedroom(1)
        self.assertEqual(len(self.house.bedrooms), 2)

    def test_run(self):
        self.house.run(3)
        for s in self.house.family.values():
            for v in s.needs.values():
                self.assertEqual(v, 7)
        self.assertEqual(self.house.time, 3)


if __name__ == "__main__":
    unittest.main()
