#! /usr/bin/perl

$FH = "../../../taxonomy/ncbi/tmp/plant/hier_genus";
$FP = "../../../taxonomy/mytree/tmp/myplant_utf8";
$FRE = "../../../taxonomy/mytree/data/mytree_synonym.txt";
$FD = "../DL/33488385_supp.txt";
$F_POSI = "../table/mesh_antim";

open(FRE, $FRE) or die "ERROR $FREP\n";
while(<FRE>){
    chomp;
    s/\r//g;
    ($name, $syno) = split(/\t/);
    next if $syno eq "";
    $repname{$syno} = $name;
}

#open(FP, $FP) or die "ERROR $FP\n";
#while(<FP>){
#    chomp;
#    s/\r//g;
#    ($id, $eolid, $taxid, $genus, $famid,
#     $ordid, $sname) = split(/\t/);
#    next if $taxid eq "";
#    $name2genus{$sname} = $genus;
    #	$taxid2name{$taxid} = $sname;
#}

open(FD, $FD) or die "ERROR $FD\n";
my $header = <FD>;
while(<FD>){
    chomp;
    s/\r//g;
    my ($spe, $gname, @tmp) = split(/\t/);
    $spe =~ s/\"//g;
    $spe = $repname{$spe} if $repname{$spe};
    $gname2 = "";
    if( $spe =~ /^([A-Z][a-z]+)/){ $gname2 = $1; }
    if( $gname ne "" ){
	$is_act{ $gname }++;
    }elsif( $gname2 ne "" ){
	$is_act{ $gname2 }++;
    }else{
	print STDERR "NO genus id for $gname\n";
    }
}

print "label\tname\n";
open(FH, $FH) or die "ERROR $FH\n";
while(<FH>){
    chomp;
    s/\r//g;
    my ($gname, $gid, @tmp) = split(/\t/);
    $label = 3;
    $label = 4 if $is_act{$gname};
    print join("\t", ("taxid" . $gid, $label, $gname)) . "\n";
}

open(FP, $F_POSI) or die "ERROR $F_POSI\n";
while(<FP>){
    chomp;
    ($ui, $label, $name) = split(/\t/);
    $ui =~ tr/[A-Z]/[a-z]/;
    print join("\t", ("mesh" . $ui, "1", $name)) . "\n";
}
