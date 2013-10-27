#!/usr/bin/env ruby

require 'pg'
require_relative 'pokemon'

module Dexter
  class PokeDB
    def initialize(host="localhost", port=5432, dbname="pokedex", user="dexter", *args)
      @connection = PGconn.new(:host => host, :port => port, :dbname => dbname, :user => user)
    end

    def add_pokemon(poke)
      insert_base_stats(poke)
      insert_pokemon(poke)
    end

    def create
      create_pokemon_table
      create_base_stats_table
    end

    def drop
      drop_pokemon_table
      drop_base_stats_table
    end

    def get_all(args)
      sql, params = nil

      if args[:id] then
        sql = "SELECT * FROM pokemon WHERE pokedex_id=$1::int;"
        params = [args[:id].to_i]

      elsif args[:name] then
        sql = "SELECT * FROM pokemon WHERE name ILIKE $1::text;"
        params = [args[:name]]

      elsif args[:types].length == 2 then
        sql=<<-'EOS'
          (SELECT * FROM pokemon
           WHERE type1=$1::text AND type2=$2::text)
          UNION
          (SELECT * FROM pokemon
           WHERE type1=$2::text AND type2=$1::text);
          EOS
        params = args[:types].map(&:to_s)

      elsif args[:types] then
        sql=<<-'EOS'
          SELECT * FROM pokemon
          WHERE type1=$1 OR type2=$1;
          EOS
        params = args[:types].map(&:to_s)
      end

      results = @connection.exec(sql, params)
      pokes = []
      results.each {|row| pokes << Dexter::Pokemon.new(row) }
      return pokes
    end

    def complete(poke)
      sql = "SELECT * FROM base_stats WHERE id=$1::text"
      params = [poke.id]

      row = @connection.exec(sql, params)[0]
      row.delete("id")
      poke.merge! "base_stats" => row

      return poke
    end

    def create_pokemon_table
      sql=<<'EOS'
CREATE TABLE pokemon (
  id text primary key,
  pokedex_id integer not null,
  name text not null,
  forme text,
  type1 text not null,
  type2 text
);
EOS
      @connection.exec(sql)
    end
    private :create_pokemon_table

    def create_base_stats_table
      sql=<<'EOS'
CREATE TABLE base_stats (
  id text primary key,
  hp integer not null,
  attack integer not null,
  defense integer not null,
  sp_attack integer not null,
  sp_defense integer not null,
  speed integer not null
);
EOS
      @connection.exec(sql)
    end
    private :create_base_stats_table

    def drop_pokemon_table
      @connection.exec("DROP TABLE pokemon;")
    end
    private :drop_pokemon_table

    def drop_base_stats_table
      @connection.exec("DROP TABLE base_stats;")
    end
    private :drop_base_stats_table

    def insert_pokemon(poke)
      sql=<<'EOS'
INSERT INTO pokemon (id, pokedex_id, name, forme, type1, type2)
VALUES ($1::text, $2::int, $3::text, $4::text, $5::text, $6::text);
EOS
      @connection.exec(sql, [poke.id, poke.pokedex_id, poke.name, poke.forme, poke.type1, poke.type2])
    end
    private :insert_pokemon

    def insert_base_stats(poke)
      sql=<<'EOS'
INSERT INTO base_stats (id, hp, attack, defense, sp_attack, sp_defense, speed)
VALUES ($1::text, $2::int, $3::int, $4::int, $5::int, $6::int, $7::int);
EOS
      @connection.exec(sql, [
                             poke.id,
                             poke.hp,
                             poke.attack,
                             poke.defense,
                             poke.special_attack,
                             poke.special_defense,
                             poke.speed,
                            ])
    end
    private :insert_base_stats

  end
end
