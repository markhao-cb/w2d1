require 'byebug'
class Board
  attr_reader :bomb_positions, :grid ,:size

  def initialize(size, num_bombs)
    @bomb_positions = []
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

  def won?
    positions = get_all_positions
    positions -= @bomb_positions

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

  private

    def populate_grid(size, num_bombs)
      @grid = Array.new(size) { Array.new(size) { nil } }
      (0...size).each do |row|
        (0...size).each do |col|
          self[row, col] = Tile.new(self, false, [row, col])
        end
      end

      set_bomb_positions(num_bombs)
    end

    def set_bomb_positions(num_bombs)
      position_array = get_all_positions
      num_bombs.times do
        position_array = position_array.shuffle
        new_bomb_position = position_array.shift
        self[*new_bomb_position].bomb = true
        @bomb_positions << new_bomb_position
      end
    end

    def get_all_positions
      position_array = []
      @grid.each_with_index do |row, row_index|
        row.each_with_index do |col, col_index|
          position_array << [row_index, col_index]
        end
      end
      position_array
    end
end
