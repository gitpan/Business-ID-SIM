package Business::ID::SIM;

use 5.010001;
use warnings;
use strict;

use DateTime;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(parse_sim);

our $VERSION = '0.04'; # VERSION

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

our %SPEC;

$SPEC{parse_sim} = {
    v => 1.1,
    summary => 'Validate Indonesian driving license number (nomor SIM)',
    args => {
        sim => {
            summary => 'Input to be parsed',
            schema => 'str*',
            pos => 0,
            req => 1,
        },
    },
};
sub parse_sim {
    my %args = @_;

    my $sim = $args{sim} or return [400, "Please specify sim"];
    my $res = {};

    $sim =~ s/\D+//g;
    return [400, "Not 12 digit"] unless length($sim) == 12;

    $res->{prov_code} = substr($sim, 4, 2);
    return [400, "Unknown province code"] unless $provinces{$res->{prov_code}};
    $res->{area_code} = substr($sim, 4, 4);

    my ($y, $m) = $sim =~ /^(..)(..)/;
    my $today = DateTime->today;
    $y += int($today->year / 100) * 100;
    $y -= 100 if $y > $today->year;
    eval { $res->{dob} = DateTime->new(day=>1, month=>$m, year=>$y) };
    return [400, "Invalid year and month of birth: $y, $m"] if $@;
    $res->{serial} = $sim =~ /(....)$/;
    return [400, "Serial starts from 1, not 0"] if $res->{serial} < 1;

    [200, "OK", $res];
}

1;
# ABSTRACT: Validate Indonesian driving license number (nomor SIM)

__END__

=pod

=encoding UTF-8

=head1 NAME

Business::ID::SIM - Validate Indonesian driving license number (nomor SIM)

=head1 VERSION

version 0.04

=head1 SYNOPSIS

 use Business::ID::SIM qw(parse_sim);

 my $res = parse_sim(sim => "0113 40 00 0001");

=head1 DESCRIPTION

This module can be used to validate Indonesian driving license number, Nomor
Surat Izin Mengemudi (SIM).

SIM is composed of 12 digits as follow:

 yymm.pp.aa.ssss

yy and mm are year and month of birth, pp and aa are area code
(province+district of some sort), ssss is 4-digit serial most probably starting
from 1.

Note that there are several kinds of SIM (A, B1, B2, C) but this is not encoded
in the SIM number and all SIM's have the same number.

=head1 FUNCTIONS


None are exported by default, but they are exportable.

=head2 parse_sim(%args) -> [status, msg, result, meta]

Arguments ('*' denotes required arguments):

=over 4

=item * B<sim>* => I<str>

Input to be parsed.

=back

Return value:

Returns an enveloped result (an array). First element (status) is an integer containing HTTP status code (200 means OK, 4xx caller error, 5xx function error). Second element (msg) is a string containing error message, or 'OK' if status is 200. Third element (result) is optional, the actual result. Fourth element (meta) is called result metadata and is optional, a hash that contains extra information.

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Business-ID-SIM>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Business-ID-SIM>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Business-ID-SIM>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
