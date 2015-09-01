#!/bin/bash

./ver.rb &
./mix1.rb &
./mix2.rb &

sleep 120

./end.rb
./count.rb