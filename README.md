# Boats

# Description
This is a basic boating script for RedM servers using the [RSG framework](https://github.com/Rexshack-RedM). Boats can be bought, sold and transferred through shops. There are 6 shops configured, more shop locations may be added using the `config.lua` file.

# Features
- Buy, sell and transfer boats through the boat shops
- Shop hours may be set individually for each shop or disabled to allow the shop to remain open
- Boats are available to use in the shop where purchased
- Boats can be transferred to other shops by menu (configurable transfer fee) or by driving boat to the new shop and returning it there.
- Shop blips are colored and changeable per shop location
- Blips can change color reflecting if shop is open or closed
- Boats can be returned at the shop location via prompt or remotely using the in-boat menu after parking/beaching the boat somewhere
- In-boat menu for anchor operation and remote boat return
- Config setting to prevent the spawning of NPC boats
- Boats can be driven across the map without sinking


# Dependencies
- [rsg-core](https://github.com/Rexshack-RedM/rsg-core)
- [menu_base](https://github.com/Rexshack-RedM/menu_base)
