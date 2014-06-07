require 'minitest/autorun'
require_relative 'blackjack'

describe Deck do
  it 'creates a deck of cards' do
    deck = Deck.new(value_override: [1, 2, 3],
                    suite_override: [:a, :b, :c]
                   )

    deck.cards.must_equal [[1, :a], [1, :b], [1, :c],
                           [2, :a], [2, :b], [2, :c],
                           [3, :a], [3, :b], [3, :c],
                          ].map { |card| Card.new card }
  end

  it 'shuffles the deck' do
    deck = Deck.new
    initial_cards = deck.cards.clone

    deck.shuffle!

    deck.cards.wont_equal initial_cards
    deck.cards.length.must_equal initial_cards.length
    deck.cards.each do |card|
      initial_cards.must_include card
    end
  end

  it 'deals the cards in order' do
    deck = Deck.new.shuffle!

    number_deals = deck.cards.length - 1
    (0..number_deals).each do |index|
      deck.next_card.must_equal deck.cards[index]
    end
  end

  it 'returns an error message when the deck is empty' do
    deck = Deck.new.shuffle!
    deck.cards.length.times { deck.next_card }
    deck.next_card.must_equal [:no_cards_remain]
  end
end

describe Card do
  it 'returns the face_value and suite of a card' do
    card = Card.new([:J, :c])

    card.face_value.must_equal :J
    card.suite.must_equal :c
  end

  it 'returns the high_value for an Ace' do
    card = Card.new [:A, :s]
    card.high_value.must_equal 11
  end

  it 'returns the low_value for an Ace' do
    card = Card.new [:A, :s]
    card.low_value.must_equal 1
  end

  it 'returns the high and low value as equal for all other cards' do
    face_card = Card.new [:K, :s]
    number_card = Card.new [5, :d]

    face_card.low_value.must_equal 10
    face_card.high_value.must_equal face_card.low_value

    number_card.low_value.must_equal 5
    number_card.high_value.must_equal number_card.low_value
  end

  it 'scores "face cards" as 10' do
    card = Card.new([:J, :d])

    card.low_value.must_equal 10
  end

  it 'scores number cards at their value' do
    card = Card.new([5, :h])

    card.low_value.must_equal 5
  end

  describe '#==' do
    it 'is equal to another card if the value and suite are equal' do
      card = Card.new([8, :c])
      other = Card.new([8, :c])

      card.must_equal other
    end

    it 'is not equal if the value is different' do
      card = Card.new([9, :c])
      other = Card.new([8, :c])

      card.wont_equal other
    end

    it 'is not equal if the suite is different' do
      card = Card.new([8, :d])
      other = Card.new([8, :c])

      card.wont_equal other
    end
  end
end

describe Hand do
  it 'accumulates cards' do
    cards = [Card.new([2, :h]), Card.new([3, :s])]

    hand = Hand.new
    hand.add_card(cards[0])
    hand.add_card(cards[1])

    hand.cards.must_equal cards
  end

  describe 'scoring' do
    it 'adds the value of cards to get the score' do
      cards = [Card.new([2, :h]), Card.new([3, :s])]

      hand = Hand.new
      hand.add_card(cards[0])
      hand.add_card(cards[1])

      hand.score.must_equal 5
    end

    it 'scores an "Ace" as 11' do
      cards = [Card.new([:A, :c]), Card.new([6, :h])]

      hand = Hand.new

      cards.each do |card|
        hand.add_card(card)
      end

      hand.score.must_equal 17
    end

    it 'scores an "Ace" as 1 if 11 would put the score over 21' do
      cards = [Card.new([7, :h]),
               Card.new([:A, :c]),
               Card.new([9, :d])
              ]

      hand = Hand.new
      cards.each do |card|
        hand.add_card(card)
      end

      hand.score.must_equal 17
    end

    it 'returns a score > 21 if that is the lowest score' do
      cards = [Card.new([10, :h]),
               Card.new([10, :d]),
               Card.new([10, :c])
              ]

      hand = Hand.new
      cards.each do |card|
        hand.add_card(card)
      end

      hand.score.must_equal 30
    end

    it 'returns the highest possible score < 21 for multiple Aces' do
      cards = [Card.new([7, :h]),
               Card.new([:A, :c]),
               Card.new([:A, :d])
              ]

      hand = Hand.new
      cards.each do |card|
        hand.add_card(card)
      end

      hand.score.must_equal 19
    end
  end
end
