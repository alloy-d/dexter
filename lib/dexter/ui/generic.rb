#!/usr/bin/env ruby
require_relative '../pokemon'
require_relative '../pokedb'
require_relative '../typechart'

module Dexter
  module UI
    class Generic
      def initialize
        @database = Dexter::PokeDB.new
      end

      def retrieve(args)
        @database.get_all(args).map{|poke| @database.complete(poke) }
      end
    end
  end
end
