# KineCraft Library

The KineCraft Library is a module loader and framework for ComputerCraft. It aims to provide the following functionality:

* Downloading modules from online repositories (github/pastebin)
* Installing modules into versioned folders
* Managing dependencies between modules
* Providing a framework for modules to hook into
* An event system for inter-module communication

## Usage

The module is automatically downloaded into the versioned folder and is linked as the startup command

You can then download and install modules like this:

```lua
unimplemented()
```

This will download the example_mod.lua file from the repository specified in the file, determine its version, and install it into a versioned folder.

The installed module can then be required and used in your program.

Contributing
Contributions to the KineCraft Library are welcome! You can contribute by:

* Reporting issues or bugs
* Suggesting new features
* Submitting pull requests with new functionality
* Writing documentation
* Please follow the Contributing Guidelines if you wish to submit a pull request.

craft([limit=64])	Craft a recipe based on the turtle's inventory.
forward()	Move the turtle forward one block.
back()	Move the turtle backwards one block.
up()	Move the turtle up one block.
down()	Move the turtle down one block.
turnLeft()	Rotate the turtle 90 degrees to the left.
turnRight()	Rotate the turtle 90 degrees to the right.
dig([side])	Attempt to break the block in front of the turtle.
digUp([side])	Attempt to break the block above the turtle.
digDown([side])	Attempt to break the block below the turtle.
place([text])	Place a block or item into the world in front of the turtle.
placeUp([text])	Place a block or item into the world above the turtle.
placeDown([text])	Place a block or item into the world below the turtle.
drop([count])	Drop the currently selected stack into the inventory in front of the turtle, or as an item into the world if there is no inventory.
dropUp([count])	Drop the currently selected stack into the inventory above the turtle, or as an item into the world if there is no inventory.
dropDown([count])	Drop the currently selected stack into the inventory in front of the turtle, or as an item into the world if there is no inventory.
select(slot)	Change the currently selected slot.
getItemCount([slot])	Get the number of items in the given slot.
getItemSpace([slot])	Get the remaining number of items which may be stored in this stack.
detect()	Check if there is a solid block in front of the turtle.
detectUp()	Check if there is a solid block above the turtle.
detectDown()	Check if there is a solid block below the turtle.
compare()	Check if the block in front of the turtle is equal to the item in the currently selected slot.
compareUp()	Check if the block above the turtle is equal to the item in the currently selected slot.
compareDown()	Check if the block below the turtle is equal to the item in the currently selected slot.
attack([side])	Attack the entity in front of the turtle.
attackUp([side])	Attack the entity above the turtle.
attackDown([side])	Attack the entity below the turtle.
suck([count])	Suck an item from the inventory in front of the turtle, or from an item floating in the world.
suckUp([count])	Suck an item from the inventory above the turtle, or from an item floating in the world.
suckDown([count])	Suck an item from the inventory below the turtle, or from an item floating in the world.
getFuelLevel()	Get the maximum amount of fuel this turtle currently holds.
refuel([count])	Refuel this turtle.
compareTo(slot)	Compare the item in the currently selected slot to the item in another slot.
transferTo(slot [, count])	Move an item from the selected slot to another one.
getSelectedSlot()	Get the currently selected slot.
getFuelLimit()	Get the maximum amount of fuel this turtle can hold.
equipLeft()	Equip (or unequip) an item on the left side of this turtle.
equipRight()	Equip (or unequip) an item on the right side of this turtle.
inspect()	Get information about the block in front of the turtle.
inspectUp()	Get information about the block above the turtle.
inspectDown()	Get information about the block below the turtle.
getItemDetail([slot [, detailed]])	Get detailed information about the items in the given slot.