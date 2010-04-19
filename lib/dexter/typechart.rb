#!/usr/bin/env ruby

module Dexter
  class TypeChart
    TYPES = [
             :bug,
             :dark,
             :dragon,
             :electric,
             :fighting,
             :fire,
             :flying,
             :ghost,
             :grass,
             :ground,
             :ice,
             :normal,
             :poison,
             :psychic,
             :rock,
             :steel,
             :water,
            ]

    MULTIPLIERS = {
      nil => 0,
      :double_weak => 0.25,
      :weak => 0.5,
      :neutral => 1.0,
      :strong => 2.0,
      :double_strong => 4.0,
    }


    EFFECTIVENESS = {}

    # Initialize all to neutral,
    TYPES.each do |attacker|
      EFFECTIVENESS[attacker] = {}
      TYPES.each do |defender|
        EFFECTIVENESS[attacker][defender] = :neutral
      end
    end

    # then add in exceptions.
    {
      # attacker => { defender => strength, ... }
      :normal => {
        :rock => :weak,
        :ghost => nil,
        :steel => :weak,
      },

      :fire => {
        :fire => :weak,
        :water => :weak,
        :grass => :strong,
        :ice => :strong,
        :bug => :strong,
        :rock => :weak,
        :dragon => :weak,
        :steel => :strong,
      },

      :water => {
        :fire => :strong,
        :water => :weak,
        :grass => :weak,
        :ground => :strong,
        :rock => :strong,
        :dragon => :weak,
      },

      :electric => {
        :water => :strong,
        :electric => :weak,
        :grass => :weak,
        :ground => nil,
        :flying => :strong,
        :dragon => :weak,
      },

      :grass => {
        :fire => :weak,
        :water => :strong,
        :grass => :weak,
        :poison => :weak,
        :ground => :strong,
        :flying => :weak,
        :bug => :weak,
        :rock => :strong,
        :dragon => :weak,
        :steel => :weak,
      },

      :ice => {
        :fire => :weak,
        :water => :weak,
        :grass => :strong,
        :ice => :weak,
        :ground => :strong,
        :flying => :strong,
        :dragon => :strong,
        :steel => :weak,
      },

      :fighting => {
        :normal => :strong,
        :ice => :strong,
        :poison => :weak,
        :flying => :weak,
        :psychic => :weak,
        :bug => :weak,
        :rock => :strong,
        :ghost => nil,
        :dark => :strong,
        :steel => :strong,
      },

      :poison => {
        :grass => :strong,
        :poison => :weak,
        :ground => :weak,
        :rock => :weak,
        :ghost => :weak,
        :steel => nil,
      },

      :ground => {
        :fire => :strong,
        :electric => :strong,
        :grass => :weak,
        :poison => :strong,
        :flying => nil,
        :bug => :weak,
        :rock => :strong,
        :steel => :strong,
      },

      :flying => {
        :electric => :weak,
        :grass => :strong,
        :fighting => :strong,
        :bug => :strong,
        :rock => :weak,
        :steel => :weak,
      },

      :psychic => {
        :fighting => :strong,
        :poison => :strong,
        :psychic => :weak,
        :dark => nil,
        :steel => :weak,
      },

      :bug => {
        :fire => :weak,
        :grass => :strong,
        :fighting => :weak,
        :poison => :weak,
        :flying => :weak,
        :psychic => :strong,
        :ghost => :weak,
        :dark => :strong,
        :steel => :weak,
      },

      :rock => {
        :fire => :strong,
        :ice => :strong,
        :fighting => :weak,
        :ground => :weak,
        :flying => :strong,
        :bug => :strong,
        :steel => :weak,
      },

      :ghost => {
        :normal => nil,
        :psychic => :strong,
        :ghost => :strong,
        :dark => :weak,
        :steel => :weak,
      },

      :dragon => {
        :dragon => :strong,
        :steel => :weak,
      },

      :dark => {
        :fighting => :weak,
        :psychic => :strong,
        :ghost => :strong,
        :dark => :weak,
        :steel => :weak,
      },

      :steel => {
        :fire => :weak,
        :water => :weak,
        :electric => :weak,
        :ice => :strong,
        :rock => :strong,
        :steel => :weak,
      },
    }.each do |attacker, defenders|
      defenders.each do |defender, effectiveness|
        EFFECTIVENESS[attacker][defender] = effectiveness
      end
    end

    def TypeChart.strategy(defender_types)
      strats = defender_types.map {|type| single_strategy(type) }
      merge_strategies(strats)
    end

    def TypeChart.merge_strategies(strats)
      if strats.length > 2 then
        STDERR.puts "Merging more than 2 defending types isn't supported."
        STDERR.puts "    (And why would you want to do that?)"
        return nil
      end
      merged = strats[0]

      if strats.length > 1 then
        merged[:double_weaknesses] = []
        merged[:double_resistances] = []

        strats[1][:weaknesses].each do |weakness|
          if merged[:weaknesses].include? weakness then
            merged[:double_weaknesses].push weakness
            merged[:weaknesses].delete weakness

          elsif merged[:resistances].include? weakness then
            merged[:resistances].delete weakness

          elsif not merged[:immunities].include? weakness then
            merged[:weaknesses].push weakness
          end
        end

        strats[1][:resistances].each do |resistance|
          if merged[:weaknesses].include? resistance then
            merged[:weaknesses].delete resistance

          elsif merged[:resistances].include? resistance then
            merged[:double_resistances].push resistance
            merged[:resistances].delete resistance

          elsif not merged[:immunities].include? resistance then
            merged[:resistances].push resistance
          end
        end

        strats[1][:immunities].each do |immunity|
          merged[:weaknesses].delete immunity
          merged[:resistances].delete immunity
          merged[:immunities].push immunity
        end
      end

      return merged
    end

    def TypeChart.single_strategy(defender)
      strat = {
        :weaknesses => weaknesses(defender),
        :resistances => resistances(defender),
        :immunities => immunities(defender),
      }
    end

    def TypeChart.weaknesses(defender)
      types_with_effectiveness(:strong, defender)
    end

    def TypeChart.resistances(defender)
      types_with_effectiveness(:weak, defender)
    end

    def TypeChart.immunities(defender)
      types_with_effectiveness(nil, defender)
    end

    def TypeChart.types_with_effectiveness(effectiveness, defender)
      types = []
      TYPES.each do |attacker|
        types << attacker if EFFECTIVENESS[attacker][defender] == effectiveness
      end
      return types
    end
  end
end
