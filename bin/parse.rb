#!/usr/bin/env ruby

require 'hpricot'
require 'trollop'
require_relative '../lib/dexter/pokemon'
require_relative '../lib/dexter/pokedb'

opts = Trollop::options do
  opt :create, "Create the tables in the database"
  opt :drop, "Drop an existing table"
  opt :dry_run, "Just parse the file and dump data", :short => "p"
end

Trollop::die("no HTML file specified") if ARGV.empty?

data = open(ARGV[0]) {|f| Hpricot(f) }

pokedex = data.at("#pokedex")

stats = [:hp, :attack, :defense, :sp_attack, :sp_defense, :speed]
all_pokemon = []
pokedex.at("tbody").search("tr").each do |row|
  data = row.search("td")
  id = data[0].inner_text.to_i
  name = data[1].inner_text

  next if [386, 413, 479, 487, 492, 555, 648].include? id

  pokemon = Dexter::Pokemon::new({"id" => id, "name" => name})
  data[2].search("a").each do |stat|
    pokemon.has_type(stat.inner_text.downcase)
  end

  stats.each_index do |i|
    pokemon.has_stat(stats[i], data[i+3].inner_text.to_i)
  end

  all_pokemon << pokemon
end

db = Dexter::PokeDB.new

if opts[:drop] then
  db.drop
end

if opts[:create] then
  db.create
end

if opts[:dry_run] then
  all_pokemon.each {|poke| puts poke }
else
  all_pokemon.each {|poke| db.add_pokemon(poke) }
end
