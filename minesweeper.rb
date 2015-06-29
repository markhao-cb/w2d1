require 'byebug'

class Board
  attr_reader :bomb_positions, :grid ,:size

  def initialize(size, num_bombs)
    populate_grid(size, num_bombs)
    @size = size
    @num_bombs = num_bombs
  end

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, value)
    @grid[row][col] = value
  end

  def populate_grid(size, num_bombs)
    # @grid = Array.new(size) { Array.new(size) { Tile.new(self) } }
    @grid = Array.new(size) { Array.new(size) { nil } }
    (0...size).each do |row|
      (0...size).each do |col|
        self[row, col] = Tile.new(self, false, [row, col])
      end
    end

    set_bomb_positions(num_bombs)
  end

  def set_bomb_positions(num_bombs)
    position_array = []
    @bomb_positions = []
    @grid.each_with_index do |row, row_index|
      # debugger
      row.each_with_index do |col, col_index|
        position_array << [row_index, col_index]
      end
    end

    num_bombs.times do
      new_bomb_position = position_array.shuffle.shift
      self[*new_bomb_position].bomb = true
      @bomb_positions << new_bomb_position
    end
  end

  def won?
    positions = []
    (0...self.size).each do |row|
      (0...self.size).each do |col|
        positions << [row, col] unless bomb_positions.include?([row, col])
      end
    end

    positions.all? do |pos|
      self[*pos].revealed?
    end
  end

  def render
    print "  "
    size.times {|i| print "#{i} "}
    puts
    self.grid.each_with_index do |row, row_index|
      print "#{row_index} "
      row.each_with_index do |col, col_index|
        print "#{self[row_index,col_index]} "
      end
      puts
    end
  end

  def reveal(won)
    if won
      self.bomb_positions.each { |pos| self[*pos].status = :flagged }
    else
      self.bomb_positions.each { |pos| self[*pos].status = :bombed }
    end
  end

end

class Tile
  attr_accessor :status ,:bomb, :pos, :board

  Neighbor_positions = [[-1,-1], [-1, 0], [-1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1]]

  def initialize(board, bomb, pos)
    @board = board
    @bomb = bomb
    @status = :hidden
    @pos = pos
  end

  def to_s
    case status
    when :hidden
      '*'
    when :interior
      '_'
    when :flagged
      'F'
    when :bombed
      'B'
    else
      status.to_s
    end
  end

  def reveal
    if @bomb
      @status = :bombed
    else
      if neighbors.none? {|neighbor| neighbor.bomb}
        self.status = :interior
        neighbors.each {|neighbor| neighbor.reveal if neighbor.status == :hidden }
      else
        self.status = neighbors.select { |neighbor| neighbor.bomb }.count
      end
    end
  end

  def neighbors
    neighbor_array = []

    Neighbor_positions.each do |position|
      x = self.pos[0]+position[0]
      y = self.pos[1]+position[1]
      if x.between?(0,(self.board.size - 1)) && y.between?(0, (self.board.size - 1))
        neighbor_array << self.board[x,y]
      end
    end

    neighbor_array
  end

  def revealed?
    self.status != :hidden && self.status != :flagged
  end

end

class Game
  attr_reader :board

  def initialize(size, num_bombs)
    @board = Board.new(size, num_bombs)
  end

  def play
    until over?
      board.render
      input = get_input
      make_move(input)
    end

    if self.board.won?
      board.reveal(true)
      puts "You won!"
    else
      board.reveal(false)
      puts "Game over!"
    end
    board.render
  end

  def make_move(input)
    row, col = input[0]
    type = input[1]

    tile = self.board[row, col]
    if type == 'r'
      tile.reveal
    elsif type == 'f'
      tile.status = tile.status == :flagged ? :hidden : :flagged
    end
  end

  def get_input
    row, col, type = nil, nil, nil

    until valid_position?([row,col])
      puts "Enter a row."
      row = gets.chomp.to_i
      puts "Enter a column."
      col = gets.chomp.to_i
    end

    until valid_move?(type)
      puts "Enter 'r' or 'f' to reveal or flag the position."
      type = gets.chomp.downcase
    end

    [[row, col], type]
  end

  def valid_position?(input)
    input.each do |el|
      return false unless el.is_a?(Integer) && el.between?(0, 8)
    end
    !self.board[*input].revealed?
  end

  def valid_move?(input)
    input == 'r' || input == 'f'
  end

  def over?
    self.board.grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        return true if self.board[row_index,col_index].status == :bombed
        return true if self.board.won?
      end
    end

    false
  end

end

game = Game.new(9,1)
game.play
