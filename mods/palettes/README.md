# Delivery Palettes

Textures CC-BY-SA 4.0, Homedecor

## Placing palettes

Palettes should be placed during map creation, and marked using a world location like `red.palette = 0,0,0`

For development, you can place a palette if the team doesn't have one.

## API

* palettes.deliver(tname, stack) -> (bool, string)
  * Attempts to add a stack to the palette.
  * Either all the stack will be added, or none.
  * Returns `true, nil` on success, `false, err_msg` on failure.
* palettes.register_on_deliver(func(tname, stack, pos))
  * func() return value is ignored.
