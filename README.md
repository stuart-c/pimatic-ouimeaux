pimatic ouimeux plugin
======================

Plugin for the integration of [Ouimeux](http://ouimeaux.readthedocs.org/) to control WiFi switches.
The ouimeaux daemon must be running to use this plugin.

Configuration
-------------
You can load the backend by editing your `config.json` to include:

    {
       "plugin": "ouimeaux",
       "url": "<url>"
    }

in the `plugins` section. For all configuration options see
[ouimeaux-config-schema](ouimeaux-config-schema.html)

Devices are automatically added from ouimeaux, when the connection is established.
