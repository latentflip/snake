// Generated by CoffeeScript 1.3.3
(function() {
  var Food, Head, Tail, World, colors, render, snake, stdin, world,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Head = (function() {

    function Head(position, direction) {
      this.grow = __bind(this.grow, this);

      this.render = __bind(this.render, this);

      this.step = __bind(this.step, this);

      this.updateDirection = __bind(this.updateDirection, this);
      this.position = position;
      this.direction = direction;
      this.child = new Tail([this.position[0], this.position[1] - 1], this);
      this.changedDirection = false;
    }

    Head.prototype.updateDirection = function(newDirection) {
      if (!this.changedDirection) {
        if (newDirection === 'up' && this.direction[1] !== 1) {
          this.changedDirection = true;
          this.direction = [0, -1];
        }
        if (newDirection === 'down' && this.direction[1] !== -1) {
          this.changedDirection = true;
          this.direction = [0, 1];
        }
        if (newDirection === 'left' && this.direction[0] !== 1) {
          this.changedDirection = true;
          this.direction = [-1, 0];
        }
        if (newDirection === 'right' && this.direction[0] !== -1) {
          this.changedDirection = true;
          return this.direction = [1, 0];
        }
      }
    };

    Head.prototype.step = function(limits) {
      this.child.step();
      this.position[0] += this.direction[0];
      this.position[1] += this.direction[1];
      if (this.position[0] > limits[0]) {
        this.position[0] = 0;
      }
      if (this.position[1] > limits[1]) {
        this.position[1] = 0;
      }
      if (this.position[0] < 0) {
        this.position[0] = limits[0];
      }
      if (this.position[1] < 0) {
        this.position[1] = limits[1];
      }
      return this.changedDirection = false;
    };

    Head.prototype.render = function(world) {
      world[this.position[1]][this.position[0]] = ' ';
      return world = this.child.render(world);
    };

    Head.prototype.grow = function() {
      return this.child.grow(this.direction);
    };

    return Head;

  })();

  Tail = (function() {

    function Tail(position, parent, child) {
      this.render = __bind(this.render, this);
      this.position = position;
      this.parent = parent;
      this.child = child;
    }

    Tail.prototype.grow = function(direction) {
      if (this.child) {
        return this.child.grow(direction);
      } else {
        return this.child = new Tail([this.position[0] - direction[0], this.position[1] - direction[1]], this);
      }
    };

    Tail.prototype.step = function() {
      if (this.child) {
        this.child.step();
      }
      return this.position = [this.parent.position[0], this.parent.position[1]];
    };

    Tail.prototype.render = function(world) {
      if (this.child) {
        this.child.render(world);
      }
      if (world[this.position[1]][this.position[0]] === ' ') {
        throw 'DEAD';
      } else {
        world[this.position[1]][this.position[0]] = ' ';
      }
      return world;
    };

    return Tail;

  })();

  Food = (function() {

    function Food(position) {
      this.position = position;
    }

    Food.prototype.render = function(world) {
      world[this.position[1]][this.position[0]] = 'x';
      return world;
    };

    return Food;

  })();

  World = (function() {

    function World(size, snake, renderFunction) {
      this.render = __bind(this.render, this);

      this.collide = __bind(this.collide, this);

      this.step = __bind(this.step, this);
      this.size = size;
      this.snake = snake;
      this.food = new Food([20, 10]);
      this.renderFunction = renderFunction;
    }

    World.prototype.step = function() {
      this.snake.step([this.size[0], this.size[1]]);
      return this.collide();
    };

    World.prototype.collide = function() {
      if (this.snake.position[0] === this.food.position[0] && this.snake.position[1] === this.food.position[1]) {
        this.snake.grow();
        return this.newRandomFood();
      }
    };

    World.prototype.newRandomFood = function() {
      return this.food = new Food([Math.floor(Math.random() * this.size[0]), Math.floor(Math.random() * this.size[1])]);
    };

    World.prototype.render = function() {
      var grid;
      grid = this.makeGrid();
      grid = this.food.render(grid);
      grid = this.snake.render(grid);
      return this.renderFunction(grid);
    };

    World.prototype.makeGrid = function() {
      var grid, height, width, y, _fn, _i, _ref;
      grid = [];
      _ref = this.size, width = _ref[0], height = _ref[1];
      _fn = function(y) {
        var row, x, _j;
        row = [];
        for (x = _j = 0; 0 <= width ? _j <= width : _j >= width; x = 0 <= width ? ++_j : --_j) {
          row.push('▋');
        }
        return grid.push(row);
      };
      for (y = _i = 0; 0 <= height ? _i <= height : _i >= height; y = 0 <= height ? ++_i : --_i) {
        _fn(y);
      }
      return grid;
    };

    return World;

  })();

  if (typeof window !== 'undefined') {
    window.Head = Head;
    window.World = World;
  }

  if (typeof module !== 'undefined' && this.module !== module) {
    colors = require('colors');
    snake = new Head([10, 10], [1, 0]);
    render = function(grid) {
      return console.log(grid.map(function(r) {
        return r.join('').green;
      }).join("\n"));
    };
    world = new World([20, 20], snake, render);
    setInterval(function() {
      console.log("\n\n");
      world.step();
      return world.render();
    }, 100);
    stdin = process.stdin;
    stdin.setRawMode(true);
    stdin.resume();
    stdin.setEncoding('utf8');
    stdin.on('data', function(key) {
      if (key === '\u0003') {
        process.exit();
      }
      if (key === '\u001b[A') {
        snake.updateDirection('up');
      }
      if (key === '\u001b[B') {
        snake.updateDirection('down');
      }
      if (key === '\u001b[C') {
        snake.updateDirection('left');
      }
      if (key === '\u001b[D') {
        return snake.updateDirection('right');
      }
    });
  }

}).call(this);
