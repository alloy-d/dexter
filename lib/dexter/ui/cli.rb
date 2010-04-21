#!/usr/bin/env ruby
require 'term/ansicolor'
require 'trollop'
require_relative 'generic'
require_relative '../pokemon'
require_relative '../pokedb'
require_relative '../typechart'

class String
  include Term::ANSIColor
end

module Dexter
  module UI
    class CLI < Generic
      PADDING = "   "
      def initialize(use_color=true)
        super()
        @use_color = use_color
      end

      def show_all(args)
        puts
        show_basic_info(args)
        puts
        show_base_stats(args)
        puts
        show_strategy(args)
      end

      def show_basic_info(args)
        poke = retrieve(args)
        puts PADDING + "##{poke.id}: #{poke.name} (#{poke.type_string})"
      end

      def show_base_stats(args)
        poke = retrieve(args)
        outrow = [PADDING, PADDING]
        { :hp => "HP",
          :attack => "Att",
          :defense => "Def",
          :sp_attack => "SpA",
          :sp_defense => "SpD",
          :speed => "Spe",
        }.each do |sym, str|
          outrow[0] += str.ljust(4) + "   "
          outrow[1] += colorize_stat(poke.stats[sym].rjust(4))  + "   "
        end

        outrow.each {|row| puts row }
      end

      def show_strategy(args)
        types = []
        if args[:types] then
          types = parse_type_arg(args[:types])
        else
          poke = retrieve(args)
          types = poke.types
        end
        strategy = Dexter::TypeChart::strategy(types)

        { :double_weaknesses => ["x4.00", [:red, :bold]],
          :weaknesses => ["x2.00", [:red]],
          :resistances => ["x0.50", [:green]],
          :double_resistances => ["x0.25", [:green, :bold]],
          :immunities => ["Nil", [:blue, :bold]],
        }.each do |sym, style|
          if not strategy[sym].nil? and not strategy[sym].empty? then
            string = PADDING + style[0].rjust(5)
            style[1].each {|attr| string = string.send(attr) }

            types = strategy[sym].map {|type| colorize_type(type.to_s) }
            string += ": " + types.join(", ")
            puts string
          end
        end
      end

      private
      def colorize_stat(stat_str)
        stat = stat_str.to_i
        { 66 => :red,
          99 => :yellow,
          126 => :green,
          256 => :blue,
        }.each do |max_val, color|
          if stat < max_val then
            return stat_str.to_s.send(color)
          end
        end
      end

      def colorize_type(type_str)
        colors = {
          :bug => [:green],
          :dark => [:black, :bold],
          :dragon => [:blue],
          :electric => [:yellow, :bold],
          :fighting => [:red],
          :fire => [:red, :bold],
          :flying => [:cyan, :bold],
          :ghost => [:black],
          :grass => [:green, :bold],
          :ground => [:yellow],
          :ice => [:cyan],
          :normal => [],
          :poison => [:magenta, :bold],
          :psychic => [:magenta],
          :rock => [:yellow],
          :steel => [:black],
          :water => [:blue, :bold],
        }

        result = type_str
        colors[type_str.strip.intern].each do |attr|
          result = result.send(attr)
        end

        result
      end

      def parse_type_arg(types_string)
        types = types_string.split('/')
        types.map {|str| str.intern }
      end
    end
  end
end
