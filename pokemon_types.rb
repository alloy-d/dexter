#!/usr/bin/env ruby

TYPES = [
         :normal,
         :fire,
         :water,
         :electric,
         :grass,
         :ice,
         :fighting,
         :poison,
         :ground,
         :flying,
         :psychic,
         :bug,
         :rock,
         :ghost,
         :dragon,
         :dark,
         :steel,
        ]

MULTIPLIERS = {}
TYPES.each do |attacker|
  TYPES.each do |defender|
    MULTIPLIERS[attacker][defender] = 1
  end
end

def resists(defender, attacker)
  MULTIPLIERS[attacker][defender] *= 0.5
end

def immunes(defender, attacker)
  MULTIPLIERS[attacker][defender] *= 0
end

def fears(defender, attacker)
  MULTIPLIERS[attacker][defender] *= 2
end

fears :normal, :fighting
immunes :normal, :ghost

resists :fire, :fire
fears :fire, :water
resists :fire, :grass
resists :fire, :ice
fears :fire, :ground
resists :fire, :bug
fears :fire, :rock
resists :fire, :steel

resists :water, :fire
resists :water, :water
fears :water, :electric
fears :water, :grass
resists :water, :ice
resists :water, :steel

resists :electric, :electric
# THIS SUCKS
