# SPDX-License-Identifier: AGPL-3.0-only
# Copyright (C) 2026 Ahmad Ali Parr
# GNU Affero General Public License version 3 only.
#
# Stage 3. Reads target.json from the Perl stage. Bounded forward chaining.
# Fibers are not used: a shared hash mutated from several fibers is not the
# fixpoint. One sequential round loop, cap 10000 rounds and 512 facts.

require "json"

struct Term
  getter kind : Symbol
  getter name : String
  def initialize(@kind : Symbol, @name : String); end
  def self.parse(s : String) : Term
    s.starts_with?('?') ? Term.new(:var, s[1..]) : Term.new(:app, s)
  end
end

struct Atom
  getter pred : String
  getter terms : Array(Term)
  def initialize(@pred : String, @terms : Array(Term)); end
  def self.parse(s : String) : Atom
    m = s.match(/^(\w+)\((.*)\)$/) || raise "bad atom: #{s}"
    Atom.new(m[1], m[2].split(',').map { |t| Term.parse(t) })
  end
end

struct Rule
  getter head : Atom
  getter body : Array(Atom)
  def initialize(@head : Atom, @body : Array(Atom)); end
end

MAX_MODEL_SIZE = 512
MAX_ROUNDS     = 10_000

raw = Array(JSON::Any).from_json(File.read("target.json"))
rules = raw.map do |r|
  Rule.new(Atom.parse(r["head"].as_s),
           r["body"].as_a.map { |b| Atom.parse(b.as_s) })
end
preds = rules.flat_map { |r| [r.head.pred] + r.body.map(&.pred) }.uniq

facts = Hash(String, Set(String)).new { |h, k| h[k] = Set(String).new }

def subst_of(atom : Atom, key : String) : Hash(String, String)?
  m = key.match(/^(\w+)\((.*)\)$/)
  return nil unless m && m[1]? == atom.pred
  args = m[2].split(',')
  bind = Hash(String, String).new
  atom.terms.each_with_index do |t, i|
    if t.kind == :var
      return nil if bind[t.name]? && bind[t.name] != args[i]?
      bind[t.name] = args[i]
    else
      return nil unless t.name == args[i]?
    end
  end
  bind
end

def instantiate(head : Atom, bind : Hash(String, String)) : String
  "#{head.pred}(#{head.terms.map { |t| t.kind == :var ? bind[t.name] : t.name }.join(',')})"
end

iterations = 0
progress = true
while progress
  raise "fixpoint diverged" if (iterations += 1) > MAX_ROUNDS
  progress = false
  preds.each do |p|
    rules.select { |r| r.head.pred == p }.each do |r|
      derived = if r.body.empty?
        [instantiate(r.head, Hash(String, String).new)]
      else
        subs = [Hash(String, String).new]
        r.body.each do |atom|
          nxt = [] of Hash(String, String)
          subs.each do |bind|
            facts[atom.pred].each do |k|
              if (b2 = subst_of(atom, k))
                merged = bind.dup
                ok = true
                b2.each do |v, val|
                  ok = false if merged[v]? && merged[v] != val
                  merged[v] = val
                end
                nxt << merged if ok
              end
            end
          end
          subs = nxt
        end
        subs.map { |b| instantiate(r.head, b) }
      end
      derived.each do |k|
        next if facts[p].includes?(k)
        raise "model exceeds #{MAX_MODEL_SIZE} facts" if facts.values.sum(&.size) >= MAX_MODEL_SIZE
        facts[p] << k
        progress = true
      end
    end
  end
end

puts "Crystal AOT synthesis complete. Derived facts:"
facts.keys.sort.each do |p|
  facts[p].to_a.sort.each { |k| puts " #{k}" }
end
