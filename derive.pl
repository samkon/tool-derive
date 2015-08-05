#!/usr/bin/perl
# derive.pl - by skonak 16.01.2012

my $derive	= $ARGV[0] || 0;
my $derive_from = $ARGV[1] || 0;

my $derive_FU = ucfirst($derive);
my $derive_drom_FU = ucfirst($derive_from);

my $derive_UC = uc($derive);
my $derive_drom_UC = uc($derive_from);

my $derive_LC = lc($derive);
my $derive_drom_LC = lc($derive_from);

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year = '20' . sprintf("%02d", $year % 100);
$mon  = sprintf("%02d", $mon + 1);

my $date  = "$mday.$mon.$year $hour:$min:$sec";

unless ($derive && $derive_from) {
  print "\nhedef veya kaynak dizin girilmedi\n";
  exit;
}

unless (-d $derive_from) {
  print "\nkaynak dizin eksik\n";
  exit;
}

my %directories = ();
my %files	= ();
my ($dcount,$fcount) = 0;

&calculate($derive_from);
#&replace_paths();
&derive($derive);

# ------------------------------------------------------------------

sub calculate {
  my $dir = shift;
  my @content = <$dir/*>;
  foreach my $c (@content) {
    print "$c\n";
    next if ($c =~ /CVS/);
    if (-d $c) {
      $directories{$c} = $dcount++;
    }
    elsif (-f $c) {
      $files{$c} = $fcount++;
    }
    &calculate($c) if (-d $c);
  }
}

# ------------------------------------------------------------------

sub replace_paths {
  # Replace Directories
  foreach my $c (keys %directories) {
    $c =~ s/$derive_from/$derive/g;
    $c =~ s/$derive_from_UF/$derive_UF/g;
    $c =~ s/$derive_from_UC/$derive_UC/g;
    $c =~ s/$derive_from_LC/$derive_LC/g;
  }
  # Replace Files
  #foreach my $c (keys %files) {
  #  $c =~ s/$derive_from/$derive/g;
  #}
}

# ------------------------------------------------------------------

sub derive {
  # Derive root directory
  unless (-d $derive) {
    `mkdir $derive`;
    print "ROOT created: $derive\n";
  }
  # Derive Directories
  foreach my $c (sort {$directories{$a} <=> $directories{$b}} 
		 keys %directories) {
    $c =~ s/$derive_from/$derive/g;
    $c =~ s/$derive_from_UF/$derive_UF/g;
    $c =~ s/$derive_from_UC/$derive_UC/g;
    $c =~ s/$derive_from_LC/$derive_LC/g;
    use File::Path;
    mkpath($c);
    print "$c\n";
  }
  # Derive Files
  foreach my $c (keys %files) {
    my $infile = $c;
    $c =~ s/$derive_from/$derive/g;
    $c =~ s/$derive_from_UF/$derive_UF/g;
    $c =~ s/$derive_from_UC/$derive_UC/g;
    $c =~ s/$derive_from_LC/$derive_LC/g;
    open(INFILE, "<$infile");
    open(OUTFILE, ">$c");
    while (<INFILE>) {
      $_ =~ s/$derive_from/$derive/g;
      $_ =~ s/$derive_from_UF/$derive_UF/g;
      $_ =~ s/$derive_from_UC/$derive_UC/g;
      $_ =~ s/$derive_from_LC/$derive_LC/g;
      print OUTFILE $_;
      # Add Derive Note
      if ($_ =~ /\#\!\/usr\/bin\/perl/) {
	print OUTFILE "# $derive is derived from $derive_from project on $date";
      }
    }
    close(OUTFILE);
    close(INFILE);
    print "$c\n";
  }
}
