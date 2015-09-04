/*
a mangling of Peter Norvig's famous sudoku solver in LiveScript
*/

assert = require \assert
{concat, lines, tail, lists-to-obj, chars, unique, fold1, join, replicate, minimum-by, obj-to-pairs, reject} = require \prelude-ls

cross = (as, bs) ->
    [a + b for a in as for b in bs]

digits = \123456789
rows = \ABCDEFGHI
cols = digits
squares = cross rows, cols
unitlist =
    [cross rows, c for c in cols] ++
    [cross r, cols for r in rows] ++
    [cross rs, cs for rs in <[ ABC DEF GHI ]> for cs in <[ 123 456 789 ]> ]
units = {["#s", [u for u in unitlist when s in u]] for s in squares}
peers = {["#s", units[s] |> concat |> reject (is s) |> unique] for s in squares}

export test = !->
    assert.strict-equal 81 squares.length
    assert.strict-equal 27 unitlist.length
    for s in squares
        assert.strict-equal 3 units[s].length
        assert.strict-equal 20 peers[s].length
    assert.deep-equal units['C2'], [ <[ A2 B2 C2 D2 E2 F2 G2 H2 I2 ]> <[ C1 C2 C3 C4 C5 C6 C7 C8 C9 ]> <[ A1 A2 A3 B1 B2 B3 C1 C2 C3 ]> ]
    assert.deep-equal peers['C2'], <[ A2 B2 D2 E2 F2 G2 H2 I2 C1 C3 C4 C5 C6 C7 C8 C9 A1 A3 B1 B3 ]>

parse-grid = (grid) ->
    values = {["#s", digits] for s in squares}
    for s, d of grid-values grid when d in digits
        values = assign values, s, d
    values

grid-values = (grid) ->
    grid |> fold1 (+) |> chars |> lists-to-obj squares

assign = (values, s, d) ->
    values[s] = d
    for s in peers[s]
        if not eliminate values, s, d
            return false
    values

eliminate = (values, s, d) ->
    if d not in values[s]
        return values
    values[s] = values[s].replace d, ''
    if values[s].length is 0
        return false
    else if values[s].length is 1
        d2 = values[s]
        for s2 in peers[s]
            if not eliminate values, s2, d2
                return false
    for u in units[s]
        dplaces = [s for s in u when d in values[s]]
        if dplaces.length is 0
            return false
        else if dplaces.length is 1
            if not assign values, dplaces.0, d
                return false
    values

done = (values) ->
    for s in squares
        if values[s].length is not 1
            return false
    true

some = (seq) ->
    for e in seq
        if e then return e
    false

dup = (obj) ->
    d = {}
    for key of obj
        d[key] = obj[key]
    d

search = (values) ->
    if not values
        return false
    if done values
        return values
    sq = values
        |> obj-to-pairs
        |> reject (.1.length < 2)
        |> minimum-by (.1.length)
        |> (.0)
    for d in values[sq]
        if search assign dup(values), sq, d
            return that
    false

export solve = (grid) ->
    search parse-grid grid

export display = (xs) !->
    width = 3
    line = join \+ replicate 3 (\-- * width)
    for r in rows
        output = ''
        for c in cols
            output += xs[r+c] + ' '
            output += '|' if c in \36
        console.log output
        console.log line if r in \CF
