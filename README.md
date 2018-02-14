# [EzPi4ME - Getting rid of Intel ME, for mere mortals](http://www.tnhh.net/posts/ezpi4me-intel-me-be-gone.html)

_The easiest, and most straightforward method to get rid of the Intel ME._

This project helps you create a Raspberry Pi image that can clean the 
Intel ME blob from your machine. In other words, "me-cleaner for dummies."

What is the Intel Management Engine/Intel ME?
--

It's a binary blob on your firmware in the flash chip. It's a software that runs
independently of the main CPU on a co-processor all the times (even when the machine is off)
and before anything on your machine with the highest ring permission. It can access
anything on your computer. It does a lot of (good?) things, but no one knows exactly 
what the Intel ME is capable of.

[It is a modified version of MINIX](http://www.cs.vu.nl/~ast/intel/).
[One good overview is here](https://hackaday.com/2017/12/11/what-you-need-to-know-about-the-intel-management-engine/).


What exactly does this process do to eliminate the Intel ME?
--

The ME firmware is very big, so the code doesn't reside on the Intel CPU hardware. The firmware has to be fed to the Intel CPU from somewhere. That somewhere is, in practice, a region of the flash chip of the computer. The ME firmware takes something like 512K-3MB in that 8MB chip. There is a hardware watchdog on the Intel CPU that checks if the operation of the ME firmware after the computer is on for half an hour. If it realizes that the ME is not operational at all, it will reset the machine. When the firmware runs, it sets certain (hidden/privileged) registers or memory values to the correct values signaling to the watchdog that it's operational, and thus makes the hardware watchdog happy.

The problem is you can't just feed the CPU a totally bogus ME code. Before the CPU runs the code, it will check certain signatures and if the signature doesn't match, the CPU won't run it. The me-cleaner software changes the firmware in an extremely clever way: the botched code still passes some minimum security requirements, the CPU still executes it, and it still flags the ME as somewhat operational, and thus the watchdog is still happy.

Now the layout of the firmware has also one more tidbit. On the firmware, you can mark a certain region of the chip to be extremely critical, to prevent that region from ever be written on. In the factory firmware, the ME region is often marked as extremely critical, that's why you can't just change the ME firmware from the machine itself (even when you can update and flash a new firmware from the machine itself).

In short, an analogy of that that is like you can't install and run the anti-virus from an infected computer - if the virus itself is smart enough, it could prevent any anti-virus being run. You'd have to start with a clean computer, and plug the infected HDD in, and clean it from there. The Raspberry Pi is acting as the "clean" computer to clean the virus here.


Why did I do this? 
--

Freedom from binary blobs shouldn't be hard or expensive.

This is after a person told me, "you need to make it easy for us mere mortals."

One doesn't need to be an electrical engineer to do be able to clean 
the ME on your computer. Just run some simple commands and connect 6 wires to 
a Raspberry Pi.

I've been thinking about this project for over a year, but prototyping was easy 
because I can just carry a customized Pi image with me. Now, to release
to the public the source and customization process, there is a lot of scripting
needed (because what's the point of advocating removing the 8MB Intel ME blob 
by releasing a 2GB blob and tell everyone to run it). I finally got up my butt 
and did it. Every script is extremely simple and can be audited quickly.


Tested platforms
--

This pipeline has been tested to work on a Dell Chromebook 7310. That's all I have.

It should work with many other Chromebooks and Thinkpads, but have not been 
verified. If you succeeded cleaning your ME with this method, please send me 
an email.


Beware
--

**Remember, that ultimately you're responsible for trying this with your machine.**
I can't guarrantee that it will work. I can't guarrantee that what I told you to do 
won't fry your $4000 laptop. I wrote it the whole thing in ten hours. 

That being said, I have put every safeguard I could think of and made this process
as simple and clear as possible. As long as you don't fry your chip by connecting
a 1.8V chip to the 3.3V Raspberry Pi, the process is entirely undoable.


Instructions
--

You will need hardware-wise: a Raspberry Pi (Pi 0 WH is the easiest and cheap),
a Ponoma SOIC-8 clip and 6 female2female jumper wires, and a microUSB cable.
You'll also need a microSD card >= 2GB. If you really want to be cheap, buy a 
Pi 0 original for $5 in Microcenter, but then you'll have to solder the headers.

The Bill of Materials should about less than $50 in total. More likely than not
you already have everything here, except for the SOIC-8 clip.

![Raspberry Pi 0 WH](https://i.imgur.com/OcKklYys.jpg)
![Female2Female](https://i.imgur.com/SOQtFips.jpg)
![SOIC clip](https://i.imgur.com/ovZ6Ao0s.jpg)
![MicroSD](https://i.imgur.com/qwgiGlJs.jpg)

Have the "target" computer to clean. Open it up, make sure that it has a SOIC-8
flash chip. **MAKE VERY SURE** the chip is 3.3V or 3.3V-tolerant. Many 
Chromebooks use 3.3V chips, but it looks like some use 1.8V chips.

If you use the Pi 0, you'll need a "spare" computer that can be used to control it,
alternatively you can attach a set of keyboard/HDMI cables/monitor to type to the
Raspberry Pi. 

The spare computer can run Linux or Windows, doesn't matter. 
I'm not sure about Macs, you'll need to install drivers on Mac to get it to talk
to the Pi via USB-serial. Easier just to boot your Mac with a live Linux distro.

Prepare the image
--

Now you can run the script in this repo in any Linux distro to 
create a ezpi4me image. Some of live distros are alright. Don't use Windows.

If you want to also flash coreboot at the same time you clean the ME, you need 
to put the ROM file you prepared to the folder `coreboot` 
and name it `coreboot.bin`. It will be copied to `/home/pi/coreboot.rom`.

Fedora:

    $ sudo dnf install qemu-user-static kpartx parted 
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

All Chromebooks and Thinkpads I'm aware of so far has the same wiring
scheme:

	              ┌───── Little "dot" on the chip
	              │ 
	             ╔═════════╗
	    CS#    1═╣o        ╠═8    VCC
	   MISO    2═╣         ╠═7    ---
	    ---    3═╣         ╠═6    SCLK
	    GND    4═╣         ╠═5    MOSI
	             ╚═════════╝

    RPi header  SPI flash
    25          GND
    24          CS#
    25          SCK
    21          MISO/DO
    19          MOSI/DI
    17          VCC 

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

**Note: The first boot is slow. It might take 10-15 minutes before the login 
prompt shows up. It won't have debug text. Be patient.**

- Alternatively, you can use a USB-OTG cable, a mini-HDMI to HDMI adapter, 
a USB keyboard, to connect to the Pi Zero directly. You'll need to type on it.

Later versions of ezpi4me might do everything automatically for you without 
requiring you to type, but I'd rather have you see and control the process now.


Connect the chip on the "target" to the SOIC clip. Make sure leg #1 matches :)

![Connect](https://i.imgur.com/a9rcEy6.jpg)

Log in with username pi, and password raspberry.
Anyway, now you're at the command line. ezpi4me has the following utilities.

Run them in this order:

    $ sudo ezpi4me-check-chip  <-- checks if you see the chip
    $ sudo ezpi4me-rom-backup  <-- backs up the current ROM from the chip
    $ sudo ezpi4me-rom-clean   <-- cleans the ME from the ROM
    $ sudo ezpi4me-rom-reflash <-- flashes it back to the chip

After you ran those commands, the "target" computer will be free of Intel ME.

![Command line](https://i.imgur.com/fATqixY.png)


Chromebooks specifics
--

Chromebooks have UEFI builds by MrChromebox at http://MrChromebox.tech

After you have flashed his firmware, you won't be able to boot stock 
ChromeOS anymore, but Linux and Windows (and possibly macOS, in the 
future) will run.

There are several ways to do it. You can either do the long-way: Follow his 
intructions to have the UEFI firmware installed (do the write protection 
screw thing), then run ezpi4me route: do the backup-clean-reflash.

You can take the shortcut: Go to

    https://github.com/MattDevo/scripts/blob/master/sources.sh

then look for your `full-rom URL=fullrom_source+coreboot_uefi_yourdev`
For example, for Dell Chromebook 13 (lulu) it is:

    https://www.mrchromebox.tech/files/firmware/full_rom/coreboot_tiano-lulu-mrchromebox_20180204.rom

Download that file, rename it to `coreboot.bin`.
Put it in the `coreboot` folder in ezpi4me, run the `make-ezpi4me.sh` script
Then boot the pi, do the backup-clean-reflash routine. 

FAQs
--

- **Why can't I just flash the cleaned UEFI firmware directly 
on the same laptop?**

The region of the Intel ME is protected, it does not allow anything
to write over itself on the same computer. You have to have an external
programmer.

- **Why does anyone want to neuter the Intel ME?** 

It often a matter of principles. 

Why does anyone run GNU/Linux instead of Windows 10?

- **Do I have to use coreboot?**

No. Even if you use your computer's default firmware, it should work.

In the case of Chromebook it will just mean that you'll run ChromeOS 
without Intel ME. 

You can't check it without root/developer access and a chroot.

- **How do I know my computer is free of Intel ME after I've done this?**

On Linux:
Clone the coreboot repository, then compile the `intelmetool` and run it.

On Windows: You don't see the Intel ME controller in Device Manager no more.

![intelmetool](https://i.imgur.com/KN0yyKt.png)

- **Where is the flash chip?**

It often has 8 legs, but you'll have to search online to see where exactly the
chip is located on your machine model.

If it helps, mine looks like this.

![chip](https://i.imgur.com/MVtMyXv.jpg)

- **How do I know my chip is 3.3V?**

Look at the markings of the chip, then Google chip_name + datasheet.
If you have a Winbond W25Q64.V chip, it is sure to be 3.3V tolerant.

- **Do I have to locate and unfasten the write-protect screw?** 

No. The Pi talks to the chip directly, it doesn't care if the 
write-protect screw is fastened or not.

- **Should I leave the write-protect screw unfastened?**

It's your choice. However, if you leave it unfastened, anything that has 
root access can write over your UEFI firmware. I leave it fastened.  

- **Do I need to disconnect the laptop battery when I flash the firmware?**

You really should. But sometimes I forgot to do it and it didn't hurt the
machine.

- **How do I know what's the pin 1 on the SOIC clip?**

It doesn't matter, you select any corner and mark it. Then it's your pin 1.

- **I saw the black SOIC clips on sale on eBay/Aliexpress for much cheaper.
Should I buy one?**

Be mindful of the pitch of the clip legs. Some are not 0.1 inch and it will be 
a pain to deal with. The Panoma (blue) one works and works well.

- **What do I do if I have a 1.8V chip?**

I don't know. Use a level shifter. I might be able to get a circuit board working
in the future... That's in the TODO. But you'd have to have additional hardware.




Thanks
--

- Code & knowledge: me-cleaner, Coreboot, John Lewis, /r/chrultrabook.

- My personal thanks to Dr. Don Bindner, bunnie, vnhacker 
for advice and support.


Have fun!
--

Have questions? Create an issue on Github.

Comments? [Go to my blog](http://www.tnhh.net/posts/ezpi4me-intel-me-be-gone.html).

Donations are welcome but not required. Paypal to htruong@tnhh.net.


