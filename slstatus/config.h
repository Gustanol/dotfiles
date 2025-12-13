/* See LICENSE file for copyright and license details. */

/* interval between updates (in ms) */
const unsigned int interval = 4000;

/* text to show if no value can be retrieved */
static const char unknown_str[] = "?";

/* maximum output string length */
#define MAXLEN 2048

static const struct arg args[] = {
    //{run_command, " 📦 %s", "checkupdates 2>/dev/null | wc -l"},
    {run_command, "  %s",
     "pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}'"},
    {run_command, " |  %s°C",
     "cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input | cut "
     "-c1-2"},
    {ram_used, " |  %s", NULL},
    {cpu_perc, " | 󰘚 %s%%", NULL},
    {datetime, " | %s", "%H:%M "},
};
