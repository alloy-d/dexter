This is a pretty incomplete project. Which is okay, 'cause it's also a
pretty goofy project. It's exactly what the description says: a
Pokémon database with a command-line interface.

It takes its data from [pokemondb.net][] (because they make their data
available in a beautifully clean format), and unless you're nerdy
enough to actually *want* the ridiculous thing that is Dexter, you
should really just go there. The only value Dexter adds is slightly
more convenient type matchups.

## Gem Dependencies

 * `pg` for the database (yeah, really)
 * `trollop` for argument parsing
 * `hpricot` for parsing data from [pokemondb.net][]
 * `term-ansicolor` for pretty colors (and yes, this is really non-optional)

## Setup

In what is totally overkill, Dexter requires a postgres table. It
expects a default postgres setup (port 5432 on the local machine,
although you can change this) and a `pokedex` table owned by `dexter`
(with no password).

It populates its database by shamelessly stealing info from
[pokemondb.net][]'s [complete pokedex][]. Download a copy (to, say,
`pokedex.html`), then run

    dexter/bin/parse.rb pokedex.html --create

Then, assuming everything goes well, you can run

    dexter/bin/query.rb info pikachu
    
for basic info about Pikachu;

    dexter/bin/query.rb stats pikachu

for Pikachu's base stats;

    dexter/bin/query.rb type pikachu

for Pikachu's weaknesses and resistences; and

    dexter/bin/query.rb all pikachu

for all of that in one command.

Me, I have an alias to dexter in my shell init file. (You, you should
probably still use [pokemondb.net][].)

## Bugs

 * Pokémon with multiple forms (Deoxys, Wormadam, etc.) are completely
   ignored because they don't fit nicely in the database.
 * Command-line interface sucks.
 * Help for figuring out the command-line interface also sucks.
 * The `type` command doesn't *actually* display the pokémon's
   type. (Largely because it used to be called `strat`, so that made
   sense.)
 * Color is non-optional. Even if you use the option to turn it off.
 * It doesn't install in any useful way.
 * It exists, period.


[pokemondb.net]: http://pokemondb.net/
[complete pokedex]: http://pokemondb.net/pokedex/all
