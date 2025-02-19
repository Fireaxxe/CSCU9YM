breed [cells cell]    ;; living cells
breed [babies baby]   ;; show where a cell will be born
cells-own [dying?]

patches-own [
  live-neighbors  ;; count of how many neighboring cells are alive
]

to setup-blank
  clear-all
  set-default-shape cells "square" ;; was circle
  set-default-shape babies "dot"
  ask patches
    [ set live-neighbors 0 ]
  draw-gridlines
  reset-ticks
end

to setup-random
  setup-blank
  ;; create initial babies
  ask patches
    [ if random-float 100.0 < initial-density
      [ sprout-babies 1 ] ]
  ;; grow the babies into adult cells
  go
  reset-ticks  ;; set the tick counter back to 0
end

;; this procedure is called when a cell is about to become alive
to birth  ;; patch procedure
  sprout-babies 1
  [ ;; soon-to-be-cells are lime
    set color black ]  ;; invisible ;; + 1 makes the lime a bit lighter
end

to go
  ;; get rid of the dying cells from the previous tick
  ask cells with [dying?] ;;[color = gray]
    [ die ]
  ;; babies become alive
  ask babies
    [ set breed cells
      set color white 
      set dying? false ]
  ;; All the live cells count how many live neighbors they have.
  ;; Note we don't bother doing this for every patch, only for
  ;; the ones that are actually adjacent to at least one cell.
  ;; This should make the program run faster.
  ask cells
    [ ask neighbors
      [ set live-neighbors live-neighbors + 1 ] ]
  ;; Starting a new "ask" here ensures that all the cells
  ;; finish executing the first ask before any of them start executing
  ;; the second ask.
  ;; Here we handle the death rule.
  ask cells
    [ ifelse live-neighbors = 2 or live-neighbors = 3
      [ set dying? false ]
      [ set dying? true ] ] ;; these cells will die next round
                           ;; Now we handle the birth rule.
  ask patches
    [ if not any? cells-here and live-neighbors = 3
      [ birth ]
    ;; While we're doing "ask patches", we might as well
    ;; reset the live-neighbors counts for the next generation.
    set live-neighbors 0 ]
  tick
end

;; user adds or removes cells with the mouse
to draw-cells
  let erasing? any? cells-on patch mouse-xcor mouse-ycor
  while [mouse-down?]
    [ ask patch mouse-xcor mouse-ycor
      [ ifelse erasing?
        [ erase ]
        [ draw ] ]
    display ]
end

;; user adds a cell with the mouse
to draw  ;; patch procedure
  if not any? cells-here
    [ ask turtles-here [ die ]  ;; old cells and babies go away
      sprout-cells 1 [ set color white ]
      update
      ask neighbors [ update ] ]
end

;; user removes a cell with the mouse
to erase  ;; patch procedure
  ask turtles-here [ die ]
  update
  ask neighbors [ update ]
end

;; this isn't called from GO.  it's only used for
;; bringing individual patches up to date in response to
;; the user adding or removing cells with the mouse.
to update  ;; patch procedure
  ask babies-here
    [ die ]
  let n count cells-on neighbors
  ifelse any? cells-here
    [ ifelse n = 2 or n = 3
      [ ask cells-here [ set dying? false ] ]
      [ ask cells-here [ set dying? true  ] ] ]
    [ if n = 3
      [ sprout-babies 1
        [ set color black ] ] ]
  set live-neighbors 0  ;; reset for next time through "go"
end

to draw-gridlines
  crt world-width [
    set ycor min-pycor
    set xcor who + .5
    set color 2
    set heading 0
    pd
    fd world-height
    die
  ]
  crt world-height [
    set xcor min-pxcor
    set ycor who + .5
    set color 2
    set heading 90
    pd
    fd world-width
    die
  ]
end

;; Must rewrite this more elegantly using lists someday!
;;
to draw-example
  setup-blank
  ifelse (example = "blinker")
  [ draw-blinker ]
  [ ifelse (example = "toad" )
    [ draw-toad ]
    [ ifelse (example = "beacon" )
      [ draw-beacon ]
      [ ifelse (example = "pulsar" )
        [ draw-pulsar ]
        [ ifelse (example = "glider" )
          [ draw-glider ]
          [ ifelse (example = "glider gun")
            [ draw-glider-gun ]
            [ if (example = "spaceship")
              [ draw-spaceship ]
            ]]]]]]
end

