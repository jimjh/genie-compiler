# ~*~ encoding: utf-8 ~*~

gen = Pathname.new(__FILE__).dirname + '..' + '..' + '..' + 'gen'
$:.push gen
require gen + 'r_p_c'
