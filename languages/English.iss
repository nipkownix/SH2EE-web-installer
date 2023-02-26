#define english_lang_name  "English"

[Messages]
StatusExtractFiles      =Placing files...
SelectDirLabel3         =Silent Hill 2: Enhanced Edition must be installed in the same folder as Silent Hill 2 PC. Please specify the directory where Silent Hill 2 PC is located.
WizardSelectComponents  =Select Enhancement Packages
SelectComponentsDesc    =Please select which enhancement packages you would like to install.
FinishedHeadingLabel    =Installation Complete!
; For translators: try to avoid using the same translated word for "Setup" and "Config" tools, as they're the same or nearly the same.
; Alternative: "Installation Tool".
ExitSetupMessage        =Are you sure you want to close the Setup Tool?

[CustomMessages]
newWelcomeLabel1 =This Setup Tool will guide you through installing Silent Hill 2: Enhanced Edition for use with Silent Hill 2 PC.
newWelcomeLabel2 =Note: This Setup Tool does not include a copy of Silent Hill 2 PC.
newWelcomeLabel3 =You must install your own copy of Silent Hill 2 PC in order to use Silent Hill 2: Enhanced Edition.
newWelcomeLabel4 =You should install Silent Hill 2 PC before running this Setup Tool.
newWelcomeLabel5 =Click Next to continue, or Cancel to exit this Setup Tool.

installTypeFull    =Full installation (Recommended)
installTypeCustom  =Custom installation

wpExtractTitle  =Extracting compressed components
wpExtractDesc   =Please wait while the Setup Tool extracts components.
ChecksumCheck   =Checking file integrity...
TotalProgress   =Total Progress
ExtractingComp  =Extracting Component

newFinishedLabel              =The Setup Tool has successfully installed the selected enhancement packages.%nIf you correctly selected the Silent Hill 2 PC folder at the start of this Setup Tool, Silent Hill 2: Enhanced Edition will automatically run the next time you launch the game.
UsefulLinksLabel              =Useful links:
ProjectWebsiteLabelTitle      =Project Website
ProjectWebsiteLabelDesc       =Silent Hill 2: Enhanced Edition project website.
TroubleshootingPageLabelTitle =Troubleshooting Page
TroubleshootingPageLabelDesc  =This page has common troubleshooting tips.
GitHubPageLabelTitle          =GitHub Project Page
GitHubPageLabelDesc           =You can open a support ticket here for help.

IstallModeTitle      =Select Installation Mode
IstallModeDesc       =How should Silent Hill 2: Enhanced Edition be installed?

normalInstallBtn     =Install enhancement packages (recommended)
normalInstallLabel   =Downloads the enhancement packages to a temporary folder for project installation.

backupInstallBtn     =Install and backup enhancement packages
backupInstallLabel   =Downloads the enhancement packages to a specified folder as a backup and installs the project files.%n%nThe backup created will work as an offline installer.

BackupLocationTitle  =Select Enhancement Packages Backup Location
BackupLocationDesc   =Where should the backup files be stored?
BackupLocationBrowse =Please specify the directory where the backup should be stored. It is recommended to choose a directory outside of Silent Hill 2 PC's folder.%n%nTo continue, click Next.

DescriptionTip                 =Move your mouse over a component to see its description.
eeModuleDescription            =The SH2 Enhancements module provides programming-based fixes and enhancements. This is the "brains" of the project and is required to be installed.
eeExeDescription               =This executable provides compatibility with newer Windows operating systems and is required to be installed.
; For translators: if your language is French, German, Italian or Spanish, here you can replace "language/textual improvements" with "translation improvements".
eeEssentialsDescription        =The Enhanced Edition Essential Files provides geometry fixes, camera clipping adjustments, high resolution text, and language/textual improvements for the game.
img_packDescription            =The Image Enhancement Pack provides upscaled, remastered, and remade full screen images.
fmv_packDescription            =The FMV Enhancement Pack provides improved quality of the game's full motion videos.
audio_packDescription          =The Audio Enhancement Pack provides restored quality of the game's audio files.
dsoalDescription               =DSOAL is a DirectSound DLL replacer that enables surround sound, HRTF, and EAX audio support via OpenAL Soft. This enables 3D positional audio, which restores the sound presentation of the game for a more immersive experience.
xidiDescription                =Provides compatibility with modern controllers.
creditsDescription             =Acknowledging and showing love to those who have made this project possible! This is the Silent Hill 2 PC credits video that includes Silent Hill 2: Enhanced Edition credits. (This is a supplementary video, separate from the original game credits video.)

