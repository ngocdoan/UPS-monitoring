# UPS-monitoring
Installing Network UPS Tools (NUT)

Cài NUT trên ubuntu
sudo apt-get install nut


Select your driver
Find the driver for your particular UPS by looking at the compatibility list on the NUT site (http://www.networkupstools.org/stable-hcl.html). If you can purchase a UPS that’s on the list, then that’s great. If you don’t find your UPS on the list, that doesn’t mean it won’t work, though. For instance, my UPS isn’t on the list, but a ton of other devices from the same company are, and they all seem to use the same driver (usbhid-ups). I gave it a shot, and it works just fine


Configure the UPS
sudo nano /etc/nut/ups.conf
[RPHS] /*RPHS là tên UPS*/
    driver = usbhid-ups
    port = auto
    desc = "CyberPower SX550G"
    
    
Configure the daemon
sudo nano /etc/nut/nut.conf
MODE=standalone

Configure the monitor
sudo nano /etc/nut/upsd.users
[admin]
    password = mypasswd
    actions = SET
    instcmds = ALL

[upsmon]
    password = mypasswd
    upsmon master
    
Next, edit the configuration file for the upsmon client program.
sudo nano /etc/nut/upsmon.conf
The keyword “MONITOR”. It does have to be all uppercase, by the way.
The “system” name in the format UpsName@HostName. I called my UPS “RPHS”, and since we’re running in standalone mode, we can just use “localhost” for the host name, so the resulting “system name” is “RPHS@localhost”.
The “power value”. This only applies to big servers with multiple redundant power supplies. Just set it to “1”.
The user name that you established in the upsd.users file (upsmon) .
The password that you established in the upsd.users file (mypasswd).
A value indicating whether this computer is the master or slave. You can read about the distinction in the upsmon.conf file itself, but for a standalone system like this, use “master”.
MONITOR RPHS@localhost 1 upsmon pass master
NOTIFYCMD /etc/nut/notifycmd
NOTIFYFLAG ONLINE       SYSLOG+WALL+EXEC
NOTIFYFLAG ONBATT       SYSLOG+WALL+EXEC

sudo nano /etc/nut/notifycmd
#!/bin/bash
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin
if [ "$NOTIFYTYPE" = "ONBATT" ]
then
ssmtp -vvv "youremail@gmail.com" -F "UPS Monitoring" < /home/user/UPSONBATT.txt
fi
if [ "$NOTIFYTYPE" = "ONLINE" ]
then
ssmtp -vvv "youremail@gmail.com" -F "UPS Monitoring" < /home/user/UPSONLINE.txt
fi
make it executable
sudo chown nut:nut /etc/nut/notifycmd
sudo chmod 700 /etc/nut/notifycmd

Next up, a little permissions wrangling. You need to set up the various configuration files to be readable by the NUT components that use them, but not by other users. This prevents anyone from reading the password, and sending unauthorized commands to the server to shut everything down. It may be overkill for a simple home network, but it’s also really simple to do.
sudo chown nut:nut /etc/nut/*
sudo chmod 640 /etc/nut/upsd.users /etc/nut/upsmon.conf

ssmtp email
sudo apt-get install ssmtp
Next, we’ll edit ssmtp’s configuration:
sudo nano /etc/ssmtp/ssmtp.conf
root=Tên tài khoản@gmail.com
mailhub=smtp.gmail.com:587
#rewriteDomain=domain local
#hostname=FQDN
UseTLS=Yes
UseSTARTTLS=Yes
AuthUser=Gmail_username
AuthPass=Gmail_password
FromLineOverride=YES

sudo nano /home/user/UPSONBATT.txt
From: UPS Monitoring youremail@gmail.com
Subject: Location Power Losses

UPS is running on battery, please check the power!

sudo nano /home/user/UPSONBATT.txt
From: UPS Monitoring youremail@gmail.com
Subject: Location Power Recover

UPS is online now!

Verify hardware configuration
To check whether the driver and daemon are configured correctly, you can simply start up the service.
/* Phải reboot máy trước mới check được bằng lệnh này
sudo upsdrvctl start
sudo service nut-server status
upsc rphs
sudo upscmd -l rphs
sudo service nut-server restart
sudo service nut-client restart
