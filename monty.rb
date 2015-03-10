require 'contracts'
include Contracts

# Useful things!
def reload!
  load './monty.rb'
end

class Door
  attr_reader :number, :item
  def initialize(number, item)
    @number = number
    @item = item
  end

  def inspect
    "#<Door @number=#{@number} @item=#{@item}>"
  end
end

# Represent the doors
Contract None => ArrayOf[Door]
def make_doors
  %i(car goat goat).shuffle.each_with_index.map do |item,index|
    Door.new(index + 1, item)
  end
end

# Initial contentant choice
Contract ArrayOf[Door] => Door
def choose_door(doors)
  doors.sample
end

# Returns door number of a goat door
Contract ArrayOf[Door], Door => Door
def reveal_goat(doors, contestant_door)
  doors.select do |door|
    door.item == :goat && door != contestant_door
  end.first
end

# When the contenstant switches
Contract ArrayOf[Door], Door, Door => Door
def switch_door(doors, goat_door, contestant_door)
  doors.reject do |door|
    door == goat_door ||
      door == contestant_door
  end.first
end

# Win or lose?
Contract Door => Symbol
def result(contestant_door)
  if contestant_door.item == :car
    :win
  else
    :lose
  end
end
# => :win
# => :lose

# Simulates a single run of the game with a strategy
Contract Symbol => Symbol
def run_game(strategy)
  doors = make_doors
  contestant_door = choose_door(doors)
  goat_door = reveal_goat(doors, contestant_door)
  if strategy == :switch
    contestant_door = switch_door(doors, goat_door, contestant_door)
  end
  result(contestant_door)
end
# => :win, :lose

# Which is best??!?!?!?!!?
Contract Symbol, Num => Num
def run_strategy(strategy, rounds)
  rounds.times.select do
    run_game(strategy) == :win
  end.count
end

Contract None => Hash
def win_counts
  {
    stick: run_strategy(:stick, 10_000),
    switch: run_strategy(:switch, 10_000)
  }
end
