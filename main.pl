use Process;
#use Node;
use strict;
use Test::More tests=>50;
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
my $simulator = Simulation_Console->new;
isa_ok($simulator, 'Simulation_Console');
isa_ok($simulator->process, 'Process');
ok(!$simulator->process->has_nodes,	q{Process not populated by default});
$simulator->process($process);
ok($simulator->process->has_nodes,	q{Process populated});

$simulator->process->map_nodes(	sub	{ $_->min_max->min(1); $_->min_max->max(6); }	);
$simulator->run;

#=Process
# Process #
my $process = Process->new;
isa_ok($process, 'Process');
ok($process->has_START,	q{Has START node.});
ok($process->has_FIN,	q{Has FIN node.});
isa_ok($process->start,	'Node');
isa_ok($process->start,	'START');
isa_ok($process->fin, 	'Node');
isa_ok($process->fin,	'FIN');
ok(!$process->has_nodes, q{No nodes at start.});

my $node_1 = Node->new(name => 'mail room',	WIP => 3);
my $node_2 = Node->new(name => 'PFR check',	WIP => 3);
my $node_3 = Node->new(name => 'Analyst',	WIP => 3);
my $node_4 = Node->new(name => 'Pay',		WIP => 3);

$process->add_nodes($node_1);
$process->add_nodes($node_2);
$process->add_nodes($node_3);
$process->add_nodes($node_4);
my $stationsList = join('|', @{ 	$process->print_stations});
ok($stationsList =~ /mail room/i,
			q{Has station: mail room});
ok($stationsList =~ /PFR Check/i,
			q{Has station: PFR Check});
ok($stationsList =~ /Analyst/i,
			q{Has station: Analyst});
ok($stationsList =~ /Pay/i,
			q{Has station: Pay});
$process->singleStep;
$process->map_nodes( sub { $_->min_max->min(3); $_->min_max->max(4); } );
my @minDice = $process->map_nodes(	sub { $_->min_max->min . '|' . $_->min_max->max;}	);
my $minMax = join '|', @minDice;
ok($minMax =~ /3|4/,
			q{Min and Max reset to 3|4});
$process->map_nodes( sub { $_->min_max->min(1); $_->min_max->max(6); } );

open (WIP, '>WIP.txt');

my @labels = (); my @report = ();
@labels = @{	$process->generate_labels	};
print REPORT  join '|', @labels;
for (my $count = 200; $count >= 1; $count--) {
	$process->singleStep;
	@report = @{	$process->report_step	};
	print REPORT  join '|', @report;
};

close(REPORT);

#=cut

#=Node
# Node #
my $genericNode = Node->new(name => 'generic');
isa_ok($genericNode, 'Node');
is($genericNode->name, 'generic', 
			q{Name set to generic.});
isa_ok($genericNode->min_max, 'MinMax');
is($genericNode->min_max->min, '1',
			q{Min is set  to 1});
is($genericNode->min_max->max, '6',
			q{Max is set  to 6});
ok($genericNode->roll_dice,
			q{Generic node rolled } . $genericNode->roll_dice);
$genericNode->min_max->min(4);
$genericNode->min_max->max(5);
is($genericNode->min_max->min, '4',
			q{Min is set  to 4});
is($genericNode->min_max->max, '5',
			q{Max is set  to 5});
my @diceRolls = ();
foreach(my $count = 9; $count > 0; $count--) {
	push @diceRolls, $genericNode->roll_dice;
};
my $diceRolls = join '|', @diceRolls;
ok($diceRolls =~ /4/, 
			q{Rolled 4 at least once});
ok($diceRolls =~ /5/, 
			q{Rolled 5 at least once});
is($genericNode->WIP, 0, 
			q{Default WIP is 0});
$genericNode->WIP(30);
is($genericNode->WIP, 30, 
			q{WIP set to 30});			
$genericNode->min_max->min(4);
$genericNode->min_max->max(4);
is($genericNode->WIP, 30,
			q{Starting WIP of 30});
$genericNode->step;
is($genericNode->WIP, 26,
			q{WIP depleted by } . $genericNode->last_roll . q{ now 26});
$genericNode->step;
is($genericNode->WIP, 22,
			q{WIP depleted by } . $genericNode->last_roll . q{ now 22});
$genericNode->step;
is($genericNode->WIP, 18,
			q{WIP depleted by } . $genericNode->last_roll . q{ now 18});

my $startNode = START->new;
isa_ok($startNode, 'Node');
isa_ok($startNode, 'START');
is($startNode->name, 'START', 
			q{Name set to START.});
$startNode->predecessor($genericNode);			
ok(!$startNode->has_predecessor,  
			q{No predecessor});
is($startNode->min_max->min, '1',
			q{Min is set  to 1});
is($startNode->min_max->max, '6',
			q{Max is set  to 6});
ok($startNode->roll_dice,
			q{START rolled dice} );
$startNode->WIP(2);
ok(!$startNode->WIP, 
			q{Customer carries no inventory ever!});
$startNode->step;
ok($startNode->last_roll,
			q{Customer pushed jobs in queue: } . $startNode->last_roll);
$startNode->min_max->min(6);
$startNode->min_max->max(6);
$startNode->step;
is($startNode->last_roll, '6',
			q{Customer pushed 6 jobs in queue: });

my $endNode = FIN->new;
isa_ok($endNode, 'Node');
isa_ok($endNode, 'FIN');
is($endNode->name, 'FIN', 
			q{Name set to FIN.});
$endNode->successor($genericNode);			
ok(!$endNode->has_successor,  
			q{No successor.});
#=cut

#=MinMax		
my $minMax = MinMax->new;
isa_ok($minMax, 'MinMax');
is($minMax->min, '1', 
			q{Minimum set to 1.});
is($minMax->max, '6', 
			q{Maximum set to 6.});
#=cut