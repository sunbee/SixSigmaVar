package Node;
use Moose;

has 'name'	=> (
		is			=>	'rw', 
		isa 		=>	'Str',
		default		=>	'generic',
);

has 'WIP'	=> (
		is			=>	'rw', 
		isa 		=>	'Int',
		default		=>	0,
		predicate	=>	'has_WIP',
		clearer		=>	'clear_WIP',
);

has 'last_roll'	=> (
		is			=>	'rw', 
		isa 		=>	'Int',
		predicate	=>	'has_lastRoll',
		clearer		=>	'clear_lastRoll',
		default		=>	0,
);

has 'predecessor'	=> (
		is			=>	'rw', 
		isa 		=>	'Node',
		predicate	=>	'has_predecessor',
		clearer		=>	'clear_predecessor',
);

has 'successor'	=> (
		is			=>	'rw', 
		isa 		=>	'Node',
		predicate	=>	'has_successor',
		clearer		=>	'clear_successor',
		weak_ref	=>	1,
);

has 'min_max'	=> (
		is			=>	'rw', 
		isa 		=>	'MinMax',
		default		=>	sub {	MinMax->new;	},
);

sub step {
	my $self = shift;
	my $processed;
	
	$processed = $self->roll_dice;
	unless ($self->WIP > $processed) {
		$processed = $self->WIP;
	};
	$self->last_roll($processed);
	$self->deplete_wip($processed);
	$self->push_out($processed);
	$self->invoke_predecessor();
};

sub roll_dice {
	my $self = shift;
	my $min; 
	my $max;
	my $range; 
	my $randomNumber;
	$min = $self->min_max->min;
	$max = $self->min_max->max;
	$range = $max - $min + 1;
	$randomNumber = int(rand($range)) + $min;
	
	return $randomNumber;
};

sub deplete_wip {
	my ($self, $processed) = @_;
	
	$self->WIP($self->WIP - $processed);
};

sub push_out {
	my ($self, $processed) = @_;
	if ($self->has_successor) {
		my $successor = $self->successor;
		$successor->WIP($successor->WIP + $processed);
	};
};

sub invoke_predecessor {
	my $self = shift;
	
	return unless $self->has_predecessor;

	my $predecessor = $self->predecessor;
	$predecessor->step;
	
	return 1;
};

package START;
use Moose;

extends 'Node';

sub step {
	my $self = shift;
	my $processed;
	
	$processed = $self->roll_dice;
	$self->last_roll($processed);
	$self->push_out($processed);
};

sub BUILD {
	my $self = shift;
	$self->name('START');
	$self->clear_predecessor;
};

after 'predecessor' => sub {
	my $self = shift;
	$self->clear_predecessor;
};

after 'WIP'	=> sub {
	my $self = shift;
	$self->clear_WIP;
};

package FIN;
use Moose;

extends 'Node';

sub BUILD {
	my $self = shift;
	$self->name('FIN');
	$self->clear_successor;
};

after 'successor' => sub {
	my $self = shift;
	$self->clear_successor;
};

package MinMax;
use Moose;

has 'min'	=> (
		is			=>	'rw', 
		isa 		=>	'Int',
		default		=>	1,
);

has 'max'	=> (
		is			=>	'rw', 
		isa 		=>	'Int',
		default		=>	6,
);

1;

#When the default is called during object construction, it may be called before other attributes have been set. 
# If your default is dependent on other parts of the object's state, you can make the attribute lazy. 
# Laziness is covered in the next section.
# If you want to use a reference of any sort as the default value, you must return it from a subroutine.