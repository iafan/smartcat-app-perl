use strict;
use warnings;

package Smartcat::App::Command;
use App::Cmd::Setup -command;

use File::Basename;

sub opt_spec {
    return (
        #[ 'config:s' => 'Config file path' ],
        [ 'token-id:s' => 'Smartcat account id' ],
        [ 'token:s'    => 'API token' ],
        [ 'log:s'      => 'Log file path' ]
    );
}

sub project_id_opt_spec {
    return ( [ 'project-id:s' => 'Project Id' ], );
}

sub project_workdir_opt_spec {
    return ( [ 'project-workdir:s' => 'Project translation files path' ], );
}

sub file_params_opt_spec {
    return (
        [ 'filetype:s' => 'Type of translation files' ],
        [
            'file-per-language' =>
              'Create a separate document for every language'
        ],

        #[ 'filename-template:s' => 'Template for per language filenames' ],
    );
}

sub validate_file_params {
    my ( $self, $opt, $args ) = @_;
    my $rundata = $self->app->{rundata};
    $rundata->{filetype} = defined $opt->{filetype} ? $opt->{filetype} : '.po';
    $rundata->{file_per_language} =
      defined $opt->{file_per_language} ? $opt->{file_per_language} : 0;

#if ($rundata->{file_per_language}) {
#    $self->app->{filename_template} = defined $opt->{filename_template} ? $opt->{filename_template} : '%LANG%_';
#}
}

sub validate_project_id {
    my ( $self, $opt, $args ) = @_;
    my $rundata = $self->app->{rundata};
    $self->usage_error("'project_id' is required")
      unless defined $opt->{project_id};
    $rundata->{project_id} = $opt->{project_id};
}

sub validate_project_workdir {
    my ( $self, $opt, $args ) = @_;

    my $rundata = $self->app->{rundata};
    $self->app->usage_error(
"'project_workdir', which is set to '$opt->{project_workdir}', does not point to a valid directory"
    ) unless -d $opt->{project_workdir};
    $rundata->{project_workdir} = $opt->{project_workdir};
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    my $app = $self->app;

    if ( defined $opt->{token_id} && defined $opt->{token} ) {
        $app->{config}->{username} = $opt->{token_id};
        $app->{config}->{password} = $opt->{token};
    }
    if ( defined $opt->{log} ) {
        $self->usage_error(
"directory of 'log', which is set to '$opt->{log}', does not point to a valid directory"
        ) unless -d dirname( $opt->{log} ) && -w _;
        $app->{config}->{log} = $opt->{log};
    }

    $self->usage_error(
"set params via 'config' command first or provide auth 'token_id' and 'token'"
      )
      unless ( defined $app->{config}->username
        && defined $app->{config}->password );

    $app->init;
}

1;
