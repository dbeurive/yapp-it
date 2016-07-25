package CallTracker;

use lib '.';
use warnings;
use strict;
use Constant;


# Create a new call tracker.
sub new {
    my $class = shift;
    my $self = {
        # List the calls in the order they are discovered by the (YAPP) parser.
        # Each element of the list is a reference to "$function->{<function name>}->[]".
        calls => [],
        # Calls' repository, referenced by functions' names.
        # key: <name of the function>
        # value: { args       => [[<arguments for the first call>], [<arguments for the second call>...]],
        #          seenInArgs => <number of times the fonction has been seen within arguments>,
        #          count      => <number of times the function has been called so far> }
        # Also: args => { type => TYPE_VARIABLE, name => <argument name>}
        #       or
        #       args => { type => TYPE_STRING, name => <argument name>}
        #       or
        #       args => { type => TYPE_NUMERIC, name => <argument name>}
        #       or
        #       args => { type => TYPE_FUNCTION, name => <argument name>, index => <number of times the __CALLED__ fonction has been seen within arguments>}
        #       The <number of times the fonction has been seen within arguments> starts at 0.
        functions => {},
        context => {}
    };

    bless($self, $class);
    return($self);
}

# Reset the call tracker.
sub reset {
    my $self = shift;

    $self->{calls}     = [];
    $self->{functions} = {};
}

# Add a call to track.
sub addCall {
    my $self = shift;
    my ($inFunctionName, $inArgs) = @_;
    my @args = ();

    # Create an entry in the calls' repository.
    unless(exists($self->{functions}->{$inFunctionName})) {
        $self->{functions}->{$inFunctionName} = { args => [], seenInArgs => 0, count => 0 };
    }

    # Scan the function's arguments.
    foreach my $arg (@{$inArgs}) {
        my $token = $arg->[0];
        my $type  = $arg->[1];

        if (TYPE_FUNCTION == $type) {
            push(@args, { type => TYPE_FUNCTION, name => $token, index => $self->{functions}->{$token}->{seenInArgs} });
            $self->{functions}->{$token}->{seenInArgs} += 1;
        } elsif (TYPE_VARIABLE == $type) {
            push(@args, { type => TYPE_VARIABLE, name => $token });
        } elsif (TYPE_NUMERIC == $type) {
            push(@args, { type => TYPE_NUMERIC, name => $token });
        } elsif (TYPE_STRING == $type) {
            push(@args, { type => TYPE_STRING, name => $token });
        } else {
            die("Unexpected type <$type>!");
        }

    }

    # Add the call into the calls' repository.
    push(@{$self->{functions}->{$inFunctionName}->{args}}, \@args);
    $self->{functions}->{$inFunctionName}->{count} += 1;

    # Add (the reference to) the newly detected call to the __ORDERED__ list of calls.
    my $index = $self->{functions}->{$inFunctionName}->{count} - 1;
    unshift(@{$self->{calls}}, {
        function => $inFunctionName,
        index => $index
        # args => $self->{functions}->{$inFunctionName}->{args}->[$index]
    });

    return $self;
}

# Extract the calls.
sub traverse {
    my $self = shift;
    my ($inFunctionName, $inCallIndex, $inOptProcessValue, $inOptProcessFunction) = @_;
    my @args = @{$self->{functions}->{$inFunctionName}->{args}->[$inCallIndex]};

    my $defaultProcessVariable = sub {
        my ($inVariableNane) = @_;
    };

    my $defaultProcessFunction = sub {
        my ($inFunctionName, $inArgs) = @_;
    };

    $inOptProcessValue = defined $inOptProcessValue ? $inOptProcessValue : \&$defaultProcessVariable;
    $inOptProcessFunction = defined $inOptProcessFunction ? $inOptProcessFunction : \&$defaultProcessFunction;

    # We choose to traverse the siblings from riht to left.
    for (my $i=int(@args)-1; $i>-1; $i--) {
        my $arg = $args[$i];
        if (TYPE_VARIABLE == $arg->{type}  ||
            TYPE_NUMERIC  == $arg->{type}  ||
            TYPE_STRING   == $arg->{type}) {
            &$inOptProcessValue($arg->{name}, $self);
            next;
        }
        # This is not a variable... so this is a function's call.
        $self->traverse($arg->{name}, $arg->{index}, $inOptProcessValue, $inOptProcessFunction);        
    }

    # You can traverse the siblings from left to right or the other way...
    # It doe not matter.
    # foreach my $arg (@args) {
    #     # Is the argument a variable ?
    #     if (TYPE_VARIABLE == $arg->{type}) {
    #         print "  " . $arg->{name} . "\n";
    #         next;
    #     }
    #     # This is not a variable... so this is a function's call.
    #     $self->traverse($arg->{name}, $arg->{index});
    # }
    
    # print $inFunctionName . '():' . int(@args) . "\n";
    &$inOptProcessFunction($inFunctionName, \@args, $self);
}



sub dump {
    my $self = shift;
    my ($inIndent) = @_;

    my $processValue = sub {
        my ($inValue, $self) = @_;
        push (@{$self->{context}->{dump}}, $inValue);
        # print "$inValue\n";
    };

    my $processFunction = sub {
        my ($inFunctionName, $inArgs, $self) = @_;
        push (@{$self->{context}->{dump}}, "$inFunctionName:" . int(@{$inArgs}));
        # print "$inFunctionName:" . int(@{$inArgs}) . "\n";
    };

    $self->{context}->{dump} = [];
    $self->traverse($self->{calls}->[0]->{function}, 0, \&$processValue, \&$processFunction);

    foreach my $line (@{$self->{context}->{dump}}) {
        $line = $inIndent . $line;
    }

    return @{$self->{context}->{dump}};
}

sub debug {
    my $self = shift;
    require Data::Dumper;
    print Data::Dumper::Dumper($self->{calls});
    print Data::Dumper::Dumper($self->{functions});
}



1;
