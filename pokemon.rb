#!/usr/bin/env ruby

#require './pokemon_types'

class Pokemon
  attr_accessor :id, :name, :types, :base_stats
  def initialize(id, name)
    @id = id
    @name = name
    @base_stats = {
      :hp => 0,
      :attack => 0,
      :defense => 0,
      :special_attack => 0,
      :special_defense => 0,
      :speed => 0,
    }
    @types = []
  end

  def has_base_stat(stat, value)
    @base_stats[stat] = value
  end

  def has_type(type)
    @types << type
  end

  def to_s
    string = "#{@id}: #{@name}\t"
    string += "(#{@types[0]}" + (@types[1] ? "/#{@types[1]}" : "") + ")\n     "
    string += "HP:#{@base_stats[:hp]} "
    string += "A:#{@base_stats[:attack]} "
    string += "D:#{@base_stats[:defense]} "
    string += "SpA:#{@base_stats[:special_attack]} "
    string += "SpD:#{@base_stats[:special_defense]} "
    string += "Spe:#{@base_stats[:speed]}"
  end
end
