from random import choice


class Pet:
    def __init__(self, name, owner):
        self.owner = owner
        self.name = name
        self.hunger = 10

    def alert(self):
        if self.hunger < 2:
            print('{} is hungry'.format(self.name))
        self.owner.feed_pet(self.name)

    def act(self):
        p = [0,0,0,1]
        if self.hunger < 4:
            p = [0,1,1,1]
        r = choice(p)
        if r == 0:
            self.owner.needs['fun'] += 3
            if self.owner.needs['fun'] > 10:
                self.owner.needs['fun'] = 10
            self.owner.needs['comfort'] += 3
            if self.owner.needs['comfort'] > 10:
                self.owner.needs['comfort'] = 10
        else:
            self.owner.needs['fun'] -= 1
            if self.owner.needs['fun'] < 0:
                self.owner.needs['fun'] = 0
            self.owner.needs['comfort'] -= 2
            if self.owner.needs['comfort'] < 0:
                self.owner.needs['comfort'] = 0

    def hunger_down(self):
        if self.hunger > 0:
            self.hunger -= 1