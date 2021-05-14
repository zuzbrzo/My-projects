class Bathroom:
    def __init__(self):
        self.queue = []

    def check_queue(self):
        if self.queue and self.queue[0][0].current_activity is None:
            if self.queue[0][1] == 'shower':
                self.use_shower(self.queue[0][0])
            else:
                self.use_toilet(self.queue[0][0])
            self.queue.pop(0)

    def use_toilet(self, person):
        person.needs['bladder'] = 10

    def use_shower(self, person):
        person.needs['hygiene'] = 10

