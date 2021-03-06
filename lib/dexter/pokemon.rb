#!/usr/bin/env ruby

#require './pokemon_types'

module Dexter
  class Pokemon
    attr_accessor :pokedex_id, :name, :forme, :types, :stats

    def initialize(info)
      @stats = {}
      @types = []

      merge!(info)
    end

    def id
      str = pokedex_id.to_s
      if forme
        str += "-" + forme.downcase.gsub(/[^a-z]+/, "-")
      end
      str
    end

    def merge!(info)
      @pokedex_id = Integer(info["pokedex_id"]) if not info["pokedex_id"].nil?
      @name = info["name"] if not info["name"].nil?
      @forme = info["forme"] if not info["forme"].nil?

      if not info["base_stats"].nil? then
        info["base_stats"].each_pair {|k,v| @stats[k.intern] = v }
      end

      @types[0] = info["type1"].intern if not info["type1"].nil?
      @types[1] = info["type2"].intern if not info["type2"].nil?
    end

    def has_stat(stat, value)
      @stats[stat] = value
    end

    def has_type(type)
      @types << type.intern if not type.nil?
    end

    def type1() @types[0] end
    def type2() @types[1] end
    def hp() @stats[:hp] end
    def attack() @stats[:attack] end
    def defense() @stats[:defense] end
    def special_attack() @stats[:sp_attack] end
    def special_defense() @stats[:sp_defense] end
    def speed() @stats[:speed] end

    def type_string
      string = "#{@types[0]}"
      string += "/#{@types[1]}" if not @types[1].nil?
      return string
    end

    def to_s
      string = "#{@pokedex_id.to_s.rjust(3)}: #{@name}"
      string += " (#{@forme})" if @forme
      string += "\t(#{type_string})"

      if not @stats.empty? then
        string += "\n     "
        string += "HP:#{@stats[:hp]} " if not @stats[:hp].nil?
        string += "A:#{@stats[:attack]} " if not @stats[:attack].nil?
        string += "D:#{@stats[:defense]} " if not @stats[:defense].nil?
        string += "SpA:#{@stats[:sp_attack]} " if not @stats[:sp_attack].nil?
        string += "SpD:#{@stats[:sp_defense]} " if not @stats[:sp_defense].nil?
        string += "Spe:#{@stats[:speed]}" if not @stats[:speed].nil?
      end
      return string
    end
  end
end
