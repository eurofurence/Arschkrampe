# Eurofurence Signage Toolchain
This toolchain has been used in the Estrel Hotel to automatically build display slides based on predefined scripts.

## Usage
Use ./generate.sh \<script\> to build a single slide based on the script, or ./generateAll.sh to build everything. 

## Requirements
imagemagick

## Starting with a new convention
If you are moving to a new year, you should first edit the ./generate.sh and replace the "BACKGROUND_LANDSCAPE" and "BACKGROUND_PORTRAIT".
Those two files are the basis for all slides. To help you to get started, you also find the Photoshop files in the main folder.

After that, you should get into /scripts and start editing. I recommend that you start with the test_ files, as those contain nearly
every case that we might encounter. You can build those by running "./generate.sh script test_landscape.txt" for example.

After the file has been written, you can inspect your result in /output

## Folders
- icons - They contain the icons that are normally shown on the slides. Most of them have been build by DB9JU as seen in icon_template.psd. The exception is the wheelchair icon, which is public domain.
- output - contains the built slides
- scripts - contains all the scripts that define the slides
- templates - does not really belong here, but they were used by the Estrel to built their own announcements, if they needed to, as also other people to have a unified representation.
