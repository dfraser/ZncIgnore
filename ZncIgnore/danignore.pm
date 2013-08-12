# danignore.pm
# ZNC 0.62 perl module
# Dan Fraser <dfraser@capybara.org>
# enjoy!

package danignore;

# put your ignores, one per line, in ~/.znc/configs/danignore.conf
# remember you're matching against an irc nick!user@host style mask, such as doorbot!*user@*host.com
# reload the module to reload the ignore list.

my @ignores;
my $filehandle;

$filename = $ENV{"HOME"}."/.znc/configs/danignore.conf";
if (!open($filehandle, '<', $filename)) {
	ZNC::PutModule("Could not open $filename\n");
	return;
}

while(my $line = <$filehandle>){
	chomp $line;
 	$line =~ s/\#.*$//; # remove comments
 	$line =~ s/\s//; # remove whitespace
 	next if $line eq "";
 	ZNC::PutModule("Loaded ignore mask: ".$line);
	push(@ignores, $line);
}

ZNC::PutModule((scalar @ignores)." ignores loaded.");

sub description {
    "Dan's Ignore Module for ZNC"
}

sub new
{
	my ( $classname ) = @_;
	my $self = {};

	bless( $self, $classname );

	return( $self );
}
	
sub OnChanMsg {
	return checkIgnores(@_);
}

sub OnChanAction {
	return checkIgnores(@_);
}

sub OnChanNotice {
	return checkIgnores(@_);
}

sub checkIgnores {
    my $self = shift;
    my ($nick, $chan, $msg) = @_;
    foreach $ignore (@ignores) {
		if (ignore_match($nick,$ignore)) {
    		ZNC::PutModule("Hey, matched ".$nick." on ".$chan.": ".$msg);
			return ZNC::HALT;
		}
    }
    return $ZNC::CONTINUE;
}

sub ignore_match { 
    my ($mask, $expression) = @_;
    $expression =~ s/\*/\.\+/g;
    $expression = "^".$expression."\$";
    return $mask =~ /$expression/i;
}
1;
