use Process;
#use Node;
use strict;
local $, = "\t", $\ = "\n";

my @simulationRuns = ();

push @simulationRuns, q{useCase_Baseline.pl};
push @simulationRuns, q{useCase_One.pl};
push @simulationRuns, q{useCase_Two.pl};
push @simulationRuns, q{useCase_Three.pl};
push @simulationRuns, q{useCase_Four.pl};

foreach my $ceRun (@simulationRuns) {
	print "Runing $ceRun ..";
	system(qq{perl $ceRun});
	print ".. Done!";
};