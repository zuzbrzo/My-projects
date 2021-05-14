import unittest
from Character import Character
from House import House


class Test(unittest.TestCase):
    def setUp(self):
        self.house = House()
        self.house.move_in_sim('sim1', 15, 'm')
        self.house.move_in_sim('sim2', 60, 'w')
        self.sim1 = self.house.family['sim1']
        self.sim2 = self.house.family['sim2']

    def test_empty_queue(self):
        self.sim1.sleep()
        self.sim1.toilet()
        self.assertNotEqual(self.sim1.activity_queue, [])
        self.sim1.empty_queue()
        self.assertEqual(self.sim1.activity_queue, [])

    def test_needs_down(self):
        for need in self.sim1.needs.values():
            self.assertEqual(need,10)
        self.sim1.needs_down()
        for need in self.sim1.needs.values():
            self.assertEqual(need,9)

    def test_pet(self):
        self.sim1.get_pet('Lara')
        self.assertEqual(self.sim1.house.pets['Lara'], self.sim1.pet)
        self.assertEqual(self.sim1.pet.name, 'Lara')
        self.sim1.feed_pet(self.sim1.pet)
        self.assertEqual(self.sim1.activity_queue, [('feed', 'Lara')])
        self.sim1.pet.hunger = 7
        self.sim1.pet_feed('Lara')
        self.assertEqual(self.sim1.pet.hunger, 10)

    def test_shower(self):
        self.sim1.shower()
        self.assertEqual(self.sim1.activity_queue, ['shower'])
        self.sim1.use_shower()
        self.assertEqual(self.house.bathrooms[0].queue, [(self.sim1, 'shower')])
        self.house.add_bathroom()
        self.sim2.use_shower()
        self.assertEqual(self.house.bathrooms[1].queue, [(self.sim2, 'shower')])

    def test_talk(self):
        self.sim1.needs['social'] = 6
        self.sim2.needs['social'] = 6
        self.sim1.interact_with(self.sim2.name)
        self.assertEqual(self.sim1.activity_queue, [('talk', self.sim2.name)])
        self.sim1.talk(self.sim2.name)
        self.assertEqual((self.sim1.needs['social'], self.sim2.needs['social']), (10, 8))

    def test_check_queue(self):
        self.sim1.rest()
        self.sim1.eat_snack()
        self.sim1.get_pet('Lara')
        self.sim1.pet.hunger = 7
        self.sim1.feed_pet(self.sim1.pet)
        self.sim1.check_queue()
        self.assertEqual(self.house.livingroom.couch_queue,[self.sim1])
        self.sim1.check_queue()
        self.assertEqual(self.house.kitchen.fridge_queue, [self.sim1])
        self.sim1.check_queue()
        self.assertEqual(self.sim1.pet.hunger, 10)



if __name__ == "__main__":
    unittest.main()
