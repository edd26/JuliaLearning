using Luxor, Colors

"""
Generate a frame filled whith dots moving toward or out form the middle.
"""
function dotted_plane(scene, framenumber)
    distance = mod(framenumber,50)
    if distance <= 25
        for radius = distance:5:300
            setdash("dot")
            sethue("gray30")
            A, B = [Point(x, 0) for x in [-radius, radius]]
            circle(O, radius, :stroke)
        end
    else
        for radius = (50-distance):5:300
            setdash("dot")
            sethue("gray30")
            A, B = [Point(x, 0) for x in [-radius, radius]]
            circle(O, radius, :stroke)
        end
    end
    return
end

"""
Function for background.
"""
function backdrop(scene, framenumber)
    background("white")
end
