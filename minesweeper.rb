class Board
  def initialize(size,num_bombs)
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
    position_array = []
    @grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        position_array << [row_index, col_index]
      end
    end

    num_bombs.times do
      new_bomb_position = position_array.shuffle.shift
      self[*new_bomb_position].bomb = true
    end
  end

  def render

  end

end

class Tile
  attr_reader :status

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
    when :
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

  def neighbor_bomb_count

  end
end

class Game

end
