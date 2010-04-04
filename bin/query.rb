#!/usr/bin/env ruby

require 'trollop'
require_relative '../lib/pokemon'
require_relative '../lib/pokedb'

opts = Trollop::options do
  opt :id, "Query by id number", :type => :int
  opt :type_of, "Get the type of a pokemon"
  opt :number_of, "Get the id number of a pokemon"
  opt :name_of, "Get the name of a pokemon"
end

if ARGV.empty? and not opts[:id_given] then
  Trollop::die("I need a pokemon to look up")
end

wanted = nil
if opts[:id_given] then
  wanted = PokeDB.get(:id => opts[:id])
else
  wanted = PokeDB.get(:name => ARGV.first)
end

if opts[:type_of_given] then
  out = "No.#{wanted.id}, #{wanted.name}, is "
  out += wanted.types[0] + ("/#{wanted.types[1]}" if wanted.types[1]) + "."
  puts out
end

if opts[:number_of_given] then
  out = "#{wanted.name} has number #{wanted.id}."
  puts out
end

if opts[:name_of_given] then
  out = "No.#{wanted.id} is #{wanted.name}."
  puts out
end
