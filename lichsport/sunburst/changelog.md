# BETA
## V0.1

### Engine
- Modeled engine tuning using **Common LichSport Tuning Parts** from *LCST Core Components*, not finished yet so not ingame. 

### Body Kit
- Modeled & Textured & JBeamed the LichSport bodykit.

## V0.2

### Body Kit
- Remade how materials/textures work, now theres 3 different materials for the kit, **Colored**, **Gloss Black** and **Carbon**. This allows you to mix and match kit parts in different materials.
- ReTextured the LichSport bodykit to work with the new setup.
- Added custom LichSport Sedan body that has support for roof spoilers and roofs, they include the new materials.
- Modeled and added roof spoilers, they include the new materials.
- Added **Functional** carbon fiber parts,  the parts that support carbon fiber are :
 - Front Bumper Lip, Sideskirt Lip and Rear Diffuser.
 - Hood, Hood Vents and Hood Scoop and Hood Grille.
 - Roof, Roof Spoiler, Lip Spoiler, Spoiler, Spoiler Fin and Spoiler Fin Lip.

## Lights
- Modeled & Textured & JBeamed custom headlights and tailights.
- Added a center mounted diffuser fog light. (Due to the tailights not having a rear foglight)

## V0.3

### Body Kit
- Created Skin UVs for Kit parts.
- Added compatibility with all existing vanilla skins.
- Created custom "LineArt" livery, Has Sedan and Wagon Version.
- Darkened carbon fiber Texture.
- Updated JBeams to use a Standard method for picking panel colors.
- Edited grille Jbeam so its easier to choose from the variants.
- Renamed grilles from **Standard** and **Alternate** to **Type A** and **Type B**.
- Fixed stability issues in carbon roof and made it lighter.
- Modeled different variants of the rear diffuser to allow for **Single** or **Dual** Exit and **Wide** or **Narrow** Hole.
- Redone rear diffuser jbeam so its easier to pick from all types.
- Made the carbon grain bigger, now matches other vanilla parts.
- Removed _wide from front bumper lip since it fits both types.
- Refactored components naming and system on the hood.
- Added option for painted carbon fiber hood and hood scoop.



### Exhaust
- Modeled a customizable exhaust system, you can choose a different Front Section, Middle Section and Muffler(s).
- Texured using the **Common LichSport Tuning Parts** from *LCST Core Components*.
- Implemented exhaust system with custom components to remove or add power depending on exhaust configuration.
- Added variables to the **Type B** muffler so you can customize the muffling, this affects performance.
- Added a split on the MidPipe to allow for dual mufflers.
- Implemented Exhaust Tips from *LCST Core Components*
- implemented a complex components system to allow for the same tips to be used but only for one to show up if its a single muffler, also required a node that only exists if theres a 2nd muffler, you can also change the position of the tip that affects the muffler so the exhaust gases are properly placed.

### Lights
- Fixed Electrics Smoothers caused by 0.36.2 , they caused the light Smoothers to not work, finished implementing said light Glowmaps/Smoothers.
- Added Metalic Housing as optional Variant of Headlights and Tailights.

