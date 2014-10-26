# Czech.pm
#
# (c) 2005 Jiri Vaclavik <jiri.vaclavik@NOSPAMgmailNOSPAM.com>
# All rights reserved. This program is free software; you can redistribute
# and/or modify it under the same terms as perl itself.

=head1 NAME

Date::Say::Czech - Output dates as text as you would speak it

=head1 SYNOPSIS

 use Date::Say::Czech;

 print time_to_say(time());
 print date_to_say($DAY, $MONTH, $YEAR);

=head1 DESCRIPTION

This module provides you with functions to easily convert a date (given
as either integer values for day, month and year or as a unix timestamp)
to its representation as czech text, like you would read it aloud.

=head1 EXPORTABLE TAGS

:ALL    - all helper methods are also exported into the callers namespace

=head1 FUNCTIONS

=head2 Exported by default

=over 2

=item B<time_to_say($TIMESTAMP)>

In scalar context, return a string consisting of the text
representation of the date in the given unix timestamp,
like e.g. "dvac�t�ho p�t�ho �ervna dva tis�ce p�t".

In list context, returns the three words of the string as a list.

=item B<date_to_say($DAY, $MONTH, $YEAR)>

Takes the values for day of month, month and year as integers
(month starting with B<1>) and gives the same return values as
I<time_to_say>.

=back

=head2 Exported by :ALL

=over 2

=item B<year_to_say($YEAR)>

Takes a year (absolute integer value) as input and returns the
text representation in Czech.

=item B<month_to_speak($MONTH)>

Takes a month (integer value, January = 1) as input and returns
the text representation in Czech.

=item B<day_to_say($DAY)>

Converts a day number to its Czech text representation.

=back

=head1 BUGS

Please report all bugs to the author of this module:
Jiri Vaclavik <jiri.vaclavik@NOSPAMgmailNOSPAM.com>

=for html <a href="mailto:jiri.vaclavik@NOSPAMgmailNOSPAM.com?subject=Bug%20in%20Date::Say::Czech">Mail a Bug</a>

=head1 AUTHOR

Jiri Vaclavik <jiri.vaclavik@NOSPAMgmailNOSPAM.com>

=head1 SEE ALSO

Date::Spoken::German from Christian Winter


=cut

package Date::Say::Czech;

require Exporter;
require POSIX;

@ISA = qw(Exporter Date::Say::Czech);
@EXPORT_OK = qw(date_to_say time_to_say);
%EXPORT_TAGS = ( ALL => [qw(year_to_say date_to_say time_to_say month_to_say day_to_say)] );
$VERSION = "0.04";
$AUTHOR = 'Jiri Vaclavik <jiri.vaclavik@NOSPAMgmailNOSPAM.com>';

my %cipher = (1 => "jedna", 2 => "dva", 3 => "t�i", 4 => "�ty�i", 5 => "p�t", 6 => "�est", 7 => "sedm", 8 => "osm", 9 => "dev�t", 10 => "deset", 11 => "jeden�ct", 12 => "dvan�ct", 13 => "t�in�ct", 14 => "�trn�ct", 15 => "patn�ct", 16 => "�estn�ct", 17 => "sedmn�ct", 18 => "osmn�ct", 19 => "devaten�ct");
my %specialcipher = (1 => "prvn�ho", 2 => "druh�ho", 3 => "t�et�ho", 4 => "�tvrt�ho", 5 => "p�t�ho", 6 => "�est�ho", 7 => "sedm�ho", 8 => "osm�ho", 9 => "dev�t�ho", 10 => "des�t�ho", 11 => "jeden�ct�ho", 12 => "dvan�ct�ho", 13 => "t�in�ct�ho", 14 => "�trn�ct�ho", 15 => "patn�ct�ho", 16 => "�estn�ct�ho", 17 => "sedmn�ct�ho", 18 => "osmn�ct�ho", 19 => "devaten�ct�ho");
my %tens = (1 => "deset", 2 => "dvacet", 3 => "t�icet", 4 => "�ty�icet", 5 => "pades�t", 6 => "�edes�t", 7 => "sedmdes�t", 8 => "osmdes�t", 9 => "devades�t" );
my %specialtens = (1 => "des�t�ho", 2 => "dvac�t�ho", 3 => "t�ic�t�ho", 4 => "�ty�ic�t�ho", 5 => "pades�t�ho", 6 => "�edes�t�ho", 7 => "sedmdes�t�ho", 8 => "osmdes�t�ho", 9 => "devades�t�ho" );
my %months = (  1 => "leden", 2 => "�nor", 3 => "b�ezen", 4 => "duben", 5 => "kv�ten", 6 => "�erven", 7 => "�ervenec", 8 => "srpen", 9 => "z���", 10 => "��jen", 11 => "listopad", 12 => "prosinec" );
my %specialmonths = (  1 => "ledna", 2 => "�nora", 3 => "b�ezna", 4 => "dubna", 5 => "kv�tna", 6 => "�ervna", 7 => "�ervence", 8 => "srpna", 9 => "z���", 10 => "��jna", 11 => "listopadu", 12 => "prosince" );

