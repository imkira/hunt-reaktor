use List::Util 'reduce';
use LWP::Simple;
print reduce { $a * $b } map { substr('' + sqrt($_ * 3), 3, 1) } get('http://hunt.reaktor.com/magicnumber') =~ /[247]/mg
