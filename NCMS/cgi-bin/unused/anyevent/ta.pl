use AnyEvent;

   # wait till the result is ready
   my $result_ready = AnyEvent->condvar;

   # do something such as adding a timer
   # or socket watcher the calls $result_ready->send
   # when the "result" is ready.
   # in this case, we simply use a timer:
   my $w = AnyEvent->timer (
      after => 1,
      cb    => sub { $result_ready->send },
   );

   # this "blocks" (while handling events) till the callback
   # calls ->send
   print '1'."\n";
   $result_ready->recv;
   print '2'."\n";