sub year_to_say
{
    my $year = shift;
    (my $tens = $year) =~ s/^.*(\d\d)$/$1/;
    my $hundreds = "";
    if( $year < 10 ) {
        $tens = "";
        $hundreds = $cipher{$year} || "null";
    } else {
        if( $tens == 0 ) {
            $tens = "";
        } elsif( ($tens % 10) == 0 ) {
            $tens =~ s/(.)(.)/$tens{$1}/;
        } else {
            if( $tens < 10 ) {
                $tens =~ s/(.)(.)/$cipher{$2}/;
            } elsif( $tens < 20 ) {
                $tens =~ s/(.)(.)/$cipher{$1.$2}/;
            } else {
                $tens =~ s/(.)(.)/$tens{$1}." ".$cipher{$2}/e;
            }
        }
        if( $year >= 100 ) {
            ($hundreds = $year) =~ s/^(.?.)..$/$1/;
            if( $hundreds % 10 == 0) {
                $thousand = thousand_form($hundreds);
                if($hundreds == 10){
                    $hundreds =~ s/(.)(.)/"tis�c "/ex;
                }else{
                    $hundreds =~ s/(.)(.)/$cipher{$1}." ".$thousand/ex;
                }
            } else {
                if( $hundreds > 10 ) {
                    $thousand = thousand_form($hundreds);
                    if ($hundreds < 20){
                        $hundred = hundred_form($hundreds);
                        my($x, $y) = split("", $hundreds);
                        if($y == 1){
                            $hundreds =~ s/(.)(.)/"tis�c sto "/ex;
                        }else{
                            $hundreds =~ s/(.)(.)/"tis�c ".$cipher{$2}." $hundred "/ex;
                        }
                    }else{
                        $hundred = hundred_form($hundreds);
                        my($x, $y) = split("", $hundreds);
                        if($y == 1){
                           $hundreds = "sto ";
                        }else{
                            $hundreds =~ s/(.)(.)/$cipher{"$1"}." ".$thousand.$cipher{$2}." ".$hundred." "/e;
                        }
                    }
                } else {
                    if($hundreds == 1){
                       $hundreds = "sto ";
                    }else{
                       $hundred = hundred_form($hundreds);
                       $hundreds = $cipher{$hundreds}." ".$hundred;
                    }
                }
            }
        }
    }
    return $hundreds.$tens;
}

sub hundred_form {
    my($hundreds) = shift;
    my($x, $num) = split("", $hundreds);
    if($num > 4){
        return "set";
    }else{
        return "sta";
    }
}

sub thousand_form {
    my($num) = shift;
    if($num > 49){
        return "tis�c ";
    }else{
        return "tis�ce ";
    }
}

sub month_to_say
{
    my $month = shift;
    return $specialmonths{$month};
}

sub day_to_say
{
    my $tag = shift;
    if( $tag >= 10 ) {
        $tag =~ s/(.)(.)/$specialcipher{"$1$2"} || $specialtens{$1}." ".$specialcipher{$2}/ex;
    } else {
        $tag = $specialcipher{$tag} || $cipher{$tag};
    }
    return $tag;
}

sub date_to_say
{
    my($day, $month, $year) = @_;
    if( wantarray ) {
        return day_to_say($day), " ", month_to_say($month), " ", year_to_say($year);
    } else {
        return day_to_say($day)." ".month_to_say($month)." ".year_to_say($year);
    }
}

sub time_to_say
{
    my($day, $month, $year) = (gmtime( shift || time() ))[3,4,5];
    return date_to_say($day, $month+1, 1900+$year);
}

1;
