{config, pkgs, ...}:
let 
  lockAction = "sleep 0.5;${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2 -f";
  
in
{
  programs.wlogout = {
    enable = true;
    layout = [
     {    label = "lock";    action = lockAction;    text = "Lock";    keybind = "l";  }
     {    label = "hibernate";    action = "${lockAction} ; systemctl hibernate";    text = "Hibernate";    keybind = "h";  }
     {    label = "logout";    action = "hyprctl dispatch exit";    text = "Logout";    keybind = "x";  }
     {    label = "shutdown";    action = "systemctl poweroff";    text = "Shutdown";    keybind = "s";  }
     {    label = "suspend";    action = "${lockAction} ; hyprctl dispatch dpms off";    text = "Screen Off";    keybind = "u";  }
     {    label = "reboot";    action = "systemctl reboot";    text = "Reboot";    keybind = "r";  }
    ];
    style = ''
* {
  background-image: none;
}
window {
    font-family: Fira Code Regular Nerd Font Complete Mono, monospace;
    font-size: 12pt;
color: #cad3f5; 
    background-color: rgba(30, 32, 48, 0);
}
/* window { */
/*   background-color: rgba(12, 12, 12, 0.6); */
/* } */
button {
  margin: 10px;
  color: #ffffff;
  background-color: rgba(75, 0, 130, 0.75);
  border-style: solid;
  border-width: 1px;
  border-radius: 25px;
  background-repeat: no-repeat;
  background-position: center;
  background-size: 20%;
  box-shadow: none;
  text-shadow: none;
  animation: gradient_f 20s ease-in infinite;
}
button:focus {
    background-color: @wb-act-bg;
    background-size: 15%;
}

button:hover {
    background-color: @wb-hvr-bg;
    background-size: 30%;
    border-radius: 10px;
    animation: gradient_f 20s ease-in infinite;
    transition: all 0.3s cubic-bezier(.55,0.0,.28,1.682);
}

button:hover#lock {
    border-radius: 10px;
    margin : 5px 0px 5px 6px;
}

button:hover#logout {
    border-radius: 10px;
    margin : 5px 0px 5px 0px;
}

button:hover#suspend {
    border-radius: 10px;
    margin : 5px 0px 5px 0px;
}

button:hover#shutdown {
    border-radius: 10px;
    margin : 5px 0px 5px 0px;
}

button:hover#hibernate {
    border-radius: 10px;
    margin : 5px 0px 5px 0px;
}

button:hover#reboot {
    border-radius: 10px;
    margin : 5px 6px 5px 0px;
}

button:focus,
button:active,
button:hover {
  background-color: #2c114f;
  outline-style: none;
}

#lock {
  background-image: image(
    url("${pkgs.wlogout}/share/wlogout/icons/lock.png")
  );
}

#logout {
  background-image: image(
    url("${pkgs.wlogout}/share/wlogout/icons/logout.png")
  );
}

#suspend {
  background-image: image(
    url("${pkgs.wlogout}/share/wlogout/icons/suspend.png")
  );
}

#hibernate {
  background-image: image(
    url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png")
  );
}

#shutdown {
  background-image: image(
    url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png")
  );
}

#reboot {
  background-image: image(
    url("${pkgs.wlogout}/share/wlogout/icons/reboot.png")
  );
}
'';
  };
}
