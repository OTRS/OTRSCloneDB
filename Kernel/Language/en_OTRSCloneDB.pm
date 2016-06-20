# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::en_OTRSCloneDB;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # SysConfig
    $Self->{Translation}->{'Settings for connecting with the target database.'} = '';
    $Self->{Translation}->{'List of tables should be skipped, perhaps internal DB tables. Please use lowercase.'} = '';
    $Self->{Translation}->{'This setting specifies which table columns contain blob data as these need special treatment.'} = '';
    $Self->{Translation}->{'Specifies which columns should be checked for valid UTF-8 source data.'} = '';
    $Self->{Translation}->{'Log file for replacement of malformed UTF-8 data values.'} = '';

    #
    # OBSOLETE ENTRIES FOR REFERENCE, DO NOT TRANSLATE!
    #

}

1;
