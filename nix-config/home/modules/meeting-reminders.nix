{ pkgs, ... }:

let
  makeReminder = { name, time, minutesBefore }: {
    systemd.user.services."meeting-reminder-${name}" = {
      Unit.Description = "Meeting reminder ${toString minutesBefore} min before";
      Service.ExecStart = "${pkgs.bash}/bin/bash /home/krieg/mysystem/scripts/meeting-reminder.sh ${toString minutesBefore}";
    };
    systemd.user.timers."meeting-reminder-${name}" = {
      Unit.Description = "Meeting reminder ${name} timer";
      Timer = { OnCalendar = "Sat *-*-* ${time}:00"; Persistent = true; };
      Install.WantedBy = [ "timers.target" ];
    };
  };
in
{
  imports = [
    (makeReminder { name = "30"; time = "14:30"; minutesBefore = 30; })
    (makeReminder { name = "25"; time = "14:35"; minutesBefore = 25; })
    (makeReminder { name = "15"; time = "14:45"; minutesBefore = 15; })
    (makeReminder { name = "5";  time = "14:55"; minutesBefore = 5;  })
  ];
}
