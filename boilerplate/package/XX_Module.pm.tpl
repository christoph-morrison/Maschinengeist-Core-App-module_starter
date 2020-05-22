=for JFTR

It's absolute nonsense to use Perl::Critic for legacy modules
if you are really interested in such messages, use --force for perlcritic

=cut
package [% package.full_name %];
[% IF license %]
=for LICENSE

    SPDX-License-Identifier: [% license.id %]

    [% license.name %]
    <[% license.uri %]>

    [% license.text %]

=cut
[% END %]
# $Id$

################################################## pragmas
use strict;
use warnings FATAL => 'all';
use 5.010;

################################################## core modules
use List::Util;

################################################## non-core modules
use Readonly;

################################################## default settings
Readonly our $VERSION => q{0.0.1};

################################################## handle attributes
Readonly our %ATTRIBUTE_HANDLER => (
    q{disable}  => {
        q{set} => sub {
            my $parameters = shift;

            if ($parameters->{attribute_value} == 1) {
                return;
            }

            if ($parameters->{attribute_value} == 0) {
                return;
            }
        },
        q{del} => sub {
            my $parameters = shift;
            return;
        },
    },
);

################################################## FHEM API
sub initialize {
    my $device_definition = shift;

    $device_definition->{DefFn}         = \&handle_define;
    $device_definition->{UndefFn}       = \&handle_undefine;
    $device_definition->{SetFn}         = \&handle_set;
    $device_definition->{GetFn}         = \&handle_get;
    $device_definition->{AttrFn}        = \&handle_attributes;
    $device_definition->{AttrList}      = join(
        q{ },
        (
            q{disable:0,1},
        )
    ) . qq[ $::readingFnAttributes ];

    return FHEM::Meta::InitMod( __FILE__, $device_definition );
}

sub handle_define {
    my $global_definition   = shift;
    my $define              = shift;

    if ( !FHEM::Meta::SetInternals($global_definition) ) {
        return $EVAL_ERROR;
    }

    Readonly my $ARG_INDEX_MIN_LENGTH   => 2;
    Readonly my $ARG_INDEX_NAME         => 0;

    my @define_arguments = split m{ \s+ }xms, $define;
    my $device_name      = $define_arguments[$ARG_INDEX_NAME];

    if (scalar @define_arguments < $ARG_INDEX_MIN_LENGTH) {
        return q{Syntax: define <name> Serienjunkies};
    }

    $global_definition->{NAME} = $device_name;
    $global_definition->{VERSION} = $VERSION;

    return;
}

sub handle_undefine {
    return;
}

sub handle_attributes {
    my $verb                = shift;
    my $device_name         = shift;
    my $attribute_name      = shift;
    my $attribute_value     = shift;
    my $global_definition    = get_global_definition($device_name);

    whisper(Dumper({
        q{device_name}      =>  $device_name,
        q{verb}             =>  $verb,
        q{attribute_name}   =>  $attribute_name,
        q{attribute_value}  =>  $attribute_value,
    }));

    if (!List::Util::any { $verb eq $ARG } qw{ set del }) {
        return qq{[$device_name] Action '$verb' is neither set nor del.};
    }

    if (defined $ATTRIBUTE_HANDLER{$attribute_name}) {
        return &{$ATTRIBUTE_HANDLER{$attribute_name}{$verb}}(
            {
                q{device_name}      =>  $device_name,
                q{verb}             =>  $verb,
                q{attribute_name}   =>  $attribute_name,
                q{attribute_value}  =>  $attribute_value,
            }
        );
    }
}

sub handle_get {
    return;
}

sub handle_set {
    return;
}

sub set_fhemweb_detail {
    return;
}

################################################## helper

## no critic (ProhibitPackageVars)
sub get_global_definition {
    my $device_name = shift;
    return $::defs{$device_name};
}
## use critic

1;
__END__

=for Autogenerated

    This module was autogenerated by FHEM::Template (https://github.com/fhem/mod-Template)
        (c) Christoph 'knurd' Morrison

=cut

=pod

=item summary
=item summary_DE
=begin html

<a name="[% name %]"></a>
<h3>[% name %]</h3>


=end html

=begin html_DE

<a name="[% name %]"></a>
<h3>[% name %]</h3>

=end

=cut