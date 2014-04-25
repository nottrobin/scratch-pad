use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'testsite' }
BEGIN { use_ok 'testsite::Controller::Library::Login' }

ok( request('/library/login')->is_success, 'Request should succeed' );


