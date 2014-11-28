package Complete::Fish;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       format_completion
               );

require Complete::Bash;

our %SPEC;

# parse_cmdline

$SPEC{format_completion} = {
    v => 1.1,
    summary => 'Format completion for output (for shell)',
    description => <<'_',

fish accepts completion reply in the form of one entry per line to STDOUT.
Description can be added to each entry, prefixed by tab character.

_
    args_as => 'array',
    args => {
        shell_completion => {
            summary => 'Result of shell completion',
            description => <<'_',

Either an array or hash.

_
            schema=>['any*' => of => ['hash*', 'array*']],
            req=>1,
            pos=>0,
        },
        as => {
            schema => ['str*', in=>['string', 'array']],
            default => 'string',
        },
    },
    result => {
        summary => 'Formatted string (or array, if `as` is set to `array`)',
        schema => ['any*' => of => ['str*', 'array*']],
    },
    result_naked => 1,
};
sub format_completion {
    my $comp = shift;

    my $as;
    my $entries;
    # i currently use Complete::Bash's rule because i haven't done a read up on
    # how exactly fish escaping rules are.
    if (ref($comp) eq 'HASH') {
        $as = $comp->{as} // 'string';
        $entries = Complete::Bash::format_completion({%$comp, as=>'array'});
    } else {
        $as = 'string';
        $entries = Complete::Bash::format_completion({
            completion=>$comp, as=>'array',
        });
    }

    # insert description
    {
        my $compary = ref($comp) eq 'HASH' ? $comp->{completion} : $comp;
        for (my $i=0; $i<@$compary; $i++) {
            if (defined $compary->{description}) {

        }
    }

    # turn back to string if that's what the user wants
    if ($as eq 'string') {
        $entries = join("", map{"$_\n"} @$entries);
    }
    $entries;
}

1;
#ABSTRACT: Completion module for tcsh shell

=head1 DESCRIPTION

tcsh allows completion to come from various sources. One of the simplest is from
a list of words:

 % complete CMDNAME 'p/*/(one two three)/'

Another source is from an external command:

 % complete CMDNAME 'p/*/`mycompleter --somearg`/'

The command receives one environment variables C<COMMAND_LINE> (string, raw
command-line). Unlike bash, tcsh does not (yet) provide something akin to
C<COMP_POINT> in bash. Command is expected to print completion entries, one line
at a time.

 % cat mycompleter
 #!/usr/bin/perl
 use Complete::Tcsh qw(parse_cmdline format_completion);
 use Complete::Util qw(complete_array_elem);
 my ($words, $cword) = parse_cmdline();
 my $res = complete_array_elem(array=>[qw/--help --verbose --version/], word=>$words->[$cword]);
 print format_completion($res);

 % complete -C foo-complete foo
 % foo --v<Tab>
 --verbose --version

This module provides routines for you to be doing the above.

Also, unlike bash, currently tcsh does not allow delegating completion to a
shell function.


=head1 TODOS


=head1 SEE ALSO

L<Complete>

L<Complete::Bash>

tcsh manual.

=cut
