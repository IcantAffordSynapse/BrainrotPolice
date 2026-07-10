# BrainrotPolice

To suggest games, report bugs, etc. join https://discord.gg/vaehz.

## Last update: 02/07/2026 {DD/MM/YYYY}

This is an open source little project made for a bunch of brainrot games. Don't take it too seriously.

https://wearentdevs.net/

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Xaric24/BrainrotPolice/refs/heads/main/src/init.lua"))()
```

## Adding Custom Games

1. Put `getgenv().FileScripts = true` before the loadstring.
2. In your executor's workspace folder, open the `BrainrotPolice` folder and make a new `.lua` file.
3. Name it the place id of the game it supports, for example: `12345678910.lua`.
4. Run the loader.

## Custom Game Template

```lua
-- game name

return function(section)
    local elements = loadstring(game:HttpGet(getgitpath("src") .. "elements.lua"))()

    elements:Label("This is a Label", section)

    elements:Toggle("This is a Toggle", section, false, function(bool)
        if bool then
            print("Enabled!")
        else
            print("Disabled.")
        end
    end)

    elements:Button("This is a Button", section, function()
        print("Clicked!")
    end)

    elements:Textbox("This is a TextBox", section, "", function(str)
        print("Typed: " .. str)
    end)
end
```
