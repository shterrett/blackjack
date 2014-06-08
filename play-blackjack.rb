#!/Users/stuart/.rbenv/shims/ruby

require_relative 'blackjack'

player = Player.new
dealer = Dealer.new
deck = Deck.new
game = Game.new deck, player, dealer
game.start!