to draw-blinker
  ask patch 0 1 [sprout-babies 1]
  ask patch 0 0 [sprout-babies 1]
  ask patch 0 -1 [sprout-babies 1] 
  go
end

to draw-toad
  ask patch 0 1 [sprout-babies 1]
  ask patch 1 1 [sprout-babies 1]
  ask patch 2 1 [sprout-babies 1] 
  ask patch -1 0 [sprout-babies 1]
  ask patch 0 0 [sprout-babies 1]
  ask patch 1 0 [sprout-babies 1] 
  go
end

to draw-beacon
  ask patch -2 1 [sprout-babies 1]
  ask patch -1 1 [sprout-babies 1]
  ask patch -2 0 [sprout-babies 1] 
  ask patch -1 0 [sprout-babies 1]
  ask patch 0 -1 [sprout-babies 1]
  ask patch 1 -1 [sprout-babies 1] 
  ask patch 0 -2 [sprout-babies 1]
  ask patch 1 -2 [sprout-babies 1]
  go
end

to draw-pulsar
  ask patch -6 4 [sprout-babies 1] 
  ask patch -6 3 [sprout-babies 1]
  ask patch -6 2 [sprout-babies 1]
  ask patch -6 -2 [sprout-babies 1] 
  ask patch -6 -3 [sprout-babies 1]
  ask patch -6 -4 [sprout-babies 1]
  
  ask patch -1 4 [sprout-babies 1] 
  ask patch -1 3 [sprout-babies 1]
  ask patch -1 2 [sprout-babies 1]
  ask patch -1 -2 [sprout-babies 1] 
  ask patch -1 -3 [sprout-babies 1]
  ask patch -1 -4 [sprout-babies 1]
  
  ask patch 1 4 [sprout-babies 1] 
  ask patch 1 3 [sprout-babies 1]
  ask patch 1 2 [sprout-babies 1]
  ask patch 1 -2 [sprout-babies 1] 
  ask patch 1 -3 [sprout-babies 1]
  ask patch 1 -4 [sprout-babies 1]
  
  ask patch 6 4 [sprout-babies 1] 
  ask patch 6 3 [sprout-babies 1]
  ask patch 6 2 [sprout-babies 1]
  ask patch 6 -2 [sprout-babies 1] 
  ask patch 6 -3 [sprout-babies 1]
  ask patch 6 -4 [sprout-babies 1]
  
  ask patch 4 -6 [sprout-babies 1] 
  ask patch 3 -6 [sprout-babies 1]
  ask patch 2 -6 [sprout-babies 1]
  ask patch -2 -6 [sprout-babies 1] 
  ask patch -3 -6 [sprout-babies 1]
  ask patch -4 -6 [sprout-babies 1]
  
  ask patch 4 -1 [sprout-babies 1] 
  ask patch 3 -1 [sprout-babies 1]
  ask patch 2 -1 [sprout-babies 1]
  ask patch -2 -1 [sprout-babies 1] 
  ask patch -3 -1 [sprout-babies 1]
  ask patch -4 -1 [sprout-babies 1]
  
  ask patch 4 1 [sprout-babies 1] 
  ask patch 3 1 [sprout-babies 1]
  ask patch 2 1 [sprout-babies 1]
  ask patch -2 1 [sprout-babies 1] 
  ask patch -3 1 [sprout-babies 1]
  ask patch -4 1 [sprout-babies 1]
  
  ask patch 4 6 [sprout-babies 1] 
  ask patch 3 6 [sprout-babies 1]
  ask patch 2 6 [sprout-babies 1]
  ask patch -2 6 [sprout-babies 1] 
  ask patch -3 6 [sprout-babies 1]
  ask patch -4 6 [sprout-babies 1]
  go
end
 
to draw-glider
  ask patch -1 2 [sprout-babies 1]
  ask patch 0 1 [sprout-babies 1]
  ask patch 0 0 [sprout-babies 1]
  ask patch -1 0 [sprout-babies 1]
  ask patch -2 0 [sprout-babies 1]
  go
end

