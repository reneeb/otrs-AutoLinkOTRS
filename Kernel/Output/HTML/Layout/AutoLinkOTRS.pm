# --
# Copyright (C) 2017 - 2022 Perl-Services.de, https://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Layout::AutoLinkOTRS;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub Kernel::Output::HTML::Layout::ArticlePreview {
    my ( $Self, %Param ) = @_;

    my $Preview = $Self->Kernel::Output::HTML::Layout::Article::ArticlePreview( %Param );

    return $Preview if $Param{ResultType} && $Param{ResultType} ne 'HTML';

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Baselink = $Self->{Baselink};
    my $Token    = $Self->{UserChallengeToken};
    my $Title    = $Self->{LanguageObject}->Translate("Copy Generic Agent");

    my $Hook    = $ConfigObject->Get('Ticket::Hook')        // 'Ticket#';
    my $Divider = $ConfigObject->Get('Ticket::HookDivider') // '';
    my $HTTP    = $ConfigObject->Get('HttpType')            // 'http';
    my $FQDN    = $ConfigObject->Get('FQDN')                // 'localhost';
    my $Script  = $ConfigObject->Get('ScriptAlias')         // 'otrs';

    my $UseSession = $ConfigObject->Get('SessionUseCookie');
    my $Name       = $ConfigObject->Get('SessionName') // 'OTRSAgentInterface';
    my $Session    = '';

    if ( !$UseSession ) {
        $Session = sprintf "%s=%s", $Name, $Self->{SessionID};
    }

    my $URL = sprintf '<a href="%sAction=AgentTicketZoom;TicketID=%%s;%s">%%s</a>',
        $Self->{Baselink}, $Session;

    my $Regex = $ConfigObject->Get('AutoLinkOTRS::TicketNumberRegex') || '\d+';
    $Preview =~ s{
        (\Q$Hook$Divider\E($Regex))
    }{
        my $URL = $Self->_BuildTicketURL( $URL, $1, $2 );
        $URL ? $URL : $1;
    }exmsg;

    return $Preview;
}

sub _BuildTicketURL {
    my ($Self, $URL, $Text, $Number) = @_;

    return if !$Number;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $TicketID = $TicketObject->TicketCheckNumber(
        Tn => $Number,
    );

    return if !$TicketID;

    my $TicketURL = sprintf $URL, $TicketID, $Text;
    return $TicketURL;
}


1;
