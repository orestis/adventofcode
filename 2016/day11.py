import Queue

def pairs(l):
    l = list(l)
    pairs = []
    while l:
        p = l.pop()
        pairs.extend([(p, el) for el in l])
    return pairs

assert pairs([4, 3, 2, 1]) == [(1, 4), (1, 3), (1, 2), (2, 4), (2, 3), (3, 4)]

def valid_pair(p):
    if len(p) == 1: return True
    a, b = p
    if a[0] == "G" and b[0] == "G":
        return True
    if a[0] == "M" and b[0] == "M":
        return True
    if (a[0] == "G" and b[0] == "M") or (a[0] == "M" and b[0] == "G"):
        return a[1] == b[1]
    return False

assert True == valid_pair(("MH", "ML"))
assert False == valid_pair(("GH", "ML"))

def shielded_microchip(p):
    a, b = p
    if (a[0] == "G" and b[0] == "M") or (a[0] == "M" and b[0] == "G"):
        return a[1] == b[1] and "M" + a[1]
    return False


assert "MH" == shielded_microchip(("MH", "GH"))
assert False == shielded_microchip(("ML", "GH"))

def valid_floor(floor):
    shielded_microchips = [shielded_microchip(p) for p in pairs(floor) if shielded_microchip(p)]
    left = list(floor)
    while shielded_microchips:
        left.remove(shielded_microchips.pop())

    return all(valid_pair(p) for p in pairs(left))


assert True == valid_floor(["GH", "MH"])
assert False == valid_floor(["GH", "MH", "ML"])
assert True == valid_floor(["GL", "GH", "MH"])
assert True == valid_floor(["GL", "GS"])
assert True == valid_floor(["ML", "MS"])

def test_input():
    return (0, (("MH", "ML"), ("GH",), ("GL",), tuple()))

def valid_passengers((elev, floors)):
    curr_floor = floors[elev]
    possible_passengers = pairs(curr_floor) + [tuple([x]) for x in curr_floor]
    possible_passengers = [p for p in possible_passengers if valid_pair(p)]

    possible = []
    for p in possible_passengers:
        fl = list(curr_floor)
        pp = list(p)
        while pp:
            fl.remove(pp.pop())
        if valid_floor(fl):
            possible.append(p)
    return possible

curr = test_input()
assert [("ML", "MH"), ("MH",), ("ML",)] == valid_passengers(curr)

assert [("GL", "GH"), ("MH", "GH"), ("MH",), ("GL",)] == valid_passengers((0, (("GH", "MH", "GL"), tuple(), tuple(), ())))


def generate_new_state((elev, floors)):
    curr_floor = floors[elev]
    passengers = valid_passengers((elev, floors))
    new_positions = [x for x in [elev + 1, elev - 1] if 0 <= x <= 3]
    new_floors = [(p, floors[p] + passen, list(passen)) for p in new_positions for passen in passengers]
    new_floors = [floor for floor in new_floors if valid_floor(floor[1])]

    new_states = []
    for (p, floor, passen) in new_floors:
        new_curr_floor = list(curr_floor)
        while passen:
            new_curr_floor.remove(passen.pop())
        new_floors_list = list(floors)
        new_floors_list[elev] = tuple(new_curr_floor)
        new_floors_list[p] = floor
        new_states.append((p, tuple(new_floors_list)))
    return new_states

def process(state, seen):
    seen.add(state)
    children = generate_new_state(state)
    return [c for c in children if (c not in seen)]


def walk_queue(q, nq, end_state, seen, depth):
    try:
        while True:
            curr = q.get_nowait()
            if len(curr[1][3]) == end_state:
                print "FOUND AT DEPTH", depth
                print curr
                return
            children = process(curr, seen)
            for c in children:
                nq.put(c)

    except Queue.Empty:
        print "GOING DEEPER!!!!!!!!!!!! ", depth
        if depth > 40: return
        walk_queue(nq, Queue.Queue(), end_state, seen, depth+1)


def puzzle_input():
    return (0, (("GP", "GS", "GT", "MT"), ("MP", "MS"), ("GQ", "GR", "MQ", "MR"), tuple()))


def solve_queue():
    final_state = 10
    q = Queue.Queue()
    print "input", puzzle_input()
    q.put(puzzle_input())
    print "queue", q, "of size", q.qsize()
    walk_queue(q, Queue.Queue(), final_state, set(), 0)

solve_queue()
