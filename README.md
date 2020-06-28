```
     ,                                     
     Et           :                        
     E#t         t#,          .,          .
     E##t       ;##W.        ,Wt         ;W
     E#W#t     :#L:WE       i#D.        f#E
     E#tfL.   .KG  ,#D     f#f        .E#f 
     E#t      EE    ;#f  .D#i        iWW;  
  ,ffW#Dffj. f#.     t#i:KW,        L##Lffi
   ;LW#ELLLf.:#G     GK t#f        tLLG##L 
     E#t      ;#L   LW.  ;#G         ,W#i  
     E#t       t#f f#:    :KE.      j#E.   
     E#t        f#D#;      .DW:   .D#j     
     E#t         G#t         L#, ,WK,      
     E#t          t           jt EG.       
     ;#t                         ,         
      :;                                   
                                           
                                           
                                           
                                           
FOCS has been re-written in Python3, because it made more sense given how much I was starting to do.
There is a dotfile directory that has the original bash script that will eventually be moved to its
own branch, but I havne't done that yet because I am too lazy.

IMPORTANT NOTE: This version of FOCS only has been shown to work on Ubuntu 16.04. This is very
obnoxious, as it was previously working on Ubuntu 18 and 19 as well as Debian 10 and Slackware.

Something changed not only in the Linux kernel, but with QEMU itself that has caused issues; so
all features have been rolled back to Ubuntu 16.04 in which this program works as expected.

  vr0n
                                           
## Focs
This project is super experimental. Use at your own peril. 

### Getting Started
- clone the repo
``` 
- git --recurse-submodules [REPO]
```
- ./focs 

- Follow instructions to install

### Features in Progress
- [x] Menu mode (utilize cli to run focs)
- [ ] Finish dialog function in script (This should be similar to generic help/man)
- [ ] Script mode (run focs.sh) without menu
- [ ] Global install
- [ ] Adding new test cases (Stopping fuzzing in progress to update testcases)
- [ ] Argument suggestions
- [ ] Fix in2/ on re-runs
- [ ] More generalized output of AFL errors (fork)
- [ ] Scale jobs
- [ ] Collect resulting crashes and hangs in a backup file so you can fuzz previous binaries without losing progress
- [ ] Add ability to checksum binaries with crashes to create a library of exploitable binaryes (in IoT, binaries are often not updated, so we can map what we learned to what we find later)
CANCELLED - [ ] Update extraction functionality with ubi_reader and sasquatch
CANCELLED - [ ] "Upgrade" to AFL++

### Contributing
This project needs alot of work, but is used for hobbyist reasons. If you see something that may need a change, please fork and add a change. We are open to issues and merge requests.

### Notes
Thanks @trvon for helping me get back on track with this and for the awesome additions.

### Changelog

2020-02-06:	

- Removed run_all_the_things that was there for testing.
- Fixed install issue. AFL is being grabbed from lcamtuf for now.
- Added some comments for clarity of what I was trying to do. 
- Extract function is more modular. I was unnecessarily invoking QEMU at a time when it didn't matter
- Added qemu_mode_setup function. This is almost entirel code from AFL's qemu script. Wasn't necessary to add it several times in my script
- Fixed issue with broken symlink between the auto-fuzz script, though this was a superficial change since that script is now integrated
- Fixed issue with QEMU_LD_PREFIX variable. This is necessary for QEMU mode to work. For those who hit similar issues: It must be set to the directory that *houses* the 'lib' directory, not the 'lib' directory itself. 
- Fixed afl-cmin issue. This issue was related to the QEMU_LD_PREFIX issue, but it was also due to an error in the ulimit code I had originally.
- Removed *several* unnecessary lines of code. More to come. 
- Made some superficial changes to prevent 'echo' from printing character codes. 
- Re-added in the blue color scheme, but I might remove all colors altogether, as I wasn't considering customized terminals when I added that.
- Fixed some of the messages. They were to wordy, and hadn't been updated in too long.
- Removed the old README. Sorry to the guy who forked the project with that README. You were probably very confused and annoyed.
- Minor bug fixes along the way.
- Commented out the check for previous jobs due to a continuous error. This needs to be fixed ASAP as that function can save you from losing crashes
- Removed uneccessary code based on how afl directory was previously calculated
