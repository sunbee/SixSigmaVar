package Process;
use Moose;
use Node;

has 'start' => (
		is			=>	'rw', 
		isa 		=>	'START',
		predicate	=>	'has_START',
		required	=>	1,
		default		=>	sub {	START->new;	},
);

has 'nodes'	=> (
		traits		=>	['Array'],
		is			=>	'rw', 
		isa 		=>	'ArrayRef[Node]',
		default		=>	sub {	[]	},
		handles		=>	{
				all_nodes		=>	'elements',
				add_nodes		=>	'push',
				map_nodes		=>	'map',
				filter_nodes	=>	'grep',
				find_node		=>	'first',
				get_node		=>	'get',
				join_nodes		=>	'join',
				count_nodes		=>	'count',
				has_nodes		=>	'count',
				has_no_nodes	=>	'is_empty',
				sorted_nodes	=>	'sort',
				clear_nodes		=>	'clear',
		},
);

has 'fin' => (
		is			=>	'rw', 
		isa 		=>	'FIN',
		predicate	=>	'has_FIN',
		required	=>	1,
		default		=>	sub {	FIN->new;	},
);

after 'add_nodes' => sub {
	my $self = shift;
	my $count =  $self->count_nodes;
	if($count == 1) {
		my $ceNode = $self->nodes->[0];
		$self->start->successor($ceNode);
		$ceNode->predecessor($self->start);
		$ceNode->successor($self->fin);
		$self->fin->predecessor($ceNode);
	} else {
		my $ultimateNode 	= $self->nodes->[$count - 1];
		my $penultimateNode = $self->nodes->[$count - 2];
		my $fin				= $self->fin;
		$penultimateNode->successor($ultimateNode);
		$ultimateNode->predecessor($penultimateNode);
		$ultimateNode->successor($fin);
		$fin->predecessor($ultimateNode);
	};
};

sub print_stations {
	my $self = shift;
	
	return $self->print_stations_forward;
};

sub print_stations_forward {
	my $self = shift;
	my @namesForward = ();
	my $ceNode = $self->start; push @namesForward, $ceNode->name;
	while ($ceNode = $ceNode->successor) {
		push @namesForward, $ceNode->name;
	}
	return \@namesForward;
};

sub print_stations_reverse {
	my $self = shift;
	my @namesReverse = ();
	@namesReverse = ();
	my $ceNode = $self->fin; unshift @namesReverse, $ceNode->name;
	while ($ceNode = $ceNode->predecessor) {
		unshift @namesReverse, $ceNode->name;
	}
	return \@namesReverse;
};

sub singleStep {
	my $self = shift;

	return unless $self->has_nodes;

	my $ultimateNode = $self->fin->predecessor;
	$ultimateNode->step;
};

sub report_WIP {
	my $self = shift;
	my @wip = $self->map_nodes( sub { $_->WIP; }  );
	push @wip, $self->fin->WIP;
	return \@wip;
};

sub report_lastRoll {
	my $self = shift;
	my @roll = $self->map_nodes( sub { $_->last_roll; }  );
	unshift @roll, $self->start->last_roll;
	return \@roll;
};

sub generate_labels {
	my $self = shift;
	
	my @processLabels = (); my @stationLabels = ();

	@processLabels = qw/IN OUT WIP/;
	@stationLabels = $self->map_nodes( sub { ($_->name . "_Processed", $_->name . "_WIP");} );
	@processLabels = (@processLabels, @stationLabels);
	#print join ',', @processLabels;
	
	return \@processLabels;
};

sub report_step {
	my $self = shift;

	my @processReport = ();
	my @elements = ();
	my $in; my $out; my $wip;

	@processReport = $self->map_nodes(	sub	{	$_->last_roll,	$_->WIP;	}	);
	$in 		= $self->start->last_roll;
	$out 		= $self->fin->predecessor->last_roll;
	@elements	= $self->map_nodes(	sub { $_->WIP	}	);
	$wip 		= summa(\@elements);
	unshift @processReport, ($in, $out, $wip);
	#print join ',', @processReport;
	
	return \@processReport;
};

sub summa {
	my $ceArray = shift;
	my @ceArray = @{$ceArray};
	my $sum = 0;
	
	foreach my $ceElement (@ceArray) {
		$sum += $ceElement;
	};
	
	return $sum;
};

package Simulation_Console;
use Moose;

has 'process' 		=> (
		is			=>	'rw', 
		isa 		=>	'Process',
		predicate	=>	'has_process',
		clearer		=>	'clear_process',
		required	=>	1,
		default		=>	sub {	Process->new;	},
);

has 'number_iterations'	=>	(
		is			=>	'rw', 
		isa 		=>	'Int',
		predicate	=>	'has_numberIterations',
		clearer		=>	'clear_numberIterations',
		required	=>	1,
		default		=>	200,
);

has 'report'	=>	(
		is			=>	'rw', 
		isa 		=>	'Str',
		predicate	=>	'has_report',
		clearer		=>	'clear_report',
		required	=>	1,
		default		=>	'report1.txt',
);

sub run {
	my $self = shift;
	
	my $process = 	$self->process;
	my $outfile = 	$self->report;
	my $count 	= 	$self->number_iterations;
	
	open(REPORT, ">$outfile");

	my @labels = (); my @report = ();
	return unless $process->has_nodes;
	@labels = @{	$process->generate_labels	};
	print REPORT join '|', @labels;
	for (my $c = $count; $c >= 1; $c--) {
		$process->singleStep;
		@report = @{	$process->report_step	};
		print REPORT join '|', @report;
	};

	close(REPORT);
};

1;
