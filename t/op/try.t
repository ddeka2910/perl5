#!./perl

BEGIN {
    chdir 't' if -d 't';
    require './test.pl';
    set_up_inc('../lib');
    require Config;
}

use strict;
use warnings;
use feature 'try';
no warnings 'experimental::try';

{
    my $x;
    try {
        $x .= "try";
    }
    catch ($e) {
        $x .= "catch";
    }
    is($x, "try", 'successful try/catch runs try but not catch');
}

{
    my $x;
    my $caught;
    try {
        $x .= "try";
        die "Oopsie\n";
    }
    catch ($e) {
        $x .= "catch";
        $caught = $e;
    }
    is($x, "trycatch", 'die in try runs catch block');
    is($caught, "Oopsie\n", 'catch block saw exception value');
}

# Loop controls inside try {} do not emit warnings
{
   my $warnings = "";
   local $SIG{__WARN__} = sub { $warnings .= $_[0] };

   {
      try {
         last;
      }
      catch ($e) { }
   }

   {
      try {
         next;
      }
      catch ($e) { }
   }

   my $count = 0;
   {
      try {
         $count++;
         redo if $count < 2;
      }
      catch ($e) { }
   }

   is($warnings, "", 'No warnings emitted by next/last/redo inside try');

   $warnings = "";

   LOOP_L: {
      try {
         last LOOP_L;
      }
      catch ($e) { }
   }

   LOOP_N: {
      try {
         next LOOP_N;
      }
      catch ($e) { }
   }

   $count = 0;
   LOOP_R: {
      try {
         $count++;
         redo LOOP_R if $count < 2;
      }
      catch ($e) { }
   }

   is($warnings, "", 'No warnings emitted by next/last/redo LABEL inside try');
}

# try/catch should localise $@
{
    eval { die "Value before\n"; };

    try { die "Localized value\n" } catch ($e) {}

    is($@, "Value before\n", 'try/catch localized $@');
}

done_testing;