CurrentSelectionSpace          =Current selection requires at least %1 of disk space.
NoFreeSpace                    =Error: Not enough free space!%n%nThe installation requires at least double the total size of components (%1) to be completed safely.%n%nPlease free some space and try again.
MissingPackage                 =Package missing
AlreadyInstalled               =Already installed
HelpButton                     =Help
LanguageButton                 =Change Language
NoUpdateAvailable              =No update available
NewVersionAvailable            =New version available
NotInstalled                   =Not installed
UnavailableOption              =Unavailable
SH2EEconfigNotFound            =Error: File not found%n%nCouldn't find 'SH2EEconfig.exe'
MaintenanceTitle               =Silent Hill 2: Enhanced Edition Maintenance Wizard
MaintenanceLabel               =Install, repair, update, or uninstall files.
MaintenanceButtonInstall       =Install or Repair Packages
MaintenanceButtonUpdate        =Update Packages
MaintenanceButtonAdjust        =Adjust Settings
MaintenanceButtonUninstall     =Uninstall
MaintenanceLabelUnavailable    =Feature unavailable. Cannot contact server. Please try again later.
MaintenanceLabelInstall        =Install enhancement packages that were not previously installed, or repair broken packages.
MaintenanceLabelUpdate         =Check and download updates for installed enhancement packages.
MaintenanceLabelAdjust         =Open the Silent Hill 2: Enhanced Edition Configuration Tool to adjust project settings for the game.
MaintenanceLabelUninstall      =Remove all installed enhancement packages. This only removes the Silent Hill 2: Enhanced Edition project files and does not remove Silent Hill 2 PC files.
; For translators: you can find Wine's official translations here: https://gitlab.winehq.org/wine/wine/-/tree/master/po
WineDetected                   =Wine/Proton detected%n%nThis installation is running in Wine/Proton.%n%nThe Silent Hill 2: Enhanced Edition DLLs have automatically been set to "native, builtin" in the Wine configuration options.%n%nFor Steam Deck/OS users: This setting is only active for the currently used profile.%nIf you added this installer as a non-Steam game, simply change its target from SH2EEsetup.exe to sh2pc.exe and use that to start the game.
GameFilesNotFound              =The selected folder may not be where Silent Hill 2 PC is located.%n%nProceed anyway?
installPageDescriptionLabel    =Please select which enhancement packages you would like to install or repair.
installSelectComponentsLabel   =Silent Hill 2: Enhanced Edition is comprised of several enhancement packages. Select which enhancement packages you wish to install. For the full, intended experience, install all enhancement packages.
updatePageDescriptionLabel     =Please select which enhancement packages you would like to update.
updateSelectComponentsLabel    =Updates will be listed below if available.
InstallSuccess                 =The Setup Tool has successfully installed the selected enhancement packages.%n%nClick Finish to exit the Setup Tool.
updateFinishedHeadingLabel     =Update complete!
UpdateSuccess                  =The Setup Tool has successfully updated the selected enhancement packages.%n%nClick Finish to exit the Setup Tool.
UninstallConfirm               =Are you sure you want to completely remove all Silent Hill 2: Enhanced Edition project files?
uninstallFinishedHeadingLabel  =Uninstallation complete.
UninstallSuccess               =The Setup Tool has successfully uninstalled the enhancement packages.%n%nClick Finish to exit the Setup Tool.
StartGameAfterExiting          =Start Silent Hill 2 after exiting the Setup Tool
OpenCfgToolAfterExiting        =Open the Configuration Tool to adjust project settings for the game
LocalCSVParseFailed            =Error: Parsing Failed%n%nOffline installation detected, but parsing 'local_sh2ee.dat' failed. Offline installation cannot proceed.%n%nUse online installation mode instead?
LocalCSVMissingFiles           =Error: Missing Files%n%nOffline installation detected, but one or more files are missing from Setup Tool's folder. Offline installation cannot proceed.%n%nUse online installation mode instead?
LocalCSVIncompatibleVersion    =Error: Incompatible Version%n%nThis version of the SH2:EE Setup Tool (%1) is not the version expected to work with the local files (%2).%n%nThe installation cannot continue.
WebURLDownloadError            =Error: Download Failed%n%nCouldn't download 'webcsv.url'.%n%nThe installation cannot continue.%n%nRetry download?
WebCSVDownloadError            =Error: Download Failed%n%nCouldn't download 'sh2ee.csv'.%n%nThe installation cannot continue.%n%nRetry download?
WebCSVParseFailed              =Error: Parsing Failed%n%nCouldn't parse 'sh2ee.csv'.%n%nThe installation cannot continue.
MaintenanceCSVParseFailed      =Error: Parsing Failed%n%nCouldn't parse 'SH2EEsetup.dat'.%n%nThe installation cannot continue.
OutdatedSetupTool              =Error: Outdated Version%n%nThe SH2:EE Setup Tool must be updated in order to use.%n%nUpdate the Setup Tool?
InvalidWebComponentsListSize   =Error: Invalid components list size%n%nThe installer should be updated to handle the new components from 'sh2ee.csv'.
InvalidLocalComponentsListSize =Error: Invalid components list size%n%nThe file 'local_sh2ee.dat' might be corrupted. Use online installation mode instead?
FailedToQueryComponents        =Error: Files unavailable%n%nFailed to query for one or more components.%n%nThe installation cannot continue. Please try again, and if the issue persists, report it to the developers.
FailedToQueryComponents2       =Error: Files unavailable%n%nFailed to query for one or more components.%n%nThe installation cannot continue.
ChecksumMismatchFirstTime      =Error: Checksum mismatch%n%nFile '%1' is corrupted.%n%nDo you wish to skip the installation of this component and move to the next one?%n%nNOTE: You can try installing this component again after the installation has been completed by opening the Setup Tool (SH2EEsetup.exe) in the game's folder, and choosing "Install or Repair Packages". It is strongly recommended you do so in order to fully experience Silent Hill 2: Enhanced Edition.
ChecksumMismatchMaintenance    =Error: Checksum mismatch%n%nFile '%1' is corrupted.%n%nThe installation of this component will be skipped. Please try again, and if the issue persists, report it to the developers.
ExtractionFailed               =Error: Failed to start the extraction.%n%nThe installation cannot continue.
NoComponentsSelected           =Error: No components were selected.
SemicolonInPath                =Error: Invalid path detected%n%nThe chosen directory name contains a semicolon.%n%nThis breaks the game. Please rename the game's directory before continuing.