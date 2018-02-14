# ezpi4ME - Getting rid of Intel ME, for mere morals


This script creates a Raspberry 0 image that can run mecleaner automatically.
Everything else you need is a Ponoma SOIC-8 clip and a 6 female jumper wires. 

This pipeline has been tested to work on a Dell Chromebook 7310. 
It should work with many other Chromebooks and Thinkpads, but have not been 
verified. If you succeeded cleaning your ME with this method, please send me 
an email.


Why did I do this? 
--

Because one doesn't need to be an electrical engineer to do be able to clean 
the ME on your computer with me_cleaner. Just run some simple commands and 
connect 6 wires on a Raspberry Pi.

As a hacker said, "you need to make it easy for us mere morals, man."

Instructions
--

Have the "target" computer to clean. Open it up, make sure that it has a SOIC-8
flash chip. **MAKE VERY SURE** the chip is 3.3V or 3.3V-tolerant. Many 
Chromebooks use 3.3V chips.

You'll also need a Raspberry Pi 0 WH (if you don't want to solder headers), 
a Panoma SOIC 8 clip, and 6 female-to-female jumper wires, and a microSD card.

You'll need a "spare" computer that can be used to control the Raspberry Pi, or
alternatively you can have a set of keyboard/HDMI cables/monitor to type to the
Raspberry Pi. The spare computer can run Linux or Windows, doesn't matter. 
I'm not sure about Macs, you'll need to install drivers on Mac to get it to talk
to the Pi via USB-serial. Easier just to boot your Mac with a live Linux distro.

Prepare the image
--

Now you can run this script in this repo in any Linux distro to 
create a ezpi4me image. Some of live distros are alright. Don't use Windows.

If you want to also flash coreboot at the same time you clean the ME, you need 
to put the ROM file you prepared to the folder `coreboot` 
and name it `coreboot.bin`. It will be copied to `/home/pi/coreboot.rom`.

Fedora:

    $ dnf install qemu-user-static kpartx parted 
    $ sudo systemctl restart systemd-binfmt.service
    $ sudo ./make-ezpi4me.sh
    
Debian/Ubuntu:

    $ sudo apt install qemu-user-static kpartx parted 
    $ sudo ./make-ezpi4me.sh
    
Write the image, should be named `ezpi4me.img` to the micro-SD card. 

    $ sudo dd if=ezpi4me.img of=/dev/Your_MicroSD_card

Wirings and flash the hardware
--

Wire the SOIC clip to the Pi according to this guide: 
https://www.flashrom.org/RaspberryPi

If you're confused, I have a video here: 
https://www.youtube.com/watch?v=YnUPf3e0ZFM

You do not need to wire pin 3 and pin 7 on the clip.

Now, you have two ways to proceed:

- Easiest: You need another linux/windows computer. Plug the micro-USB to the 
Pi 0 using the USB OTG port on the Pi 0 (NOT PWR) -- that's the middle, not the 
outermost micro-USB port. Now install `screen` (Linux) or Putty (Win). On Linux:

        $ sudo screen /dev/ttyUSB0 115200
        or
        $ sudo screen /dev/ttyACM0 115200
    
On Windows, use Putty to create a new connection to connect to whatever COM port
that shows up in Device Manager.

Press Enter a couple of times so it shows the login prompt after you connect.

- Alternatively, you can use a USB-OTG cable, a mini-HDMI to HDMI adapter, 
a USB keyboard, to connect to the Pi Zero directly. You'll need to type on it.



Later versions of ezpi4me might do everything automatically for you without 
requiring you to type, but this is process is too dangerous and error-prone 
to have it automated now.


Connect the chip on the "target" to the SOIC clip. Make sure leg #1 matches :)


Log in with username pi, and password raspberry.
Anyway, now you're at the command line. ezpi4me has the following utilities.

Run them in this order:

    $ sudo ezpi4me-check-chip  <-- checks if you see the chip
    $ sudo ezpi4me-rom-backup  <-- backs up the current ROM from the chip
    $ sudo ezpi4me-rom-clean   <-- cleans the ME from the ROM
    $ sudo ezpi4me-rom-reflash <-- flashes it back to the chip

After you ran those commands, the "target" computer will be free of Intel ME.


Have questions? Get answers: htruong@tnhh.net.

Donations are welcome but not required. Paypal to the same email address.


