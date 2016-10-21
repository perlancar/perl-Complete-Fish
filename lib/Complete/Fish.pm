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

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Completion module for fish shell',
};

$SPEC{format_completion} = {
    v => 1.1,
    summary => 'Format completion for output (for shell)',
    description => <<'_',

fish accepts completion reply in the form of one entry per line to STDOUT.
Description can be added to each entry, prefixed by tab character.

_
    args_as => 'array',
    args => {
        completion => {
            summary => 'Completion answer structure',
            description => <<'_',

Either an array or hash, as described in `Complete`.

_
            schema=>['any*' => of => ['hash*', 'array*']],
            req=>1,
            pos=>0,
        },
    },
    result => {
        summary => 'Formatted string (or array, if `as` key is set to `array`)',
        schema => ['any*' => of => ['str*', 'array*']],
    },
    result_naked => 1,
};
sub format_completion {
    my $comp = shift;

    my $as;
    my $entries;

    # we currently use Complete::Bash's rule because i haven't done a read up on
    # how exactly fish escaping rules are.
    if (ref($comp) eq 'HASH') {
        $as = $comp->{as} // 'string';
        $entries = Complete::Bash::format_completion({%$comp, as=>'array'});
    } else {
        $as = 'string';
        $entries = Complete::Bash::format_completion({
            words=>$comp, as=>'array',
        });
    }

    # insert description
    {
        my $compary = ref($comp) eq 'HASH' ? $comp->{words} : $comp;
        for (my $i=0; $i<@$compary; $i++) {

            my $desc = (ref($compary->[$i]) eq 'HASH' ?
                            $compary->[$i]{description} : '' ) // '';
            $desc =~ s/\R/ /g;
            $entries->[$i] .= "\t$desc";
        }
    }

    # turn back to string if that's what the user wants
    if ($as eq 'string') {
        $entries = join("", map{"$_\n"} @$entries);
    }
    $entries;
}

1;
#ABSTRACT:

=head1 DESCRIPTION

fish allows completion of option arguments to come from an external command,
e.g.:

 % complete -c deluser -l user -d Username -a "(cat /etc/passwd|cut -d : -f 1)"

The command is supposed to return completion entries one in a separate line.
Description for each entry can be added, prefixed with a tab character. The
provided function C<format_completion()> accept a completion answer structure
and format it for fish. Example:

 format_completion(["a", "b", {word=>"c", description=>"Another letter"}])

will result in:

 a
 b
 c       Another letter


=head1 SEE ALSO

L<Complete>

L<Complete::Bash>

Fish manual.

=cut
