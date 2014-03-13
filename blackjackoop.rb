# Black Jack OOP game


module CardOptions
  VALUES = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10',
               'Jack', 'Queen', 'King']
  SUITS = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
end

module Handable
  def total #return hard and soft totals
    sum = 0
    self.hand.each do |h|
      if h.value == 'Ace'
        sum += 11
      elsif h.value.to_i == 0
        sum += 10
      else
        sum += h.value.to_i
      end
    end
    aces = self.hand.select {|h| h.value=='Ace'}
    num_aces = aces.count
    soft_sum = sum
    num_aces.times do
      if sum > 21
        sum -= 10
        soft_sum = sum
      else
        sum -= 10
      end
    end
    return sum, soft_sum
  end

  def bust?
    total[0] > Blackjack::BLACKJACK_AMOUNT
  end

  def card_display(hand=self.hand, total=self.total)
    puts
    puts "#{name} has the following cards:"
    puts hand
    if (total[0].to_i!=0)
      if total[0] == total[1]
        puts "With a hand total of #{total[0]}."
      else
        puts "With a soft-total of #{total[1]}"\
          " and hard-total of #{total[0]}."
      end
    end
  end
end

class Card
  include CardOptions

  attr_reader :value, :suit

  def initialize(v, s)
    self.value = v
    self.suit = s
  end

  def value=(v)
    if VALUES.include?(v.to_s.capitalize)
      @value = v.to_s.capitalize
    else
      puts "Error: Card value not recognised. "\
        "Last valid value used/reset to default."
      @value ||=VALUES[1]
    end
  end

  def suit=(s)
    if SUITS.include?(s.to_s.capitalize)
      @suit = s.to_s.capitalize
    else
      puts "Error: Card suit not recognised. "\
        "Last valid suit used/reset to default."
      @suit ||=SUITS[3]
    end
  end

  def to_s
    "#{value} of #{suit}"
  end
end

class Deck
  include CardOptions

  attr_accessor :cards

  def initialize
    @cards = []
    VALUES.each do |v|
      SUITS.each do |s|
        @cards << Card.new(v,s)
      end
    end
    @cards.shuffle!
  end

  def deal!(hand)
    hand << cards.pop
  end
end

class Player
  include Handable
  attr_accessor :name, :hand

  def initialize(name,hand =[])
    @name = name
    @hand = hand
  end
end

class Dealer
  include Handable
  attr_accessor :hand
  attr_reader :name

  def initialize(hand =[])
    @hand = hand
    @name = 'Dealer'
  end
end

#Black Jack Game engine
class Blackjack
  BLACKJACK_AMOUNT = 21
  PLAYER_FORCE_STAY = 18
  DEALER_HIT_UNTIL = 17
  attr_accessor :deck, :player, :dealer
  attr_reader :player_final_total, :dealer_final_total

  def initialize
    @deck= Deck.new
    @player = Player.new($current_name ||='Player1')
    @dealer = Dealer.new
  end

  def start
    if $current_name == 'Player1'
      $current_name = player.name = get_name
      puts "", "Welcome #{player.name}!", ""
    end
    deal_cards
    show_hands
    player_turn
    dealer_turn
    compare_hands
  end

  def get_name
    puts 'Please enter your name:'
    gets.chomp
  end

  def deal_cards
    2.times{
      deck.deal!(player.hand)
      deck.deal!(dealer.hand)
    }
  end

  def show_hands
    puts "","Both you and the dealer have been dealt 2 cards each."
    puts dealer.card_display([dealer.hand[0],'and another card.'],0)
    puts player.card_display
  end

  def player_turn
    puts 'You get to go first.'

    while true
      puts 'What would you like to do 1)hit or 2)stay?'
      input = gets.chomp
      action = input.downcase
      case action
      when 'stay', '2'
        break
      when 'hit', '1'
        if player.total[0] < PLAYER_FORCE_STAY
          deck.deal!(player.hand)
          player.card_display
          if player.bust?
            puts "OH NO!!! You've busted!"
            break
          end
        else
          puts "You already have a total 18 or higher, you can not hit anymore."
        end
      else
        puts "I'm sorry, I don't understand your action."
        puts "Please enter either, 'hit'=1 or 'stay'=2", ""
      end
    end
    @player_final_total = player.total[1]
    if @player_final_total ==BLACKJACK_AMOUNT
      if player.hand.size ==2
        puts 'Congratulations - you have Blackjack!'
      else
        puts 'Congratulations - you have a perfect 21 score.'
      end
    end
    @player_final_total  
  end

  def dealer_turn
    until dealer.total[1] >= DEALER_HIT_UNTIL
      deck.deal!(dealer.hand)   
    end

    dealer.card_display
    @dealer_final_total = dealer.total[1]
  end

  def compare_hands
    if player_final_total == dealer_final_total
      puts 'This game is a push (tie).'
    elsif player.bust? && dealer.bust?
      puts 'Both you and the dealer are bust - the game is a tie.'
    elsif player.bust?
      puts 'You are bust! Dealer wins this game.'
    elsif dealer.bust?
      puts 'Dealer is bust. You win!'
    elsif player_final_total > dealer_final_total
      puts 'Congratulations your total is higher than the dealer, you win!'
    else
      puts 'Sorry the dealer has a higher total than you. Dealer wins.'
    end
  end
end

def replay?
 while true
    puts "",'Would you like to play again?'
    answer = gets.chomp.downcase
    
    case answer
    when 'yes', 'y'
      return true
    when 'no', 'n'
      return false
    else
      puts "I'm sorry, I don't understand your answer. "\
        "Please answer 'yes' or 'no'."
    end
  end 
end

puts "", "~~~~~~~~~~~~~Welcome to Blackjack!~~~~~~~~~~~~~~~~"
while true
  game = Blackjack.new
  game.start
  exit if replay? ==false
end 