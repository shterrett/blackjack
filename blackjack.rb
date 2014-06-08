require 'pry'

class Deck
  VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, :J, :K, :Q, :A]
  SUITES = [:h, :d, :c, :s]

  attr_reader :cards

  def initialize(value_override: nil, suite_override: nil)
    @card_pointer = -1
    @cards = build_deck(value_override, suite_override)
  end

  def shuffle!
    @cards.shuffle!
    self
  end

  def next_card
    @card_pointer += 1
    if @card_pointer < @cards.length
      @cards[@card_pointer]
    else
      [:no_cards_remain]
    end
  end

  private

  def build_deck(value_override = nil, suite_override = nil)
    values = value_override || VALUES
    suites = suite_override || SUITES
    values.flat_map do |value|
      suites.map do |suite|
        Card.new [value, suite]
      end
    end
  end
end

class Card
  VALUE_MAP = { J: 10,
                Q: 10,
                K: 10,
                A: 1
              }
  SUITE_UTF_8 = { s: "\u{2660}",
                  h: "\u{2665}",
                  d: "\u{2666}",
                  c: "\u{2663}"
                }

  attr_reader :suite

  def initialize(card)
    @value = card[0]
    @suite = card[1]
  end

  def face_value
    @value
  end

  def high_value
    if @value == :A
      11
    else
      low_value
    end
  end

  def low_value
    if VALUE_MAP.keys.include? @value
      VALUE_MAP[@value]
    else
      @value
    end
  end

  def ==(other)
    @value == other.face_value && @suite == other.suite
  end

  def to_s
    "#{face_value}#{SUITE_UTF_8[suite]}"
  end
end

class Hand
  attr_reader :cards

  def initialize
    @cards = []
  end

  def add_card(card)
    @cards << card
  end

  def score
    aces, others = seperate_aces
    aces.reduce(base_score(others)) do |score, card|
      if score + card.high_value > 21
        score += card.low_value
      else
        score += card.high_value
      end
    end
  end

  private

  def seperate_aces
    @cards.partition { |card| card.face_value == :A }
  end

  def base_score(cards)
    cards.reduce(0) do |score, card|
      score += card.low_value
    end
  end
end

module PlayerSharedMethods

  attr_reader :hand

  def cards
    hand.cards
  end

  def add_card(card)
    hand.add_card(card)
  end

  def score
    hand.score
  end
end

class Player
  include PlayerSharedMethods

  def initialize
    @hand = Hand.new
  end

  def print_hand
    puts("Your Hand: " +
         cards.map { |card| card.to_s }.join(" ")
        )
  end

  def print_final_hand
    print_hand
  end

  def take_turn(game)
    puts 'Next Turn'
    print_hand
    print 'Hit (h) or Stay (s)?: '
    choice = gets.chomp
    if choice.downcase == 'h' || choice.downcase == 'hit'
      game.deal_to(self)
      puts cards.last.to_s
    else
      game.stay
    end
  end
end

class Dealer
  include PlayerSharedMethods

  def initialize
    @hand = Hand.new
  end

  def print_hand
    puts("Dealer: XX " +
         cards.last(cards.length - 1).map { |card| card.to_s }.join(" ")
        )
  end

  def print_final_hand
    puts("Dealer: " +
         cards.map { |card| card.to_s }.join(" ")
        )
  end

  def take_turn(game)
    puts 'Dealers Turn'
    print_hand
    if score <= 12
      puts 'Hit me'
      game.deal_to(self)
      puts cards.last.to_s
    else
      puts 'Stay'
      game.stay
    end
  end
end

class PrivatelyTestable
  def self.publicize_methods!
    hidden_methods = self.private_instance_methods + self.protected_instance_methods
    self.class_eval { public *hidden_methods }
  end
end

class Game < PrivatelyTestable
  attr_reader :deck, :players

  def initialize(deck, *players, test:  false)
    @deck = deck
    @players = players
    @test = test
    @game_on = true
    @stays = 0
  end

  def start!
    deck.shuffle!
    2.times { deal_all }
    players.each { |player| player.print_hand }
    take_turns
  end

  def stay
    @stays += 1
  end

  def deal_to(player)
    player.add_card(deck.next_card)
  end

  private

  def take_turns
    while @game_on && !@test
      players.each do |player|
        player.take_turn(self)
        validate_score(player)
      end
      check_end_conditions
      reset_stays
    end
  end

  def deal_all
    players.each do |player|
      deal_to(player)
    end
  end

  def reset_stays
    @stays = 0
  end

  def validate_score(player)
    if player.score > 21
      puts 'Bust!'
    end
  end

  def check_end_conditions
    if all_stay? || zero_or_one_valid?
      end_game
    end
  end

  def all_stay?
    players.length == @stays
  end

  def zero_or_one_valid?
    players.reject { |player| player.score > 21 }.length <= 1
  end

  def find_winner
    players.reject { |player| player.score > 21 }
           .max { |a, b| a.score <=> b.score }
  end

  def end_game
    @game_on = false
    winner = find_winner
    players.each do |player|
      if player == winner
        print 'Winner! '
      elsif player.score > 21
        print 'Over! '
      end
      player.print_final_hand
    end
  end
end
