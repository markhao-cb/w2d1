require_relative 'game'
require 'yaml'

def valid_input?(input)
  input == 'l' || input == 'n'
end

def load_game
  puts "Please enter the filename: "
  filename = gets.chomp
  filename = "#{filename}.yml"
  data = File.read(filename)
  game = YAML.load(data)
end

def play_game
  answer = nil
  until valid_input?(answer)
    puts "New game or load game? (n / l)."
    answer = gets.chomp.downcase
    if answer == "n"
      game = Game.new(9,2)
    elsif answer == "l"
      game = load_game
    else
      puts "Invalid input."
    end
  end
  game.play
end

if __FILE__ == $PROGRAM_NAME
  play_game
end
