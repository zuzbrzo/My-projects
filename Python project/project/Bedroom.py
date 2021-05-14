class Bedroom:
    def __init__(self, size):
        self.current_users = {}
        self.queue = []
        self.size_of_bed = size

    def check_queue(self):
        if self.size_of_bed == 2:
            for _ in range(2):
                if self.queue and self.queue[0].current_activity is None:
                    self.current_users[self.queue[0]] = 3
                    self.queue.pop(0)
        else:
            if self.queue and self.queue[0].current_activity is None:
                self.current_users[self.queue[0]] = 3
                self.queue.pop(0)
        self.use_bed()

    def use_bed(self):
        todel = []
        for k, v in self.current_users.items():
            if v == 0:
                k.needs['energy'] = 10
                k.needs['comfort'] += 2
                if k.needs['comfort'] > 10:
                    k.needs['comfort'] = 10
                todel.append(k)
                k.current_activity = None
            else:
                self.current_users[k] = v - 1
                k.needs['energy'] += 1
                if k.needs['energy'] > 10:
                    k.needs['energy'] = 10
                k.current_activity = 'sleep for {} more'.format(v-1)
        for s in todel:
            del self.current_users[s]