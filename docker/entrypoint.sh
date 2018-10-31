#!/bin/sh
echo "🐋  Starting ..."

browser=$BROWSER

echo "BROWSER"$browser

if [ "$browser" == "chrome" ]
then
  echo "🦄 You are using Google Chrome"
  $(npm bin)/cypress run --reporter mochawesome --browser chrome
else
  echo "⚡️ You are using Electron"
  $(npm bin)/cypress run --reporter mochawesome
fi
