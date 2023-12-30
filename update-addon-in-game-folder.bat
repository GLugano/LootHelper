rd /s /q "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\LootHelper"
xcopy ".\" "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\LootHelper" /s /e /h /c /i
rd /s /q "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\LootHelper\.git"
rd /s /q "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\LootHelper\.vscode"
del "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\LootHelper\.gitignore"
del "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\LootHelper\package.json"
del "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\LootHelper\update-addon-in-game-folder.bat" 