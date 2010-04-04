#!/usr/bin/env ruby
require 'trollop'
require_relative '../lib/dexter/pokemon'
require_relative '../lib/dexter/pokedb'

SUB_COMMANDS = %w(find)

opts = Trollop::options do
  opt :id, "Query by id number", :type => :int
  opt :type_of, "Get the type of a pokemon"
  opt :number_of, "Get the id number of a pokemon"
  opt :name_of, "Get the name of a pokemon"
  stop_on SUB_COMMANDS
end

first = ARGV.shift
if first.nil? and not opts[:id_given] then
  Trollop::die("I need a pokemon to look up or an operation")
end

db = Dexter::PokeDB.new

case first
when "find"
  cmd_opts = Trollop::options do
    opt :complete, "Show all information"
    opt :type, "Search by type; specify dual-type as type1/type2", :type=> :string
  end

  pokes = []
  if cmd_opts[:type_given] then
    types = cmd_opts[:type].split('/')
    pokes += db.get_all(:types => types)
  end

  pokes.map! {|poke| db.complete(poke) } if cmd_opts[:complete]
  pokes.each {|poke| puts poke }

else
  pokemon_name = first
  wanted = nil

  if opts[:id_given] then
    wanted = db.get(:id => opts[:id])
  else
    wanted = db.get(:name => pokemon_name)
  end

  if opts[:type_of_given] then
    out = "No.#{wanted.id}, #{wanted.name}, is "
    out += wanted.types[0].to_s
    out += "/#{wanted.types[1]}" if wanted.types[1]
    out += "."
    puts out
    exit 0
  end

  if opts[:number_of_given] then
    out = "#{wanted.name} has number #{wanted.id}."
    puts out
    exit 0
  end

  if opts[:name_of_given] then
    out = "No.#{wanted.id} is #{wanted.name}."
    puts out
    exit 0
  end

  puts db.complete wanted
end