to draw-glider-gun
  ask patch 0 0 [sprout-babies 1]
  
  ask patch -14 0 [sprout-babies 1]
  ask patch -13 0 [sprout-babies 1]
  ask patch -14 1 [sprout-babies 1]
  ask patch -13 1 [sprout-babies 1]
  
  ask patch -1 -3 [sprout-babies 1]
  ask patch -2 -3 [sprout-babies 1]
  ask patch -3 -2 [sprout-babies 1]
  ask patch -4 -1 [sprout-babies 1]
  ask patch -4 0 [sprout-babies 1]
  ask patch -4 1 [sprout-babies 1]
  ask patch -3 2 [sprout-babies 1]
  ask patch -2 3 [sprout-babies 1]
  ask patch -1 3 [sprout-babies 1] 
  
  ask patch 1 2 [sprout-babies 1]
  ask patch 2 1 [sprout-babies 1]
  ask patch 2 0 [sprout-babies 1]
  ask patch 3 0 [sprout-babies 1]
  ask patch 2 -1 [sprout-babies 1]
  ask patch 1 -2 [sprout-babies 1]
  
  ask patch 6 1 [sprout-babies 1]
  ask patch 6 2 [sprout-babies 1]
  ask patch 6 3 [sprout-babies 1]
  ask patch 7 1 [sprout-babies 1]
  ask patch 7 2 [sprout-babies 1]
  ask patch 7 3 [sprout-babies 1]
  ask patch 8 0 [sprout-babies 1]
  ask patch 8 4 [sprout-babies 1]
  ask patch 10 0 [sprout-babies 1]
  ask patch 10 -1 [sprout-babies 1]
  ask patch 10 4 [sprout-babies 1]
  ask patch 10 5 [sprout-babies 1]
  
  ask patch 20 2 [sprout-babies 1]
  ask patch 21 2 [sprout-babies 1]
  ask patch 20 3 [sprout-babies 1]
  ask patch 21 3 [sprout-babies 1]
  go
end

to draw-spaceship
  ask patch -2 2  [sprout-babies 1]
  ask patch -1 2  [sprout-babies 1]
  ask patch 0 2 [sprout-babies 1]
  ask patch 1 2 [sprout-babies 1]
  
  ask patch -2 1 [sprout-babies 1]
  ask patch -1 1 [sprout-babies 1]
  ask patch 0 1 [sprout-babies 1]
  ask patch 1 1 [sprout-babies 1]
  
  ask patch -6 0 [sprout-babies 1]
  ask patch -5 0 [sprout-babies 1]
  ask patch -4 0 [sprout-babies 1]
  ask patch -3 0 [sprout-babies 1]
  
  ask patch 2 0 [sprout-babies 1]
  ask patch 3 0 [sprout-babies 1]
  ask patch 4 0 [sprout-babies 1]
  ask patch 5 0 [sprout-babies 1]
  
  ask patch -6 2 [sprout-babies 1]
  ask patch -7 3 [sprout-babies 1]
  ask patch -7 4 [sprout-babies 1]
  ask patch -8 5 [sprout-babies 1]
  ask patch -6 5 [sprout-babies 1]
  ask patch -7 6 [sprout-babies 1]
  ask patch -7 7 [sprout-babies 1]
  
  ask patch 5 2 [sprout-babies 1]
  ask patch 6 3 [sprout-babies 1]
  ask patch 6 4 [sprout-babies 1]
  ask patch 5 5 [sprout-babies 1]
  ask patch 7 5 [sprout-babies 1]
  ask patch 6 6 [sprout-babies 1]
  ask patch 6 7 [sprout-babies 1]
  
  ask patch -4 -2 [sprout-babies 1] 
  ask patch -3 -3 [sprout-babies 1] 
  ask patch -2 -3 [sprout-babies 1] 
  
  ask patch 3 -2 [sprout-babies 1] 
  ask patch 1 -3 [sprout-babies 1] 
  ask patch 2 -3 [sprout-babies 1] 
  
  go
end


; Copyright 2005 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
290
10
868
609
35
35
8.0
1
10
1
1
1
0
1
1
1
-35
35
-35
35
1
1
1
ticks
15.0

SLIDER
125
72
281
105
initial-density
initial-density
0.0
100.0
35
0.1
1
%
HORIZONTAL

BUTTON
16
73
118
106
NIL
setup-random
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
17
227
121
265
go-once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
127
227
231
265
go-forever
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
67
274
170
319
current density
(count cells\n/ count patches) * 100
2
1
11

BUTTON
16
37
118
70
NIL
setup-blank
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
131
136
284
202
When this button is down, you can add or remove cells by holding down the mouse button and \"drawing\".
11
0.0
0

BUTTON
16
144
119
179
NIL
draw-cells
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
18
376
157
421
example
example
"blinker" "toad" "beacon" "pulsar" "glider" "glider gun" "spaceship"
5

