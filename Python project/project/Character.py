from Pet import Pet


class Character:
    def __init__(self, name, age , sex, house):
        self.name = name
        self.age = age
        self.sex = sex
        self.needs = {'hunger': 10, 'energy': 10, 'bladder': 10, 'hygiene': 10, 'fun': 10, 'comfort': 10, 'social': 10}
        self.house = house
        self.current_activity = None
        self.activity_queue = []
        self.pet = None

    def check_needs(self):
        return self.needs

    def show_info(self):
        print('Name: {}, age: {}, gender: {}, pet: {}, current activity: {}'.format(self.name, self.age, self.sex,
                                                                                    self.pet, self.current_activity))

    def empty_queue(self):
        self.activity_queue = []

    def get_pet(self, name):
        if self.pet is None:
            pet = Pet(name, self)
            self.house.pets[name] = pet
            self.pet = pet
        else:
            print('You already have a pet')

    def feed_pet(self, pet):
        if len(self.activity_queue) == 9:
            print('Too many activities in the queue')
        else:
            self.activity_queue.append(('feed', pet.name))

    def pet_feed(self, pet):
        p = self.house.pets[pet]
        p.hunger = 10

    def toilet(self):
        if len(self.activity_queue) == 9:
            print('Too many activities in the queue')
        else:
            self.activity_queue.append('toilet')

    def use_toilet(self):
        if len(self.house.bathrooms) > 1:
            if len(self.house.bathrooms[0].queue) <= len(self.house.bathrooms[1].queue):
                self.house.bathrooms[0].queue.append((self, 'toilet'))
            else:
                self.house.bathrooms[1].queue.append((self, 'toilet'))
        else:
            self.house.bathrooms[0].queue.append((self, 'toilet'))

    def shower(self):
        if len(self.activity_queue) == 9:
            print('Too many activities in the queue')
        else:
            self.activity_queue.append('shower')

    def use_shower(self):
        if len(self.house.bathrooms) > 1:
            if len(self.house.bathrooms[0].queue) <= len(self.house.bathrooms[1].queue):
                self.house.bathrooms[0].queue.append((self, 'shower'))
            else:
                self.house.bathrooms[1].queue.append((self, 'shower'))
        else:
            self.house.bathrooms[0].queue.append((self, 'shower'))

    def eat_snack(self):
        if len(self.activity_queue) == 9:
            print('Too many activities in the queue')
        else:
            self.activity_queue.append('fridge')

    def use_fridge(self):
        self.house.kitchen.fridge_queue.append(self)

    def cook_meal(self):
        if len(self.activity_queue) == 9:
            print('Too many activities in the queue')
        else:
            self.activity_queue.append('oven')

    def use_oven(self):
        self.house.kitchen.oven_queue.append(self)

    def rest(self):
        if len(self.activity_queue) == 9:
            print('Too many activities in the queue')
        else:
            self.activity_queue.append('couch')

    def use_couch(self):
        self.house.livingroom.couch_queue.append(self)

    def watch_tv(self):
        if len(self.activity_queue) == 9:
            print('Too many activities in the queue')
        else:
            self.activity_queue.append('tv')

    def use_tv(self):
        self.house.livingroom.current_tv_users.append(self)

    def sleep(self):
        if len(self.activity_queue) == 9:
            print('Too many activities in the queue')
        else:
            self.activity_queue.append('bed')

    def use_bed(self):
        done = 0
        if len(self.house.bedrooms) > 1:
            for b in self.house.bedrooms:
                if b.size_of_bed > len(b.current_users):
                    b.queue.append(self)
                    done = 1
                break
            if done == 0:
                queues = {}
                for b in self.house.bedrooms:
                    queues[b.queue] = len(b.queue)
                min(queues).append(self)
        else:
            self.house.bedrooms[0].queue.append(self)

    def interact_with(self, friend):
        if len(self.activity_queue) == 9:
            print('Too many activities in the queue')
        else:
            self.activity_queue.append(('talk', friend))

    def talk(self, friend):
        sim = self.house.family[friend]
        sim.needs['social'] += 2
        if sim.needs['social'] > 10:
            sim.needs['social'] = 10
        self.needs['social'] = 10

    def raise_alert(self):
        if self.needs['energy'] < 2 and self.current_activity in (None, 'cook'):
            self.activity_queue.insert(0, 'bed')
            print('Critical energy level at {}'.format(self.name))
        if self.needs['hunger'] < 2 and self.current_activity != 'cook':
            self.activity_queue.insert(0, 'fridge')
            print('Critical hunger level at {}'.format(self.name))

    def needs_down(self):
        for k, v in self.needs.items():
            if v > 0:
                self.needs[k] = v - 1
        if self.needs['hunger'] < 2 or self.needs['energy'] < 2:
            self.raise_alert()

    def check_queue(self):
        while self.activity_queue:
            i = self.activity_queue[0]
            if i == 'toilet':
                self.use_toilet()
            elif i == 'shower':
                self.use_shower()
            elif i == 'fridge':
                self.use_fridge()
            elif i == 'oven':
                self.use_oven()
            elif i == 'couch':
                self.use_couch()
            elif i == 'tv':
                self.use_tv()
            elif i == 'bed':
                self.use_bed()
            elif i[0] == 'talk':
                self.talk(i[1])
            else:
                self.pet_feed(i[1])
            self.activity_queue.pop(0)
