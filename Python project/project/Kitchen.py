class Kitchen:
    def __init__(self):
        self.fridge_queue = []
        self.oven_queue = []
        self.current_oven_user = None

    def check_queue(self):
        if self.fridge_queue and self.fridge_queue[0].current_activity is None:
            self.use_fridge(self.fridge_queue[0])
        if self.current_oven_user is not None:
            self.use_oven(self.current_oven_user)
        elif self.oven_queue and self.oven_queue[0].current_activity is None:
            self.current_oven_user = self.oven_queue[0]
            self.current_oven_user.current_activity = 'cook'
            self.oven_queue.pop(0)

    def use_fridge(self, char):
        char.needs['hunger'] += 2
        if char.needs['hunger'] > 10:
            char.needs['hunger'] = 10
        self.fridge_queue.pop(0)

    def use_oven(self, char):
        char.needs['hunger'] = 10
        self.current_oven_user = None
