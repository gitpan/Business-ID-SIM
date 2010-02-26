#!perl -T

use strict;
use warnings;
use Test::More tests => 15;

use Business::ID::SIM;

ok(!(validate_sim("") ? 1:0), "procedural style (1)");
ok((validate_sim("0101 06 00 0001") ? 1:0), "procedural style (2)");

isa_ok(Business::ID::SIM->new(""), "Business::ID::SIM", "new() works on invalid SIM");

ok(Business::ID::SIM->new("0101 06 00 0001")->validate, "valid SIM (1)");

ok(!Business::ID::SIM->new("0101 01 00 0001")->validate, "invalid SIM: unknown area (1)");
ok(!Business::ID::SIM->new("0101 40 00 0001")->validate, "invalid SIM: unknown area (2)");

ok(!Business::ID::SIM->new("0113 40 00 0001")->validate, "invalid SIM: invalid month");

ok(!Business::ID::SIM->new("0101 06 00 0000")->validate, "invalid SIM: zero serial");

is(Business::ID::SIM->new("0101 06 00 0001")->area_code, "0600", "area_code");

is(Business::ID::SIM->new("0201 06 00 0001")->year_of_birth % 100, 2, "year_of_birth");
is(Business::ID::SIM->new("0201 06 00 0001")->yob % 100, 2, "year_of_birth (alias, yob)");
is(Business::ID::SIM->new("0203 06 00 0001")->month_of_birth, 3, "month_of_birth");
is(Business::ID::SIM->new("0203 06 00 0001")->mob, 3, "month_of_birth (alias, mob)");

is(Business::ID::SIM->new("0101 06 00 0001")->serial, "0001", "serial");

is(Business::ID::SIM->new("0101 06 00 0001")->normalize, "010106000001", "normalize");
