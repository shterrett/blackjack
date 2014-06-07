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
