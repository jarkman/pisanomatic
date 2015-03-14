The Pisan-O-Matic is a device, built from bike parts and an Arduino, which plays musical sequences as it is pushed along.

![http://farm4.static.flickr.com/3532/3990499481_a4e147018c.jpg](http://farm4.static.flickr.com/3532/3990499481_a4e147018c.jpg)

It was built for Dorkbot Bristol (http://www.dorkbot.org/dorkbotbristol/), intially for the Staging Sound festival in Bath (http://www.dorkbot.org/dorkbotbristol/?p=159), and it was improved and expanded for 'May You Live in Interesting Times'(http://www.mayyouliveininterestingtimes.org.uk/makersfaire.html).

This project is derived from the GPS-A-Min:
http://jarkman.co.uk/catalog/robots/gpsamin.htm

And from Phill's work with Pisano sequences and music generation.

It's related to the World-O-Music project, too:
http://code.google.com/p/worldomusic/

Hardware for this is pretty simple:

One Arduino Duemilanove (the 328 version). Any other Arduino-compatible board that is at least as fast as the 328 should be fine.

Optical sensors (we used three) to detect lumps of foam on bike wheels. The Omron EESY313 worked for us:
http://uk.farnell.com/jsp/search/productdetail.jsp?SKU=1348973

One cheap MP3 amp/speaker.

The amp input is wired to pin 3 of the Arduino, the PWM output. The opto-sensors are wired to input pins on the Arduino as noted in the code.