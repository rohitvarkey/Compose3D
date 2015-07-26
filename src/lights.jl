abstract Light <: Compose3DNode
import Color: RGB, color

export pointlight, spotlight, ambientlight
#Ambient Light is applied globally to all objects.
immutable AmbientLight <: Light
    color::RGB{Float64}
end

ambientlight(color::String) = ambientlight(Color.color(color))
ambientlight(color::RGB{Float64}=Color.color("white")) = AmbientLight(color) 

resolve(box::Absolute3DBox, light::AmbientLight) = light

#Like a light bulb. Light shines in all directions.
immutable PointLight <: Light
    position::Point{3}
    color::RGB{Float64}
    intensity::Float64
    distance::Length
end

PointLight(x::Length,y::Length,z::Length,color::RGB{Float64},intensity::Float64,
           distance::Length) = 
    PointLight(Point(x,y,z),color,intensity,distance)

pointlight(x::Length,y::Length,z::Length,color::RGB{Float64}=Color.color("white");
    intensity::Float64=1.0,distance=0mm) = 
    PointLight(x,y,z,color,intensity,distance)

pointlight(x::Length,y::Length,z::Length,color::String;intensity::Float64=1.0,
    distance=0mm) = 
    PointLight(x,y,z,Color.color(color),intensity,distance)

function resolve(box::Absolute3DBox, light::PointLight)
    absposition = Point(resolve(box, light.position))
    absdistance = resolve(box, light.distance)mm
    PointLight(absposition,light.color,light.intensity,absdistance)
end

#PointLight casting shadow in one direction.
immutable SpotLight <: Light
    position::Point{3}
    color::RGB{Float64}
    intensity::Float64
    distance::Length
    angle::Float64 #Degrees
    exponent::Float64
    shadow::Bool
end

SpotLight(x::Length,y::Length,z::Length,color::RGB{Float64},intensity::Float64,
          distance::Length,angle::Float64,exponent::Float64,shadow::Bool) = 
    SpotLight(Point(x,y,z),color,intensity,distance,angle,exponent,shadow)

spotlight(x::Length,y::Length,z::Length,color::RGB{Float64}=Color.color("white");
          intensity::Float64=1.0,distance=0mm,angle::Float64=60.0,
          exponent::Float64=8.0,shadow::Bool=false) = 
    SpotLight(x,y,z,color,intensity,distance,angle,exponent,shadow)

spotlight(x::Length,y::Length,z::Length,color::String;intensity::Float64=1.0,
          distance=0mm,angle::Float64=60.0,exponent::Float64=8.0,shadow::Bool=false) =
    SpotLight(x,y,z,Color.color(color),intensity,distance,angle,exponent,shadow)

function resolve(box::Absolute3DBox, light::SpotLight)
    absposition = Point(resolve(box, light.position))
    absdistance = resolve(box, light.distance)mm
    SpotLight(
        absposition,
        light.color,
        light.intensity,
        absdistance,
        light.angle,
        light.exponent,
        light.shadow
    )
end