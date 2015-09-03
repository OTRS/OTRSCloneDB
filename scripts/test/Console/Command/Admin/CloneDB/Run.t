# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;
use utf8;

use vars (qw($Self));

my $CommandObject = $Kernel::OM->Get('Kernel::System::Console::Command::Admin::CloneDB::Run');

# check command without option
my $ExitCode = $CommandObject->Execute();

$Self->Is(
    $ExitCode,
    1,
    "Admin::CloneDB::Run - No options",
);

# check command with '--mode dry' option
$ExitCode = $CommandObject->Execute( '--mode', 'dry' );

$Self->Is(
    $ExitCode,
    0,
    "Admin::CloneDB::Run --mode dry option",
);

# check command with '--mode real --force' options
$ExitCode = $CommandObject->Execute( '--mode', 'real', '--force' );

$Self->Is(
    $ExitCode,
    0,
    "Admin::CloneDB::Run --mode dry --force options",
);

1;
