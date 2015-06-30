require 'colorize'
require 'gemoji'

class Tile
  attr_accessor :status ,:bomb
  attr_reader :pos, :board

  NEIGHBOR_POSITIONS = [[-1,-1], [-1, 0], [-1, 1], [0, 1],
                        [1, 1], [1, 0], [1, -1], [0, -1]]

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
      Emoji.find_by_alias("triangular_flag_on_post").raw
    when :bombed
      Emoji.find_by_alias("bomb").raw
    else
      colorize_string(status.to_s)
    end
  end

  def reveal
    if @bomb
      @status = :bombed
    elsif self.status == :flagged
      puts "You have to unflag this position to reveal."
    else
      if neighbors.none? {|neighbor| neighbor.bomb}
        self.status = :interior
        neighbors.each {|neighbor| neighbor.reveal if neighbor.status == :hidden }
      else
        self.status = neighbors.select { |neighbor| neighbor.bomb }.count
      end
    end
  end

  def revealed?
    self.status != :hidden && self.status != :flagged
  end

  private

  def neighbors
    neighbor_array = []

    NEIGHBOR_POSITIONS.each do |position|
      x = self.pos[0] + position[0]
      y = self.pos[1] + position[1]
      if [x,y].all? {|el| el.between?(0,(self.board.size - 1)) }
        neighbor_array << self.board[x,y]
      end
    end

    neighbor_array
  end

  def colorize_string(str)
    case str
    when "1" then str.colorize(:blue)
    when "2" then str.colorize(:green)
    when "3" then str.colorize(:red)
    else str
    end
  end
end
