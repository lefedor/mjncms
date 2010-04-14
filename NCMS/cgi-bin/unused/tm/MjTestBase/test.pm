package MjTestBase::test;

MjTestBase::get '/some' => sub {
	my $self = shift;
	$self->render(text => 'Take some');
};

MjTestBase::get '/someelse' => sub {
	my $self = shift;
	$self->render('helloroot');
};
