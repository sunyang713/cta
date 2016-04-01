###   Jonathan Sun
###   v5
###   Last modified: 2014.07.24
###   
###   Triple '#' indicates magic number .... dunno perl convention for static constant stuff
###
###   Also, snapshot2 has to be in the same folder as this perl script, and the perl script has to be executed from the folder in which snapshot2 resides (I think)
###


#!/user/bin/perl
use strict;
use warnings;

use Path::Class;
use autodie;
use File::Basename;
use Cwd 'abs_path';
use File::Spec;


my $number_of_arguments = scalar @ARGV;
die "\nPlease specify wirless-cta-__ location, i.e.:\n
     >>  perl extract-stress-tests.pl ~/dir1/wireless-cta-2/\n" if ( $number_of_arguments < 1 );


mkdir"$ARGV[0]/logs"    if ! -d "$ARGV[0]/logs";

my $read_dir            =  dir( "$ARGV[0]/pics" );
my $write_dir           =  dir( "$ARGV[0]/logs" );

my $dir                 =  dir( "$ARGV[0]" );
my $name                =  basename($dir);

my $log                 =  $write_dir->file("$name.log");
my $log_handler         =  $log->openw();

my $error_log           =  $write_dir->file("$name-errors.log");
my $error_log_handler   =  $error_log->openw();

my @exts                =  qw(.log .jpg);
###
my $set_index           =  1;
my $success_count       =  0;
my $error_count         =  0;

print "
  *******STARTING HERE*******
  reading from: $read_dir\n";


###
#   Iterates over all of the sets (folders).
#   Will pull information from each set as a contained 'appending.'
#      This 'appending' will then be added to the final <LOG> file.
#   Counts number of sets.
#   Resets after every set investigation: got-data, Appending.
###
while ( my $set = $read_dir->next ) {

    next if ( ! -d $set );

    print "\n$set_index------ Looking through: $set\n";

    my $set_path      =  $set->stringify();
    my @item_list     = `ls -Ut $set_path`;
    my $got_data      =  0;
    my @appending;

    ###
    #   Iterates through inner set
    #   Convention: set should contain one <.log> file with the START and END date-time-temps.
    #               set should also contain <.jpg> (s) Could be 100, could be 1.
    #   Idea is to grab the most recent <.jpg> and get the data from that.
    #               also pull most recent date-time-temp from <.log> file.
    ###
    while ( my $item = $set->next ) {

	next if $item->is_dir();
	
	my $item_path      = $item->stringify();

	my $file_parts = $item;
	chomp $file_parts;

	## I switched the $name and $dir convention I found online; seems backwards?
	my ($name, $dir, $ext) = fileparse($file_parts, @exts);

	###
	#   If a <.log> file is found:
	#   Finds the most recent date-time and appends to Appending.
	#   <.log> files are supposed to have "START: <date-time-temp>  END: <date-time-temp>"
	#      However, sometimes something is missing, so can't just consistently pull a date-time.
	#      Sometimes accidentally pulls out "END."
	#   Simple fix: if the size of the found <.log> is less than <4>, pulls whatever it can,
	#      As long as it's not "END" or "START."
	###
	if ( $ext eq '.log' ) {
	    my @item_content     = $item->slurp();
	    my $item_handler     = $item->openr();
	    my $number_of_lines  = scalar @item_content;
	    my $lines_index      = 1;

	    foreach my $line ( @item_content ) {
		if ( $line ne "END\n" && $line ne "START\n" ) {
###
		    if ( $number_of_lines == 4 ) {
			unshift ( @appending, $line ) if $lines_index == $number_of_lines;
		    } else {
			unshift ( @appending, $line );
		    }
		}
		$lines_index++;
	    }
	}

	###
	#   If <.jpg> found and snapshot-data has not been collected for this set:
	#   Takes `ls` of entire set, snapshots the most recent image --> Get data.
	#   Appends data to Appending to be appended to final <.log> file.
	###
###
	if( $ext eq '.jpg' && $got_data == 0 ) {
	    my $snapshot_data = "";

	    ## Sometimes the most recent file is not a <.jpg>, 
	    ##    so this flimsy fix checks to see if the first one is <.jpg>.
	    ##    If it isn't, it takes the second one.
	    ## Better fix would be a loop that increments the $list-index until a <.jpg> is found.
	    if ( index($item_list[0], ".jpg") != -1 ) {
		$snapshot_data = `./snapshot2 $set_path/$item_list[0]`;
	    } else {
		$snapshot_data = `./snapshot2 $set_path/$item_list[1]`;
	    }

	    my @snapshot_data_lines = split /\n/, $snapshot_data;

	    ## Adding snapshot-data to Appending.
	    foreach my $line ( @snapshot_data_lines ) {
		push( @appending, "$line\n");
	    }
###
	    $got_data = '1';
	}
    }


    ##  If the appending does not satisfy the standard of three lines of info:
    ##        date-time-temp
    ##        snapshot-data-line-1
    ##        snapshot-data-line-2
    ##
    ##  Or more accurately, just checks if there are three lines.
    ##        Perhaps a check on whether the lines are correct 'data-types' is needed.
    ##
    ##  Reports the error to an error <.log>. Notes the set-folder-location
    ##        Helpful for finding out where and why something is missing or wrong in the <LOG>.
    my $appending_size = scalar @appending;
###
    if ( $appending_size != 3 ) {
	$error_log_handler->print( "$set \n" );
	$error_count++;
	$set_index++;
	next;
    }

    ##  Appends the prepared Appending (extracted from the set) to the <LOG>.
    my $index = 0;
    $success_count++;
    foreach my $line ( @appending ) {
	print "------------ Appending to <LOG>: \n" if $index == 0;
	print "                  $line";
	$log_handler->print( $line );
	$index++;
    }
    $log_handler->print("\n") if $got_data == 1;
    $set_index++;
}




print "\n
---------------------------------------------------------------------------------------
------------------------------------ Done! --------------------------------------------
---------------------------------------------------------------------------------------

         Successful data sets:            $success_count
         Exceptions:                      $error_count
         Total sets examined:             $set_index

         Check errors <.log> at           $error_log
         Final <LOG> at                   $log

   Thank you for your patronage. Have a nice day.\n\n";
