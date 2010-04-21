#!/usr/bin/env ruby
require_relative '../pokemon'
require_relative '../pokedb'
require_relative '../typechart'

module Dexter
  module UI
    class Generic
      def initialize
        @database = Dexter::PokeDB.new
        @cache = {}
      end

      def retrieve(args)
        poke = nil
        pokes = []
        if args[:id] then
          if @cache[args[:id]] then return @cache[args[:id]]
          else poke = @database.get(:id => args[:id])
          end
        elsif args[:name] then
          if @cache[args[:name]] then return @cache[args[:name]]
          else poke = @database.get(:name => args[:name])
          end

        elsif args[:types] then
          pokes = @database.get_all(:types => args[:types])
        end

        if not poke.nil? then
          poke = @database.complete(poke)
          @cache[poke.name.downcase.intern] = poke
          @cache[poke.id] = poke
          return poke
        elsif not pokes.empty? then
          pokes.each do |poke|
            poke = @database.complete(poke)
            @cache[poke.name.downcase.intern] = poke
            @cache[poke.id] = poke
          end
        end
      end
    end
  end
end
