require 'set'
require_relative 'DFA'

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map do |state|
      follow_rules_for(state, character)
    end.to_set
  end

  def follow_rules_for(state, character)
    rules_for(state, character).map { |rule| rule.follow  }
  end

  def rules_for(state, character)
    rules.select { |rule| rule.applies_to?(state, character) }
  end

  def follow_free_moves(states)
    more_states = next_states(states, nil)
    if more_states.subset?(states)
      states
    else
      follow_free_moves(states + more_states)
    end
  end
end

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  def accepting?
    (current_states & accept_states).any?
  end

  def read_character(character)
    self.current_states = rulebook.next_states(current_states, character)
  end

  def read_string(str)
    str.chars.each { |character| read_character(character) }
  end

  def current_states
    rulebook.follow_free_moves(super)
  end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accepting?(str)
    to_nfa.tap { |nfa| nfa.read_string(str) }.accepting?
  end

  def to_nfa
    NFA.new(Set[start_state], accept_states, rulebook)
  end
end
