use Process;
#use Node;
use strict;
local $, = "\t", $\ = "\n";
# SIMULATION #

#	1.	# Process Template
my $process = Process->new;

#	2.	# Set up nodes
my $node_1 = Node->new(name => 'mail room',	WIP => 3);
my $node_2 = Node->new(name => 'PFR check',	WIP => 3);
my $node_3 = Node->new(name => 'Analyst',	WIP => 3);
my $node_4 = Node->new(name => 'Pay',		WIP => 3);

#	3.	# Insert nodes in process
$process->add_nodes($node_1);
$process->add_nodes($node_2);
$process->add_nodes($node_3);
$process->add_nodes($node_4);

#	4.	# Set-up Simulation
#		#	Simulate: Variability at Station 4
$process->map_nodes( sub { $_->min_max->min(1); $_->min_max->max(6); } );
#		# Round-Robin
$process->get_node(1)->min_max->min(4);
$process->get_node(1)->min_max->max(4); 

open(REPORT, '>useCase_One.txt');

#	5.	# Run Simulation
my @labels = (); my @report = ();
@labels = @{	$process->generate_labels	};
print REPORT join '|', @labels;
for (my $count = 200; $count >= 1; $count--) {
	$process->singleStep;
	@report = @{	$process->report_step	};
	print REPORT join '|', @report;
};

close(REPORT);