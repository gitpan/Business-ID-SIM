package Business::ID::SIM;
our $VERSION = '0.02';
# ABSTRACT: Validate Indonesian driving license number (nomor SIM)


use warnings;
use strict;
use DateTime;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(validate_sim);

# legend: S = lack of samples

# less organized than the convoluted code in NIK

my %provinces = (
    '06' => "Nanggroe Aceh Darussalam",
    '07' => "Sumatera Utara",
    '08' => "Sumatera Barat",
    '09' => "Riau, Kepulauan Riau",
    '10' => undef, # S
    '11' => "Sumatera Selatan",
    '12' => "DKI Jakarta", # most frequently encountered
    '13' => "Jawa Barat",
    '14' => "Jawa Tengah, DI Yogyakarta",
    '15' => "Jawa Timur",
    '16' => "Bali",
    '17' => "Kalimantan Timur",
    '18' => "Kalimantan Selatan",
    '19' => "Sulawesi Selatan",
    '20' => "Sulawesi Utara, Gorontalo",
    '21' => undef, # S
    '22' => 'Papua',
    '23' => 'Kalimantan Tengah',
    '24' => 'Sulawesi Tengah',
    '25' => 'Lampung',
    #'30' => "Banten", # ?, SS

    );


sub new {
    my ($class, $str) = @_;
    bless {
	_str => $str,
	_err => undef, # errstr
	_res => undef, # validation result cache
	_dob => undef, # date is assumed to be 1
    }, $class;
}


sub validate {
    my ($self, $another) = @_;
    return validate_sim($another) if $another;
    return $self->{_res} if defined($self->{_res});

    $self->{_res} = 0;
    for ($self->{_str}) {
	s/\D+//g;
	if (length != 12) {
	    $self->{_err} = "not 12 digit";
	    return;
	}
	if (/^\d{4}(..)/ and !exists($provinces{$1})) {
	    $self->{_err} = "unknown 'province' code"; 
	    return;
	}
	my ($y, $m) = /^(..)(..)/;
	my $today = DateTime->today;
	$y += int($today->year / 100) * 100;
	$y -= 100 if $y > $today->year;
	eval { $self->{_dob} = DateTime->new(day=>1, month=>$m, year=>$y) };
	if ($@) {
	    $self->{_err} = "invalid year and month of birth: $y, $m";
	    return;
	}
	/(....)$/;
	if ($1 < 1) {
	    $self->{_err} = "serial starts from 1, not 0";
	    return;
	}
    }
    $self->{_res} = 1;
}


sub errstr {
    my ($self) = @_;
    $self->validate and return;
    $self->{_err};
}


sub normalize {
    my ($self, $another) = @_;
    return Business::ID::SIM->new($another)->normalize if $another;
    $self->validate or return;
    $self->{_str};
}


sub pretty { normalize(@_) }


sub area_code {
    my ($self) = @_;
    $self->validate or return;
    $self->{_str} =~ /^\d{4}(....)/;
    $1;
}


sub year_of_birth {
    my ($self) = @_;
    $self->validate or return;
    $self->{_dob}->year;
}


sub yob { year_of_birth(@_) }


sub month_of_birth {
    my ($self) = @_;
    $self->validate or return;
    $self->{_dob}->mon;
}


sub mob { month_of_birth(@_) }


sub serial {
    my ($self) = @_;
    $self->validate or return;
    $self->{_str} =~ /(\d{4})$/;
    $1;
}


sub validate_sim {
    my ($str) = @_;
    Business::ID::SIM->new($str)->validate();
}


1;

__END__
=pod

=head1 NAME

Business::ID::SIM - Validate Indonesian driving license number (nomor SIM)

=head1 VERSION

version 0.02

=head1 SYNOPSIS

    use Business::ID::SIM;
    
    # OO-style

    my $sim = Business::ID::SIM->new($str);
    die "Invalid SIM!" unless $sim->validate;

    print $sim->year_of_birth, "\n"; # also, yob()
    print $sim->mon_of_birth, "\n"; # also, mob()
    print $sim->area_code, "\n";
    print $sim->serial, "\n";

    # procedural style

    validate_sim($str) or die "Invalid SIM!";

=head1 DESCRIPTION

This module can be used to validate Indonesian driving license number,
Nomor Surat Izin Mengemudi (SIM).

SIM is composed of 12 digits as follow:

 yymm.pp.aa.ssss

yy and mm are year and month of birth, pp and aa are area code
(province+district of some sort), ssss is 4-digit serial most probably
starting from 1.

Note that there are several kinds of SIM (A, B1, B2, C) but this is
not encoded in the SIM number and all SIM's have the same number.

=head1 METHODS

=head2 new $str

Create a new C<Business::ID::SIM> object.

=head2 validate()

Return true if SIM is valid, or false if otherwise. In the case of SIM
being invalid, you can call the errstr() method to get a description
of the error.

=head2 errstr()

Return validation error of SIM, or undef if no error is found. See
C<validate()>.

=head2 normalize()

Return formatted SIM, or undef if SIM is invalid.

=head2 pretty()

Alias for normalize().

=head2 area_code()

Return 4-digit 'province'+district code component of SIM.

=head2 year_of_birth()

Return year component of the SIM, already added with the century, or
undef if SIM is invalid.

=head2 yob()

Alias for year_of_birth()

=head2 month_of_birth()

Return month component of the SIM, or undef if SIM is invalid.

=head2 mob()

Alias for month_of_birth().

=head2 serial()

Return 4-digit serial component of SIM, or undef if SIM is invalid.

=head1 FUNCTIONS

=head2 validate_sim($string)

Return true if SIM is valid, or false if otherwise. If you want to
know the error details, you need to use the OO version (see the
C<errstr> method).

Exported by default.

=head1 AUTHOR

Steven Haryanto, C<< <stevenharyanto at gmail.com> >>

=head1 BUGS

The list of valid 'province' codes in the program might need to be
updated from time to time.

Please report any bugs or feature requests to C<bug-business-id-sim at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Business-ID-SIM>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Business::ID::SIM

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-ID-SIM>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Business-ID-SIM>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Business-ID-SIM>

=item * Search CPAN

L<http://search.cpan.org/dist/Business-ID-SIM/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2009 Steven Haryanto.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 AUTHOR

  Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

