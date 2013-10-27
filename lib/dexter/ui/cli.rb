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

      def respond_to_missing?(meth)
        self.methods.include?("#{meth}_single".to_sym)
      end
      def method_missing(meth, *args, &blk)
        single_meth = "#{meth}_single".to_sym
        if self.methods.include?(single_meth)
          pokes = retrieve(args[0])
          pokes.each do |poke|
            self.send(single_meth, poke)
          end
        else super
        end
      end

      def show_all_single(poke)
        puts
        show_basic_info_single(poke)
        puts
        show_base_stats_single(poke)
        puts
        show_strategy_single(poke)
      end

      def show_basic_info_single(poke)
        str = PADDING + "##{poke.pokedex_id}: #{poke.name}"
        if poke.forme
          str += " (#{poke.forme})"
        end
        str += "\t(#{poke.type_string})"
        puts str
      end

      def show_base_stats_single(poke)
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

      def show_strategy_single(poke)
        types = poke.types
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
