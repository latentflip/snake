class Head
  constructor: (position, direction) ->
    @position = position
    @direction = direction
    @child = new Tail( [ @position[0]-1, @position[1] ], @)
    @changedDirection = false

  updateDirection: (newDirection) =>
    unless @changedDirection
      if newDirection == 'up' and @direction[1] != 1
        @changedDirection = true
        @direction = [0, -1]
      if newDirection == 'down' and @direction[1] != -1
        @changedDirection = true
        @direction = [0, 1]
      if newDirection == 'left' and @direction[0] != 1
        @changedDirection = true
        @direction = [-1, 0]
      if newDirection == 'right' and @direction[0] != -1
        @changedDirection = true
        @direction = [1, 0]


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
    world[@position[1]][@position[0]] = 'x'
    world
    

class World
  constructor: (size, snake, renderFunction, onGameEnd) ->
    @size = size
    @snake = snake
    @food = new Food([ 20, 10 ])
    @renderFunction = renderFunction
    @onGameEnd = onGameEnd || (-> )
    @score = 0

  step: =>
    @snake.step([@size[0], @size[1]])
    @collide()

  collide: =>
    if @snake.position[0] == @food.position[0] and @snake.position[1] == @food.position[1]
      @snake.grow()
      @newRandomFood()
      @score++

  newRandomFood: ->
    @food = new Food([ Math.floor(Math.random() * @size[0]),
                       Math.floor(Math.random() * @size[1]) ])

  render: =>
    try
      grid = @makeGrid()
      grid = @food.render(grid)
      grid = @snake.render(grid)
      @renderFunction(grid)
    catch err
      @onGameEnd(@score)

  makeGrid: ->
    grid = []
    [width, height] = @size
    
    for y in [0..height]
      do (y) ->
        row = []
        row.push('▋') for x in [0..width]
        grid.push(row)
    grid


if typeof window != 'undefined'
  window.Head = Head
  window.World = World


if typeof module != 'undefined' && this.module != module
  colors = require 'colors'

  snake = new Head([10,10], [1,0])

  render = (grid) ->
    console.log grid.map( (r) -> r.join('').green).join("\n")

  world = new World([20,20], snake, render)

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
      snake.updateDirection('up')
    if key == '\u001b[B'
      snake.updateDirection('down')
    if key == '\u001b[C'
      snake.updateDirection('right')
    if key == '\u001b[D'
      snake.updateDirection('left')
