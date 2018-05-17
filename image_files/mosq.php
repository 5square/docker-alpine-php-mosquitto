<?php

$c = new Mosquitto\Client;
$c->onConnect(function() use ($c) {
    $c->publish('mgdm/test', 'Hello', 0);
    $c->disconnect();
});

$c->connect('mosquitto');
$c->loopForever();

echo "Finished\n";