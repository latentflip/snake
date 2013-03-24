colors = require 'colors'

class Head
  constructor: (position, direction) ->
    @position = position
    @direction = direction
    @child = new Tail( [ @position[0], @position[1]-1 ], @)
    @changedDirection = false

  step: (limits) =>
    @child.step()
    @position[0] += @direction[0]
    @position[1] += @direction[1]

    @position[0] = 0 if @position[0] > limits[0]
    @position[1] = 0 if @position[1] > limits[1]

    @position[0] = limits[0] if @position[0] < 0
    @position[1] = limits[1] if @position[1] < 0
    @changedDirection = false

  render: (world) =>
    world[@position[1]][@position[0]] = ' '
    world = @child.render(world)

  grow: =>
    @child.grow(@direction)

class Tail
  constructor: (position, parent, child) ->
    @position = position
    @parent = parent
    @child = child

  grow: (direction) ->
    if @child
      @child.grow(direction)
    else
      @child = new Tail([ @position[0] - direction[0], @position[1] - direction[1] ], @)

  step: ->
    @child.step() if @child
    @position = [ @parent.position[0], @parent.position[1] ]

  render: (world) =>
    @child.render(world) if @child
    if world[@position[1]][@position[0]] == ' '
      throw 'DEAD'
    else
      world[@position[1]][@position[0]] = ' '
    world
    
class Food
  constructor: (position) ->
    @position = position

  render: (world) ->
    world[@position[1]][@position[0]] = 'x'.green
    world
    

class World
  constructor: (size, snake) ->
    @size = size
    @snake = snake
    @food = new Food([ 20, 10 ])

  step: =>
    @snake.step([@size[0], @size[1]])
    @collide()

  collide: =>
    if @snake.position[0] == @food.position[0] and @snake.position[1] == @food.position[1]
      @snake.grow()
      @newRandomFood()

  newRandomFood: ->
    @food = new Food([ Math.floor(Math.random() * @size[0]),
                       Math.floor(Math.random() * @size[1]) ])

  render: =>
    grid = @makeGrid() 
    grid = @food.render(grid)
    grid = @snake.render(grid)
    console.log grid.map( (r) -> r.join('')).join("\n")

  makeGrid: ->
    grid = []
    [width, height] = @size
    
    for y in [0..height]
      do (y) ->
        row = []
        row.push('▋'.green) for x in [0..width]
        grid.push(row)
    grid


snake = new Head([10,10], [1,0])


world = new World([20,20], snake)
setInterval ->
  console.log("\n\n")
  world.step()
  world.render()
, 100


stdin = process.stdin
stdin.setRawMode true
stdin.resume()
stdin.setEncoding 'utf8'

stdin.on 'data', (key) ->
  if key == '\u0003'
    process.exit()
  if key == '\u001b[A'
    unless snake.direction[1] == 1 || snake.changedDirection
      snake.changedDirection = true
      snake.direction = [0,-1]
  if key == '\u001b[B'
    unless snake.direction[1] == -1 || snake.changedDirection
      snake.changedDirection = true
      snake.direction = [0,1]
  if key == '\u001b[C'
    unless snake.direction[0] == -1 || snake.changedDirection
      snake.changedDirection = true
      snake.direction = [1,0]
  if key == '\u001b[D'
    unless snake.direction[0] == 1 || snake.changedDirection
      snake.changedDirection = true
      snake.direction = [-1,0]
  #console.dir(key)
