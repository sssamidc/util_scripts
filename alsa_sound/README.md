# ALSA Sound check

This are the scripts used for resolution of asla sound which is arising on 
20.04 zettaone compute boards

Place all `*.service` files in `/etc/systemd/system/`

Place all `*.sh` files in `/home/ati/`

Place `beep.wav` file in `$HOME` dir

Run the following after above 

```
sudo systemctl enable ati_snd_init
sudo systemctl daemon-reload
sudo systemctl start ati_snd_init
```

Give the system a reboot check if the beep is up and running.

## What is doing all the above don't give a bee indication?

OK, Just manualy run the `ati_snd_init.sh` 

Run : `aplay ~/beep.wav` and you should be able to get the sound

>Note : The `ati_snd_init` might show error while you check status of it thats fine

