package Buffer;
   
use warnings;
use strict;

sub new {
	my $class = shift; 
 	my $self = {
 		list => []
 	};
 	bless($self, $class);
 	return($self);
}

sub reset {
	my $self = shift;
	$self->{list} = [];
}

sub add {
 	my $self = shift;
 	my ($inChar) = @_;
 	push(@{$self->{list}}, $inChar);
 	return $self;
}

sub get {
	my $self = shift;
	return $self->{list};
}



1;