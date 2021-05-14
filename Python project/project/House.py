from Character import Character
from Bathroom import Bathroom
from Kitchen import Kitchen
from Livingroom import Livingroom
from Bedroom import Bedroom
from random import uniform


class House:
    def __init__(self):
        self.bathrooms = (Bathroom(),)
        self.kitchen = Kitchen()
        self.livingroom = Livingroom()
        self.bedrooms = (Bedroom(2),)
        self.rooms = (self.kitchen, self.livingroom) + self.bathrooms + self.bedrooms
        self.time = 0
        self.family = {}
        self.pets = {}
        self.address = None

    def move_in_sim(self, name, age, sex):
        if len(self.family) == 7:
            print('Too many family members')
        else:
            self.family[name] = Character(name, age, sex, self)

    def show_needs(self):
        for k, v in self.family.items():
            print('{} needs: {}'.format(k, v.needs))
        for k, v in self.pets.items():
            print('{} hunger: {}'.format(k, v.hunger))

    def add_bathroom(self):
        if len(self.bathrooms) == 3:
            print('Too many bathrooms')
        else:
            self.bathrooms += (Bathroom(),)

    def add_bedroom(self, k):
        if len(self.bedrooms) == 4:
            print('Too many bedrooms')
        else:
            self.bedrooms += (Bedroom(k),)

    def run(self, steps):
        for s in range(steps):
            self.time += 1
            for pet in self.pets.values():
                pet.hunger_down()
                p = uniform(0, 1)
                if p < 0.1:
                    pet.act()
                    print('{} acted'.format(pet.name))
            for sim in self.family.values():
                sim.needs_down()
                sim.check_queue()
            for room in self.rooms:
                room.check_queue()

