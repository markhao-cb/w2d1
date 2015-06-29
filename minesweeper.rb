class Board
  attr_reader :bomb_positions

  def initialize(size, num_bombs)
    populate_grid(size, num_bombs)
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
        @grid[row, col] = Tile.new(self, false, [row, col])
      end
    end

    set_bomb_positions(num_bombs)
  end

  def set_bomb_positions(num_bombs)
    @bomb_positions = []
    @grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        @bomb_positions << [row_index, col_index]
      end
    end

    num_bombs.times do
      new_bomb_position = position_array.shuffle.shift
      self[*new_bomb_position].bomb = true
    end
  end

  def won?
    positions = []
    (0...size).each do |row|
      (0...size).each do |col|
        positions << [row, col] unless bomb_positions.include?([row, col])
      end
    end

    positions.all? do |pos|
      self[*pos].status != :flagged && self[*pos].status != :hidden }
    end
  end

  def render

  end

end

class Tile
  attr_writer :status

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
    else
      status.to_s
    end
  end

  def reveal
    if @bomb
      @status = :bombed
    else
      if neighbors.none? {|neighbor| neighbor.bomb}
        neighbors.each {|neighbor| neighbor.reveal}
        self.status = :interior
      else
        self.status = neighbors.select { |neighbor| neighbor.bomb }.count
      end
    end
  end

  def flag
    @status = :flagged
  end

  def neighbors
    neighbor_array = []
    Neighbor_positions.each do |position|
      x = self.pos[0]+position[0]
      y = self.pos[1]+position[1]
      if x.between?(0,self.board.size) && y.between(0,self.board.size)
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
    board.render
    until over?
      input = get_input

    end
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
    !self.board[input].revealed?
  end

  def valid_move?(input)
    input == 'r' || input == 'f'
  end

  def over?
    self.board.grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        return true if self.board.grid[row_index,col_index].status == :bombed
        return true if self.board.won?
      end
    end

    false
  end

end
