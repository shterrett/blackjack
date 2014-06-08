# Blackjack

This was inspired by talking to some [LaunchAcademy](http://www.launchacademy.com/) students. I was curious how I
would solve it now that I have more experience.

## The Problem

Create a ruby program that (to a first approximation) allows for the interactive
playing of blackjack.

### The approximation

Use the simple rules:

+ One deck
+ Hit or stay only
+ Highest score under 21 wins
+ Over 21 is a bust
+ No actual betting

## Challenges

Handling the Ace was a pain. It's value depends on the value of the hand.
Finding a logical place for the logic to calculate a score was difficult.

All of the possible routes for the game - if this, then that... Factoring the
conditional logic without resorting to giant case statements was hard. There are
still a few long if/else that I may try to eliminate eventually.

I don't know how to interactively test console apps, so I resorted to testing
the private control logic of the `Game` class directly. Not the cleanest ever,
but gives me decent security. This
[gist](https://gist.github.com/methodmissing/20349) inspired the
`PrivatelyTestable` superclass.

## To Play

`$ git clone https://github.com/shterrett/blackjack.git`

`$ cd blackjack`

`$ chmod u+x play-blackjack.rb`

`$ ./play-blackjack.rb`
