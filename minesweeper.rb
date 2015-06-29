class Board
  def initialize(size,num_bombs)
    @grid = populate_grid(size, num_bombs)
  end

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, value)
    @grid[row][col] = value
  end

  def populate_grid(size, num_bombs)
    grid = Array.new(size) { Array.new(size) { Tile.new(self) } }

  end

  def get_random_positions(num_bombs)
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

end

class Tile
  def initialize(board, bomb)
    @board = board
    @bomb = bomb
    @status = :hidden
  end

  def reveal
    if !@bomb
      @status = :revealed
    else
      @status = :bombed
    end
  end

  def flag
    @status = :flagged
  end

  def neighbors

  end

  def neighbor_bomb_count

  end
end
