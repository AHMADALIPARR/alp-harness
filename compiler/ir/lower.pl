#!/usr/bin/perl
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright (C) 2026 Ahmad Ali Parr
# GNU Affero General Public License version 3 only.
#
# Stage 2. Read RULE lines on STDIN. Bottom-up fixpoint, cap 10000 rounds
# and 512 facts. Writes target.json for the Crystal stage.
use strict;
use warnings;

my @rules;

sub parse_term {
    my $t = shift;
    return (substr($t, 0, 1) eq '?') ? { var => substr($t, 1) } : { app => $t };
}
sub parse_atom {
    my $a = shift;
    my ($name, $args) = $a =~ /^(\w+)\((.*)\)$/;
    return unless $name;
    return [ $name, [ map { parse_term($_) } split /,/, $args ] ];
}

while (my $line = <STDIN>) {
    chomp $line;
    next unless $line =~ /^RULE \d+ HEAD (\w+\([^()]*\)) BODY \[(.*)\]$/;
    my ($h, $b) = ($1, $2);
    my $bh = parse_atom($h) or die "IR: bad head '$h'";
    my @body;
    while ($b =~ /(\w+\([^()]*\))/g) {
        my $ba = parse_atom($1) or die "IR: bad body atom '$1'";
        push @body, $ba;
    }
    push @rules, { head => $bh, body => \@body };
}
die "IR: no rules lowered\n" unless @rules;

my %facts;
sub find_matches {
    my $r = shift;
    my @subs = ( {} );
    for my $atom (@{ $r->{body} }) {
        my $pname = $atom->[0];
        my @next;
        for my $sub (@subs) {
            FACT: for my $k (sort keys %{ $facts{$pname} || {} }) {
                $k =~ /^\Q$pname\E\((.*)\)$/ or next FACT;
                my @args = split /,/, $1, -1;
                my %s2 = %$sub;
                for my $i (0 .. $#{ $atom->[1] }) {
                    my $t = $atom->[1][$i];
                    if ($t->{var}) {
                        if (exists $s2{ $t->{var} }) {
                            next FACT unless $s2{ $t->{var} } eq $args[$i];
                        } else {
                            $s2{ $t->{var} } = $args[$i];
                        }
                    } else {
                        next FACT unless $args[$i] eq $t->{app};
                    }
                }
                push @next, \%s2;
            }
        }
        @subs = @next;
    }
    my @out;
    for my $sub (@subs) {
        my @ht;
        for my $t (@{ $r->{head}[1] }) {
            if ($t->{var}) {
                die "unbound head var" unless exists $sub->{ $t->{var} };
                push @ht, $sub->{ $t->{var} };
            } else {
                push @ht, $t->{app};
            }
        }
        push @out, $r->{head}[0] . "(" . join(",", @ht) . ")";
    }
    return \@out;
}

my $changed = 1;
my $iterations = 0;
while ($changed) {
    die "IR: fixpoint diverged\n" if ++$iterations > 10_000;
    $changed = 0;
    for my $r (@rules) {
        my $derived = @{ $r->{body} } == 0
            ? [ $r->{head}[0] . "("
                . join(",", map { $_->{app} } @{ $r->{head}[1] }) . ")" ]
            : find_matches($r);
        for my $k (@$derived) {
            my ($p) = $k =~ /^(\w+)\(/;
            next if $facts{$p}{$k};
            die "IR: BoundedList violation (model > 512 facts)\n"
                if (scalar(map { keys %{ $facts{$_} } } keys %facts) >= 512);
            $facts{$p}{$k} = 1;
            $changed = 1;
        }
    }
}

print "IR facts:\n";
print " $_\n" for sort map { keys %{ $facts{$_} } } sort keys %facts;

sub term_str { my $t = shift; $t->{var} ? "?" . $t->{var} : $t->{app} }
sub atom_str { my $a = shift; $a->[0] . "(" . join(",", map { term_str($_) } @{ $a->[1] }) . ")" }
open my $fh, '>', 'target.json' or die $!;
print $fh "[\n";
my @rs;
for my $r (@rules) {
    my @bs = map { '"' . atom_str($_) . '"' } @{ $r->{body} };
    push @rs, ' {"head": "' . atom_str($r->{head})
            . '", "body": [' . join(",", @bs) . ']}';
}
print $fh join(",\n", @rs), "\n]\n";
close $fh;
print "IR lowered to target.json for AOT synthesis\n";
