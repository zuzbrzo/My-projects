class Livingroom:
    def __init__(self):
        self.current_couch_users = []
        self.current_tv_users = []
        self.couch_queue = []

    def check_queue(self):
        self.use_tv()
        for _ in range(3):
            if self.couch_queue != [] and len(self.current_couch_users) < 3 and self.couch_queue[0].current_activity\
                    is None:
                self.current_couch_users.append(self.couch_queue[0])
                self.couch_queue.pop(0)
        self.use_couch()

    def use_couch(self):
        for sim in self.current_couch_users:
            sim.needs['comfort'] = 10
        self.current_couch_users = []

    def use_tv(self):
        for sim in self.current_tv_users:
            sim.needs['fun'] = 10
