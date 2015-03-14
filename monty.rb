# This was live-coded (with a cheat sheet) at rorosyd on Tuesday 10th March
# 2015. Actually, what is below is slightly different to what I live coded.
# The differences are:
#
# 1) This code has method contracts. I found that using the Contracts gem was
#    super useful while rehearsing, and would have been really useful during 
#    live-coding if I didn't have a cheat sheet. Shout-out to pseudo static
#    typing.
# 2) This code has comments.

# The code is written bottom-up so that there would be working code at all
# stages during the live-coding session, without a long gap between writing code
# and running it in the REPL. It could have been written top-down (which would
# have provided better context to the audience) but would have required a bit
# more forethought to have the code runnable in the REPL while only partially
# implemented. If I was to do the talk again, I would rehearse top-down.
#
# Also if I had a longer time slot, I might have even avoided rehearsing fully
# so as to arrive at the solution in collaboration with the audience. That may
# have been more engaging.

require 'contracts'
include Contracts

# Lets us reload the code easily while live-coding.
def reload!
  load './monty.rb'
end

# A door has a number and an item behind it.
class Door
  attr_reader :number, :item

  def initialize(number, item)
    @number = number
    @item = item
  end

  # When live coding on a projector, the fonts are bigger so there isn't much
  # room - so override the default inspect implementation and replace with one
  # that doesn't have the object IDs.
  def inspect
    "#<Door @number=#{@number} @item=#{@item}>"
  end
end

# The initial state of the game. An array of Door objects number 1, 2, 3.
# Two have a goat, one has a car. Order is random.
Contract None => ArrayOf[Door]
def initial_state
  %i(car goat goat).shuffle.each_with_index.map do |item,index|
    Door.new(index + 1, item)
  end
end

# Initial contestant choice.
Contract ArrayOf[Door] => Door
def choose_door(doors)
  doors.sample
end

# Returns door number of a goat door.
Contract ArrayOf[Door], Door => Door
def reveal_goat(doors, contestant_door)
  doors.select do |door|
    door.item == :goat && door != contestant_door
  end.first
end

# Picks the last door that remains after the contestant has made their initial
# choice and Monty has revealed a goat.
Contract ArrayOf[Door], Door, Door => Door
def switch_door(doors, goat_door, contestant_door)
  doors.reject do |door|
    door == goat_door ||
      door == contestant_door
  end.first
end

# Determine if the contestant wins.
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

# Simulates a single run of the game with a strategy.
Contract Symbol => Symbol
def run_game(strategy)
  doors = initial_state
  contestant_door = choose_door(doors)
  goat_door = reveal_goat(doors, contestant_door)
  if strategy == :switch
    contestant_door = switch_door(doors, goat_door, contestant_door)
  end
  result(contestant_door)
end
# => :win, :lose

# Runs a strategy for a number of rounds and returns how many times that
# strategy won the game.
Contract Symbol, Num => Num
def run_strategy(strategy, rounds)
  rounds.times.select do
    run_game(strategy) == :win
  end.count
end

# Runs the two strategies 10,000 times and returns the win counts.
Contract None => Hash
def win_counts
  {
    stick: run_strategy(:stick, 10_000),
    switch: run_strategy(:switch, 10_000)
  }
end

