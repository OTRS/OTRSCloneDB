# --
# Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Console::Command::Admin::CloneDB::Run;

use strict;
use warnings;

use base qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::CloneDB::Backend',
    'Kernel::System::DB',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Clone OTRS database.');
    $Self->AddOption(
        Name        => 'mode',
        Description => "Mode of executing the command - real or dry (See help for more info!).",
        Required    => 1,
        HasValue    => 1,
        ValueRegex  => qr/(real|dry)/smx,
    );
    $Self->AddOption(
        Name        => 'force',
        Description => 'Continue even if there are errors while writing the data.',
        Required    => 0,
        HasValue    => 0,
    );

    $Self->AdditionalHelp(<<"EOF");

<yellow>\tThis script clones an OTRS database into an empty target database, even
\ton another database platform. It will dynamically get the list of tables in the
\tsource DB, and copy the data of each table to the target DB.
</yellow>
<green>\t--mode real: Clone the data into the target database.
\t--mode dry: Dry run mode, only read and verify, but don't write to the target database.
\t--force: Continue even if there are errors while writing the data.
</green>
<red>\tPlease note that you first need to configure the target database via SysConfig.</red>
EOF

    return;
}

sub PreRun {
    my ( $Self, %Param ) = @_;

    $Self->{SourceDBObject} = $Kernel::OM->Get('Kernel::System::DB')
        || die "Could not connect to source DB";

    # create CloneDB backend object
    $Self->{CloneDBBackendObject} = $Kernel::OM->Get('Kernel::System::CloneDB::Backend')
        || die "Could not create clone db object.";

    # get the target DB settings
    my $TargetDBSettings = $Kernel::OM->Get('Kernel::Config')->Get('CloneDB::TargetDBSettings');

    # create DB connections
    $Self->{TargetDBObject} = $Self->{CloneDBBackendObject}->CreateTargetDBConnection(
        TargetDBSettings => $TargetDBSettings,
    );
    die "Could not create target DB connection." if !$Self->{TargetDBObject};

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Cloning OTRS database...</yellow>\n");
    $Self->Print( "\n<green>" . ( '=' x 69 ) . "</green>\n" );

    my $CloneMode = $Self->GetOption('mode');
    my $DryRun;

    if ( $CloneMode eq 'real' ) {
        $Self->{CloneDBBackendObject}->PopulateTargetStructuresPre(
            TargetDBObject => $Self->{TargetDBObject},
        );
    }
    else {
        $DryRun = 1;
    }

    my $SanityResult = $Self->{CloneDBBackendObject}->SanityChecks(
        TargetDBObject => $Self->{TargetDBObject},
        DryRun         => $DryRun || '',
    );
    if ($SanityResult) {
        my $DataTransferResult = $Self->{CloneDBBackendObject}->DataTransfer(
            TargetDBObject => $Self->{TargetDBObject},
            DryRun         => $DryRun || '',
            Force          => $Self->GetOption('force') || '',
        );

        if ( !$DataTransferResult ) {
            $Self->PrintError("Aborting because it is not possible to complete the data transfer.");
            return $Self->ExitCodeError();
        }

        if ( $DataTransferResult eq 2 ) {
            $Self->Print("<green>Dry run successfully finished.</green>\n");
        }
    }

    if ( $CloneMode eq 'real' ) {
        $Self->{CloneDBBackendObject}->PopulateTargetStructuresPost(
            TargetDBObject => $Self->{TargetDBObject},
        );
    }

    $Self->Print( "\n<green>" . ( '=' x 69 ) . "</green>\n" );
    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();

}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
