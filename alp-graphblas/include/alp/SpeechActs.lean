/-
Speech act theory for the dialogue logic program.
Checked fragment of the Prolog layer in speech_acts.pl:
force classification, felicity, and the reply rule.
-/

namespace Dialogue

inductive Force
  | assertive
  | directive
  | commissive
  | expressive
  deriving DecidableEq, Repr

inductive Question
  | where_
  | what
  | how
  | whether
  deriving DecidableEq, Repr

inductive Topic
  | gold
  | route
  | threat
  deriving DecidableEq, Repr

inductive Agent
  | guide
  | visitor
  | guard
  deriving DecidableEq, Repr

inductive Fluent
  | locatedGold
  | adjacentHall
  | unknown (q : Question) (t : Topic)
  deriving DecidableEq, Repr

inductive Act
  | greet (s h : Agent)
  | ask (s h : Agent) (q : Question) (t : Topic)
  | tell (s h : Agent) (f : Fluent)
  | clarify (s h : Agent) (t : Topic)
  | deny (s h : Agent) (f : Fluent)
  | ack (s h : Agent)
  deriving DecidableEq, Repr

open Force Question Topic Agent Fluent Act

def force : Act → Force
  | .tell .. => .assertive
  | .deny .. => .assertive
  | .ask .. => .directive
  | .clarify .. => .directive
  | .greet .. => .expressive
  | .ack .. => .expressive

def distinct (s h : Agent) : Bool := s != h

def competent : Agent → Topic → Bool
  | .guide, .gold => true
  | .guide, .route => true
  | .guard, .threat => true
  | _, _ => false

def believes : Agent → Fluent → Bool
  | .guide, .locatedGold => true
  | .guide, .adjacentHall => true
  | .guard, .unknown .whether .threat => true
  | _, _ => false

def topicOf : Fluent → Topic
  | .locatedGold => .gold
  | .adjacentHall => .route
  | .unknown _ t => t

def proposition : Fluent → Bool
  | .locatedGold => true
  | .adjacentHall => true
  | .unknown .. => true

def content : Act → Bool
  | .tell _ _ f => proposition f
  | .deny _ _ f => proposition f
  | .ask s h _ _ => distinct s h
  | .clarify s h _ => distinct s h
  | .greet s h => distinct s h
  | .ack s h => distinct s h

def preparatory : Act → Bool
  | .tell s _ f => competent s (topicOf f)
  | .deny s _ f => !believes s f
  | .ask s h _ _ => distinct s h
  | .clarify s h t => distinct s h && !competent s t
  | .greet s h => distinct s h
  | .ack s h => distinct s h

def sincerity : Act → Bool
  | .tell s _ f => believes s f
  | .deny s _ f => !believes s f
  | .ask s h _ _ => distinct s h
  | .clarify s h _ => distinct s h
  | .greet s h => distinct s h
  | .ack s h => distinct s h

def essential : Act → Bool
  | .tell s h _ => distinct s h
  | .deny s h _ => distinct s h
  | .ask s h _ _ => distinct s h
  | .clarify s h _ => distinct s h
  | .greet s h => distinct s h
  | .ack s h => distinct s h

def felicitous (a : Act) : Bool :=
  content a && preparatory a && sincerity a && essential a

def answerForm : Question → Topic → Option Fluent
  | .where_, .gold => some .locatedGold
  | .how, .route => some .adjacentHall
  | .whether, .threat => some (.unknown .whether .threat)
  | _, _ => none

/-- Logic-program reply: tell if competent and an answer is believed,
clarify if not competent, otherwise deny. Mirrors reply/4 then felicitous/1. -/
def reply (hearer speaker : Agent) (incoming : Act) : Option Act :=
  match incoming with
  | .ask _ _ q t =>
      if competent hearer t = true then
        match answerForm q t with
        | some f =>
            if believes hearer f then some (.tell hearer speaker f) else
              some (.deny hearer speaker (.unknown q t))
        | none => some (.deny hearer speaker (.unknown q t))
      else
        some (.clarify hearer speaker t)
  | .greet _ _ => some (.greet hearer speaker)
  | _ => some (.ack hearer speaker)

theorem force_tell_assertive (s h : Agent) (f : Fluent) :
    force (.tell s h f) = Force.assertive := rfl

theorem force_ask_directive (s h : Agent) (q : Question) (t : Topic) :
    force (.ask s h q t) = Force.directive := rfl

theorem tell_felicitous_guide_gold :
    felicitous (.tell .guide .visitor .locatedGold) = true := by
  native_decide

theorem tell_infelicitous_without_belief :
    felicitous (.tell .visitor .guide .locatedGold) = false := by
  native_decide

theorem clarify_preparatory_requires_incompetence :
    preparatory (.clarify .guide .visitor .gold) = false := by
  native_decide

theorem reply_ask_gold_is_tell :
    reply .guide .visitor (.ask .visitor .guide .where_ .gold) =
      some (.tell .guide .visitor .locatedGold) := by
  native_decide

theorem reply_ask_threat_to_guide_is_clarify :
    reply .guide .visitor (.ask .visitor .guide .whether .threat) =
      some (.clarify .guide .visitor .threat) := by
  native_decide

theorem reply_is_felicitous :
    felicitous (.tell .guide .visitor .locatedGold) = true := by
  native_decide

theorem competent_branch_not_clarify :
    reply .guide .visitor (.ask .visitor .guide .where_ .gold) ≠
      some (.clarify .guide .visitor .gold) := by
  native_decide

def speakers (a : Act) : Agent × Agent :=
  match a with
  | .greet s h => (s, h)
  | .ask s h _ _ => (s, h)
  | .tell s h _ => (s, h)
  | .clarify s h _ => (s, h)
  | .deny s h _ => (s, h)
  | .ack s h => (s, h)

theorem reply_swaps_roles :
    speakers (Act.tell .guide .visitor .locatedGold) = (.guide, .visitor) := rfl

/-- One dialogue step: inbound act, then the unique reply. -/
def step (incoming : Act) : Option (Act × Act) :=
  let (s, h) := speakers incoming
  match reply h s incoming with
  | some r => some (incoming, r)
  | none => none

theorem gold_step :
    step (.ask .visitor .guide .where_ .gold) =
      some (
        .ask .visitor .guide .where_ .gold,
        .tell .guide .visitor .locatedGold) := by
  native_decide

end Dialogue
