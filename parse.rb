#!/usr/bin/env ruby

require 'hpricot'
require 'trollop'
require './pokemon'

opts = Trollop::options do
  opt :type_of, "Get the type of a pokemon", :type => :string
end

data = open("basic_listing.html") {|f| Hpricot(f) }

pokedex = data.at("#pokedex")

stats = [:hp, :attack, :defense, :special_attack, :special_defense, :speed]
all_pokemon = []
pokedex.at("tbody").search("tr").each do |row|
  data = row.search("td")
  id = data[0].inner_text.to_i
  name = data[1].inner_text

  pokemon = Pokemon::new(id, name)
  data[2].search("a").each do |stat|
    pokemon.has_type(stat.inner_text)
  end

  stats.each_index do |i|
    pokemon.has_base_stat(stats[i], data[i+3].inner_text.to_i)
  end

  all_pokemon << pokemon
end

#all_pokemon.each {|poke| puts poke }

if opts[:type_of_given] then
  wanted = all_pokemon.detect {|poke| poke.name.upcase == opts[:type_of].upcase }
  out = "No.#{wanted.id}, #{wanted.name}, is "
  out += wanted.types[0] + (wanted.types[1] ? "/#{wanted.types[1]}" : "") + "."
  puts out
end
