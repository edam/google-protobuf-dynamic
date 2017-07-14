use t::lib::GrpcClient;

spawn_server('t/grpc/sayhello_stream_server.pl');

my $d = Google::ProtocolBuffers::Dynamic->new('t/proto');
$d->load_file("grpc/service.proto");
$d->map(
    { package => 'helloworld', prefix => 'Helloworld' },
);

my $credentials = Grpc::XS::ChannelCredentials::createInsecure;
my $greeter = Helloworld::Greeter->new(
    server_address,
    credentials => $credentials,
);
my $request = Helloworld::HelloRequest->new({
    name => 'grpc-perl',
});
my $call = $greeter->SplitHello( argument => $request );
my @responses = $call->responses;

is(scalar @responses, 10);
is(join('', map $_->get_message, @responses), 'Hello, grpc-perl');

done_testing();
