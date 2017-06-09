Silence Between Songs
=======

MediaMonkey Script: Adds a configurable length of silence between songs. 

Note: The functionality of this script is now built-in to the Cortina plug-in. Development and support for this plug-in has been discontinued. Please use the Cortina plug-in instead.

Installation:

* MediMonkey must be installed on your system before proceeding.
* Download silencebetweensongs.mmip and double-click the file, this will launch MediaMonkey and start the script installation process.
* Some versions of Windows will require entering an administration account name and passowrd to proceed.
* Restart MediaMonkey.

Updating:

* From the 'Tools' menu, click the 'Extensions' menu item.
* Click the 'Find Updates' button at the bottom of the dialog box.
* If an update is available, click on 'Silence Between Songs' in the list of extensions, then click the 'Install Update' button.
* Some versions of Windows will require entering an administration account name and passowrd to proceed.
* Restart MediaMonkey.

Uninstall:

* From the 'Tools' menu, click the 'Extensions' menu item.
* Click on 'Silence Between Songs' in the list of extensions.
* Click the 'Uninstall' button.
* Click the 'OK' button on the confirmation prompt.
* Select either the 'Yes' or 'No' option on the prompt asking if you wish to delete registry settings created by the script.
* Click 'OK' on the uninstall information prompt.
* Restart MediaMonkey.

Build Notes:

* To build the MediaMonkey Installation Package, compress all files, except for silencebetweensongs.xml, with any Zip compressor utility. 
* Rename the resulting zip file to 'silencebetweensongs.mmip' (mmip = MediaMonkey Installer Package).
* Double-clicking on 'silencebetweensongs.mmip' will automatically start the MediaMonkey installation process.

Configuring:

* Click the 'Play' menu in MediaMonkey.
* Click the 'Silence between songs' sub-menu item.
  * Checkmark the 'Enable' checkbox to add silence between songs.
  * Set the length of silence.
  * To skip adding silence after some songs:
    * Checkmark the 'Exclude gapless tracks' checkbox.
    * Select which Custom Tag of each song to look for gapless track info.
    * Enter what text to look for in the selected Custom Tag. The default is '[Gapless]'.
    * Right-click any song that you do not want silence after, and select 'Properties' from the pop-up menu.
    * Click the 'Classification' tab and enter the gapless indicator text into the Custom Tag you configured. The default is '[Gapless]'. 

* For a uniform length of silence between each song follow this procedure:
  * From the 'Tools' menu, click the 'Options' menu item.
  * Click on 'Output Plug-ins' in the list of options.
  * Click on the currently enabled output plug-in in the list of 'Available Output Plug-ins:'
  * Checkmark the "Remove silence at the beginning / end of track" checkbox in your output plug-in.
  * Note that some output plug-ins, like waveOut, do not have this option. Use an output plug-in that does have this option, such as MediaMonkey DirectSound output.
