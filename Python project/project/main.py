from House import House

house = House()
print("Hello!\nType in your house address:")
house.address = str(input())
print('For now you have one bathroom, one bedroom, one kitchen and one living room. Do you want to add some more rooms?'
      '\n1. Bathroom\n2. Bedroom\n3. no')
odp = input()
while odp != '3':
    if odp == '1':
        house.add_bathroom()
        print('Your house now have {} bathrooms.'.format((len(house.bathrooms))))
    elif odp == '2':
        print('How big bed do you want? For 1 person or 2?')
        n = input()
        while n not in ('1', '2'):
            print('Please enter 1 or 2:')
            n = input()
        house.add_bedroom(int(n))
        print('Your house now have {} bedrooms.'.format((len(house.bedrooms))))
    else:
        print('Please, type in 1, 2 or 3.')
        odp = input()
        continue
    print('Do you want to add any more room?\n1. Bathroom\n2. Bedroom\n3. no')
    odp = input()

print('Now it\'s time to add family members!')
odp = '1'
while odp != '2':
    if odp != '1':
        print('Please enter 1 or 2')
        odp = input()
        continue
    print('Please name the person:')
    name = input()
    print('Enter the persons age:')
    age = input()
    while not age.isdigit():
        print('Please enter a number:')
        age = input()
    print('Enter the person\'s gender:')
    sex = input()
    house.move_in_sim(name, age, sex)
    print('Do you want to add another family member?\n1. yes\n2. no')
    odp = input()

print('Time to play!')
print('What do you want to do now?\n1. Check stats\n2. Choose person to play\n3. Run the game\n4. Add new family member'
      '\n5. Add rooms\n6. Check activity queues\n7. Exit the game')
odp = input()
while odp != '7':
    if odp not in ('1', '2', '3', '4', '5', '6'):
        print('Please enter number from the list:')
        odp = input()
        continue
    if odp == '1':
        house.show_needs()
    elif odp == '2':
        list2 = []
        print('Which person do you want to play?')
        for name, sim in house.family.items():
            list2.append(sim)
            print('{}. {}'.format(len(list2), name))
        n = input()
        while True:
            if n.isdigit():
                if int(n) in list(range(1, len(list2) + 1)):
                    break
            print('Please enter a number from list:')
            n = input()
        sim = list2[int(n) - 1]
        odp2 = 1
        while odp2 != '14':
            print('What do you want to do?\n1. Check needs\n2. Check info\n3. Erase queue of activities\n'
                  '4. Get a pet\n5. Feed pet\n6. Interact with someone\n7. Eat snack\n8. Cook meal\n9. Use toilet'
                  '\n10. Take shower\n11. Sleep\n12. Rest on the couch\n13. Watch tv\n14. Go back')
            odp2 = input()
            while True:
                if odp2.isdigit():
                    if int(odp2) in list(range(1, 15)):
                        break
                print('Please enter a number from list:')
                odp2 = input()
            if odp2 == '1':
                print(sim.check_needs())
            elif odp2 == '2':
                sim.show_info()
            elif odp2 == '3':
                sim.empty_queue()
            elif odp2 == '4':
                print('Name your pet:')
                petname = input()
                sim.get_pet(petname)
            elif odp2 == '5':
                pet = sim.pet
                if len(house.pets) > 1 or sim.pet is None:
                    print('Which pet do you want to feed?')
                    list2 = []
                    for name, pet in house.pets.items():
                        list2.append(name)
                        print('{}. {}'.format(len(list2), name))
                    n = input()
                    while True:
                        if n.isdigit():
                            if int(n) in list(range(1, len(list2) + 1)):
                                break
                        print('Please enter a number from list:')
                        n = input()
                    pet = list2[int(n) - 1]
                sim.feed_pet(pet)
            elif odp2 == '6':
                if len(house.family) == 1:
                    print('No one to interact with.')
                else:
                    print('With who do you want to interact?')
                    list2 = []
                    for name, friend in house.family.items():
                        if friend == sim:
                            continue
                        list2.append(friend)
                        print('{}. {}'.format(len(list2), name))
                    n = input()
                    while True:
                        if n.isdigit():
                            if int(n) in list(range(1, len(list2) + 1)):
                                break
                        print('Please enter a number from list:')
                        n = input()
                    friend = list2[int(n) - 1]
                    sim.interact_with(friend.name)
            elif odp2 == '7':
                sim.eat_snack()
            elif odp2 == '8':
                sim.cook_meal()
            elif odp2 == '9':
                sim.toilet()
            elif odp2 == '10':
                sim.shower()
            elif odp2 == '11':
                sim.sleep()
            elif odp2 == '12':
                sim.rest()
            elif odp2 == '13':
                sim.watch_tv()
    elif odp == '3':
        print('How many steps do you want to run the game for?')
        n = input()
        while not n.isdigit():
            print('Please enter a number:')
            n = input()
        house.run(int(n))
        house.show_needs()
        for sim in house.family.values():
            print('{} current activity: {}'.format(sim.name, sim.current_activity))
    elif odp == '4':
        print('Please name the person:')
        name = input()
        print('Enter the persons age:')
        age = input()
        while not age.isdigit():
            print('Please enter a number:')
            age = input()
        print('Enter the person\'s gender:')
        sex = input()
        house.move_in_sim(name, age, sex)
    elif odp == '5':
        print('What room do you want to add?\n1. Bathroom\n2. Bedroom\n3. Go back')
        n = input()
        while not n in ('1', '2', '3'):
            print('Please enter a number from list:')
            n = input()
        if n == '1':
            house.add_bathroom()
            print('Your house now have {} bathrooms.'.format((len(house.bathrooms))))
        elif odp == '2':
            print('How big bed do you want? For 1 person or 2?')
            n = input()
            while n not in ('1', '2'):
                print('Please enter 1 or 2:')
                n = input()
            house.add_bedroom(int(n))
            print('Your house now have {} bedrooms.'.format((len(house.bedrooms))))
    else:
        for sim in house.family.values():
            print('{} to do list: {}'.format(sim.name, sim.activity_queue))
    print('What do you want to do next?\n1. Check stats\n2. Choose person to play\n3. Run the game\n4. Add new family '
          'member\n5. Add rooms\n6. Check activity queues\n7. Exit the game')
    odp = input()

print('Thank you for playing!')
