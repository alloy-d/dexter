#!/usr/bin/env ruby
require_relative '../lib/dexter/ui/cli'

OPERATIONS = {
  "all" => :show_all,
  "base-stats" => :show_base_stats,
  "info" => :show_basic_info,
  "find" => :show_find_results,
  "type" => :show_strategy,
}

opts = Trollop::options do
  opt :color, "Use pretty colors", :default => true
  opt :id, "Query by pokemon id instead of name", :type => :int
end

op, poke = ARGV.shift, ARGV.shift
unless not op.nil? and (not poke.nil? or opts[:id_given]) then
  Trollop::die("I need an operation and a pokemon to look up")
end

ui = Dexter::UI::CLI.new
if poke then ui.send(OPERATIONS[op], :name => poke)
else ui.send(OPERATIONS[op], :id => opts[:id])
end