BUTTON
20
435
130
469
NIL
draw-example
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This model is the same as the Life model, but with a more attractive display.  This display is achieved by basing the model on turtles rather than patches.

This program is an example of a two-dimensional cellular automaton. This particular cellular automaton is called The Game of Life.

A cellular automaton is a computational machine that performs actions based on certain rules.  It can be thought of as a board which is divided into cells (such as square cells of a checkerboard).  Each cell can be either "alive" or "dead."  This is called the "state" of the cell.  According to specified rules, each cell will be alive or dead at the next time step.

## HOW IT WORKS

The rules of the game are as follows.  Each cell checks the state of itself and its eight surrounding neighbors and then sets itself to either alive or dead.  If there are less than two alive neighbors, then the cell dies.  If there are more than three alive neighbors, the cell dies.  If there are 2 alive neighbors, the cell remains in the state it is in.  If there are exactly three alive neighbors, the cell becomes alive. This is done in parallel and continues forever.

There are certain recurring shapes in Life, for example, the "glider" and the "blinker". The glider is composed of 5 cells which form a small arrow-headed shape, like this:

      O
       O
     OOO

This glider will wiggle across the world, retaining its shape.  A blinker is a group of three cells (either up and down or left and right) that rotates between horizontal and vertical orientations.

## HOW TO USE IT

The INITIAL-DENSITY slider determines the initial density of cells that are alive.  SETUP-RANDOM places these cells.  GO-FOREVER runs the rule forever.  GO-ONCE runs the rule once.

As the model runs, a small green dot indicates where a cell will be born, but is not treated as a live cell.  Grey cells are cells that are about to die, but are treated as live cells.

If you want to draw your own pattern, press the DRAW-CELLS button and then use the mouse to "draw" and "erase" in the view.

CURRENT DENSITY is the percent of cells that are on.

## THINGS TO NOTICE

Find some objects that are alive, but motionless.

Is there a "critical density" - one at which all change and motion stops/eternal motion begins?

## THINGS TO TRY

Are there any recurring shapes other than gliders and blinkers?

Build some objects that don't die (using DRAW-CELLS)

How much life can the board hold and still remain motionless and unchanging? (use DRAW-CELLS)

The glider gun is a large conglomeration of cells that repeatedly spits out gliders.  Find a "glider gun" (very, very difficult!).

## EXTENDING THE MODEL

Give some different rules to life and see what happens.

Experiment with using `neighbors4` instead of `neighbors` (see below).

## NETLOGO FEATURES

The `neighbors` primitive returns the agentset of the patches to the north, south, east, west, northeast, northwest, southeast, and southwest.

`neighbors4` is like `neighbors` but only uses the patches to the north, south, east, and west.  Some cellular automata, like this one, are defined using the 8-neighbors rule, others the 4-neighbors.

## RELATED MODELS

Life --- same as this, but implemented using only patches, not turtles  
CA 1D Elementary --- a model that shows all 256 possible simple 1D cellular automata  
CA 1D Totalistic --- a model that shows all 2,187 possible 1D 3-color totalistic cellular automata  
CA 1D Rule 30 --- the basic rule 30 model  
CA 1D Rule 30 Turtle --- the basic rule 30 model implemented using turtles  
CA 1D Rule 90 --- the basic rule 90 model  
CA 1D Rule 110 --- the basic rule 110 model  
CA 1D Rule 250 --- the basic rule 250 model

## CREDITS AND REFERENCES

The Game of Life was invented by John Horton Conway.

See also:

Von Neumann, J. and Burks, A. W., Eds, 1966. Theory of Self-Reproducing Automata. University of Illinois Press, Champaign, IL.

"LifeLine: A Quarterly Newsletter for Enthusiasts of John Conway's Game of Life", nos. 1-11, 1971-1973.

Martin Gardner, "Mathematical Games: The fantastic combinations of John Conway's new solitaire game `life',", Scientific American, October, 1970, pp. 120-123.

Martin Gardner, "Mathematical Games: On cellular automata, self-reproduction, the Garden of Eden, and the game `life',", Scientific American, February, 1971, pp. 112-117.

Berlekamp, Conway, and Guy, Winning Ways for your Mathematical Plays, Academic Press: New York, 1982.

William Poundstone, The Recursive Universe, William Morrow: New York, 1985.


## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

* Wilensky, U. (2005).  NetLogo Life Turtle-Based model.  http://ccl.northwestern.edu/netlogo/models/LifeTurtle-Based.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2005 Uri Wilensky.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
setup-random repeat 20 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
