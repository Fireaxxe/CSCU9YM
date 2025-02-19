;; This is a model of an SIR disease spreading on a network.
;; It incorporates NetLogo library code from the Small World and Preferential Attachment models

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Breeds, turtle and breed variables, and global variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

breed [susceptibles susceptible]  ;; people who have never been ill
breed [infecteds infected]        ;; people who are ill and can spread infection
breed [recovereds recovered]      ;; people who have recovered and are immune

susceptibles-own [to-become-infected?]   ;; has the susceptible contracted the illness?
infecteds-own [days-ill]           ;; length of time the infected has been ill

globals [wrap?        ;; for square lattice network. If true, network wraps from top to bottom and left to right.
         max-ticks]   ;; maximum length of epidemic


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Network setup procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This module creates a network of the chosen type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-network
  clear-all
  set-default-shape turtles "circle"
  ifelse (network-type = "line")
  [
     create-line
  ][
  ifelse (network-type = "ring")
  [
     create-ring
  ][ 
  ifelse (network-type = "ring lattice")
  [
    create-ring-lattice
  ][
  ifelse (network-type = "square lattice (no wrapping)")
  [
    set wrap? false
    create-square-lattice
  ][
  ifelse (network-type = "square lattice (wrapping)")
  [
    set wrap? true
    create-square-lattice
  ][
  ifelse (network-type = "random")
  [
    create-random
  ][
  ifelse (network-type = "small world")
  [
    create-small-world
  ][
  ifelse (network-type = "scale free")
  [
    create-scale-free
  ][
  ]]]]]]]]
  reset-ticks
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create a simple ring network ;;            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to create-ring
  create-turtles population-size                   ;; create the turtles
  layout-circle (sort turtles) max-pxcor - 1       ;; lay them out in a circle in order of their who numbers
  let n 0
  while [n < count turtles]                        ;; get each turtle to make a link with the next turtle along                    
  [
    ask turtle n [
      create-link-with (turtle ((n + 1) mod count turtles))    
    ]
    set n n + 1
  ]         
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create a straight line network           ;;
;; Nodes at end of line are coloured yellow ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to create-line
  create-ring           ;; First create a ring network
  ask link 1 2 [die]    ;; Then remove one link to turn the ring into a line
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create a square lattice network           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to create-square-lattice
  let side round (sqrt population-size)  ;; Work out approx side of square needed to contain required number of turtles
  let minx 0 - side  
  let miny 0 - side   
  let maxx side - 2      
  if ((side * side) < population-size) [set maxx side]     ;; if square is too small to hold enough turtles increase the width
  let maxy side - 2      
  let num-so-far 0                  ;; count of number of turtles processed so far
  ;;
  ;; Create required number of turtles in square area around origin.
  ;; If the number of turtles is not a perfect square the square area
  ;; will be partially filled.
  ;;
  let x minx
  while [x <= maxx]
  [
    let y miny
    while [(y <= maxy) and (num-so-far < population-size)] 
    [
      ask patch x y [sprout 1]
      set num-so-far (num-so-far + 1)
      set y y + 2
    ]
    set x x + 2
  ]
  ;;
  ;; Add links to place turtles in square lattice
  ;; Ask each turtle to create links with the turtle to its right and the turtle above it
  ;; If wrapping is requested, the rightmost turtles create links with their leftmost 
  ;; counterparts, and the topmost turtles create links with their counterparts on the
  ;; bottom row. 
  ;;
  set num-so-far 0
  set x minx
  while [x <= maxx]
  [
    let y miny
    while [(y <= maxy) and (num-so-far < population-size)] 
    [
      ask turtles-on patch x y 
      [
        ifelse (any? turtles-on patch (x + 2) y) 
        [
          create-link-with one-of turtles-on patch (x + 2) y
        ][
          if (wrap? and minx != x) [create-link-with one-of turtles-on patch minx y]
        ]
        ifelse (any? turtles-on patch x (y + 2))
        [
          create-link-with one-of turtles-on patch x (y + 2)
        ][
          if (wrap? and miny != y) [create-link-with one-of turtles-on patch x miny]
        ]
      ]
      set num-so-far (num-so-far + 1)
      set y y + 2
    ]
    set x x + 2
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create a ring lattice network. First a    ;;
;; ring is created, then each node is given  ;;
;; two additional links to the nodes that    ;;
;; are two steps away from it in the ring.   ;;
;; (This could be done more efficiently by   ;;
;; creating all links in one step rather than;;
;; creating the ring first.}                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to create-ring-lattice
  create-ring  
  let n 0
  while [n < count turtles]
  [
    ;; add links with turtles two links away
    ;; this makes a lattice with average degree of 4
    ask turtle n [
      create-link-with (turtle ((n + 2) mod count turtles))
    ]
    set n n + 1
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create a "small-world" network. This is done  ;;
;; using the Watts-Strogatz method of creating   ;;
;; a ring lattice first and then randomly        ;;
;; "rewiring" each link by replacing it with a   ;;
;; link from one of its end nodes to some        ;;
;; randomly chosen other node to which it is not ;;
;; already linked. The rewiring-probability      ;;
;; parameter dictates what percentage of links   ;;
;; will be rewired. The resulting graph is not   ;;
;; guaranteed to be a small-world (I think) as I ;;
;; expect this depends on the parameters used.   ;;
;; (Could add code to check path lengths and     ;;
;; clustering coefficient so as to decide        ;;
;; if the result has small world property.       ;;
;;                                               ;;
;; The resulting graph may or may not be         ;;
;; connected - this could also be checked.       ;;
;;                                               ;;
;; The code here is adapted from the Small World ;;
;; model in the NetLogo library.                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to create-small-world
  create-ring-lattice       ;; start with a ring lattice entork
  ask links [
    if (random-float 1) < rewiring-probability   ;; make a random choice about whether to rewire this link
    [
      let node1 end1
      if [ count link-neighbors ] of node1 < (count turtles - 1)   ;; check that node1 is not already connected to everyone
      [
        let node2 one-of turtles with [ (self != node1) and (not link-neighbor? node1) ]   ;; chose a node (node2) that is not node1 and that node1 is not already connected to
        ask node1 [ create-link-with node2 ]        ;; connect node1 to node 2
        die                                         ;; destroy the original link
      ]
    ] 
  ] 
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create a scale free network using the method of ;;
;; preferential attachment. This code is adapted   ;;
;; from the Preferential Attachment model in the   ;;
;; NetLogo library                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to create-scale-free  
  make-node nobody
  make-node turtle 0
  let n 2
  while [n < population-size]
  [
    make-node find-partner
    layout
    set n n + 1
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create a new node linked to old-node and move it ;;
;; to a suitable position                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to make-node [old-node]
  create-turtles 1 
  [
    if old-node != nobody [
      create-link-with old-node 
      move-to old-node
      forward 8
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Comment from Preferential Attachment library model:
;; This code is borrowed from Lottery Example (in the Code Examples
;; section of the Models Library).
;; The idea behind the code is a bit tricky to understand.
;; Basically we take the sum of the degrees (number of connections)
;; of the turtles, and that's how many "tickets" we have in our lottery.
;; Then we pick a random "ticket" (a random number).  Then we step
;; through the turtles to figure out which node holds the winning ticket.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report find-partner
  let ticket random-float sum [count link-neighbors] of turtles
  let partner nobody
  ask turtles
  [
    let nc count link-neighbors
    ;; if there's no winner yet...
    if partner = nobody
    [
      ifelse nc > ticket      ;; if the turtle has more neighbors than the "ticket" value
        [ set partner self ]        ;; then that turtle is the chosen partner
        [ set ticket ticket - nc ]  ;; otherwise the ticket value is reduced by the turtle's number of neighbours
    ]
  ]
  report partner
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; layout procedure from Preferential Attachment library model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to layout
  ;; the number 3 here is arbitrary; more repetitions slows down the
  ;; model, but too few gives poor layouts
  repeat 3 [
    ;; the more turtles we have to fit into the same amount of space,
    ;; the smaller the inputs to layout-spring we'll need to use
    let factor sqrt count turtles
    ;; numbers here are arbitrarily chosen for pleasing appearance
    layout-spring turtles links (1 / factor) (7 / factor) (1 / factor)
    display  ;; for smooth animation
  ]
  ;; don't bump the edges of the world
  let x-offset max [xcor] of turtles + min [xcor] of turtles
  let y-offset max [ycor] of turtles + min [ycor] of turtles
  ;; big jumps look funny, so only adjust a little each time
  set x-offset limit-magnitude x-offset 0.1
  set y-offset limit-magnitude y-offset 0.1
  ask turtles [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; limit-magnitude reporter, needed by the layout procedure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report limit-magnitude [number limit]
  if number > limit [ report limit ]
  if number < (- limit) [ report (- limit) ]
  report number
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create a random graph containing the ;;
;; requested percentage of links        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to create-random 
  create-turtles population-size 
  let numlinks round ((linkage / 200) * population-size * (population-size - 1))  ;; work out how many links to create
  repeat numlinks 
  [
    ask one-of (turtles with [count my-links < count turtles - 1])   ;; find a turtle that is not already linked to all the others
    [  
      let first-turtle self                             
      create-link-with (one-of other turtles with [link-neighbor? first-turtle = false])  ;; ask that turtle to make a link with another turtle it is not already linked to
    ]
  ]
  repeat 10 [layout-spring turtles links 0.5 35 25]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  setup epidemic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-epidemic
  ask turtles     ;; Make all the turtles susceptibles
  [
    set breed susceptibles    
    set color green
    set to-become-infected? false
  ]
  if (initial-infected > population-size) [set initial-infected population-size]    
  ask n-of initial-infected turtles                                                 ;; infect the initial infection foci
  [
    set breed infecteds
    set color red
    set days-ill (random recovery-time)
  ]
  clear-all-plots
  reset-ticks
  set max-ticks 1000   ;; maximum length of epidemic is 1000 ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Go procedures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  progress-epidemic ;; spread te
  update-status     ;; change the breeds of turtles who have moved from sus to inf, or from inf to rec
  tick
  if (ticks = max-ticks) or (count infecteds = 0) [stop]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; One day in the progress of the epidemic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to progress-epidemic
  ask susceptibles      ;; susceptibles contact infecteds and may thereby become infected
  [
    let infected-contacts (count link-neighbors with [breed = infecteds])  ;; count the number of infected contacts
    let transmission-chance  1 - ((1 - p-infect) ^ infected-contacts) ;; The probability that at least one of these contacts transmits the infection is
                                                                      ;; 1 - the probability that none of them transmit the infection infection
    if random-float 1 < transmission-chance [set to-become-infected? true]   ;; infection is transmitted with probability transmission-chance
  ]
  ask infecteds  ;; infecteds chalk up one more day of illness
  [
    set days-ill (days-ill + 1)
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Update status of individuals
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to update-status
  ask susceptibles with [to-become-infected?]
  [
    set breed infecteds
    set color red
    set days-ill 0
  ]
  ask infecteds with [days-ill = recovery-time]
  [
    set breed recovereds
    set color grey
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
504
10
1242
769
45
45
8.0
1
10
1
1
1
0
0
0
1
-45
45
-45
45
0
0
1
ticks
30.0

CHOOSER
120
260
324
305
network-type
network-type
"line" "ring" "ring lattice" "small world" "square lattice (no wrapping)" "square lattice (wrapping)" "scale free" "random"
7

BUTTON
30
451
142
484
setup-network
setup-network
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
35
330
188
375
Random network: percentage of all possible links to include.
11
0.0
1

TEXTBOX
30
382
194
438
Small world network: probability that a given link  will be replaced by a random link.
11
0.0
1

TEXTBOX
36
18
431
54
SIR disease spread on networks of different types
16
105.0
1

SLIDER
195
50
367
83
population-size
population-size
0
500
12
1
1
NIL
HORIZONTAL

SLIDER
195
145
367
178
p-infect
p-infect
0
1
0.25
0.01
1
NIL
HORIZONTAL

SLIDER
187
331
359
364
linkage
linkage
0
10
10
0.1
1
NIL
HORIZONTAL

SLIDER
187
384
359
417
rewiring-probability
rewiring-probability
0
1
0.3
0.01
1
NIL
HORIZONTAL

TEXTBOX
39
60
204
88
Number of people in population
11
0.0
1

TEXTBOX
21
141
187
197
Probability that a susceptible person will become ill from a single contact with an infected person.
11
0.0
1

SLIDER
195
195
367
228
recovery-time
recovery-time
0
50
10
1
1
NIL
HORIZONTAL

TEXTBOX
35
200
192
228
Time for an ill person to recover
11
0.0
1

TEXTBOX
29
269
179
287
type of network
11
0.0
1

BUTTON
155
452
269
485
setup-epidemic
setup-epidemic
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
420
450
483
483
go
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

PLOT
30
505
435
755
epidemic populations
time
number
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"S" 1.0 0 -13840069 true "" "plot count susceptibles"
"I" 1.0 0 -2674135 true "" "plot count infecteds"
"R" 1.0 0 -7500403 true "" "plot count recovereds"

SLIDER
195
100
367
133
initial-infected
initial-infected
0
50
10
1
1
NIL
HORIZONTAL

TEXTBOX
15
100
195
126
Number infected at start of epidemic
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This is a model of the spread of an SIR (Susceptible-Infected-Recovered) disease epidemic on a network. The model provides a variety of network types to allow exploration of how epidemic spread is affected by the structure of the contacts between people in the population. 

## HOW IT WORKS

Turtles represent people in a population experiencing an epidemic. Initially, a few people are infected (and capable of infecting others) and the rest are susceptible, meaning they can catch the disease. At each time step, susceptible people contact those they are linked to. Each contact with an infected person presents a risk that the susceptible person will become infected. Once infected, the person remains ill for a fixed number of days (recovery-time), after which the person recovers and becomes immune to the infection. The epidemic ends when all infected people have recovered. 

## HOW TO USE IT

Set sliders to control the size of the population, the number of people infected at the
start of the epidemic, the infectiousness of the disease agent, and the time taken to 
recover from the disease. 

Then choose the network type. If choosing a random network, it is also necessary to choose what percentage of the total number of possible links should be included. If choosing a small-world network (which is constructed by starting from a ring lattice, following the Watts-Strogatz method), it is necessary to choose the probability that a link in the initial ring lattice is randomly rewired.

Once the parameters are set, click setup-network to create the network, then click setup-epidemic to choose the initial infected cases, then click go.

## THINGS TO NOTICE

Keeping the network and all other parameters fixed, run the model with very high and very low values for p-infect. You should see a clear difference in behaviour. See if you can find a tipping point value for p-infect (called the epidemic threshold) that separates these two kinds of behaviour.

Try using a different type of network. Can you still find an epidemic threshold? How is it affected by the type of network? Why do you think this might be?

## THINGS TO TRY

Using BehaviorSpace, set up experiments to find the epidemic threshold (if there is one) in a few networks. Your experiments should systematically sweep through values of p-infect, keeping the network and all other parameters fixed. 

## CREDITS AND REFERENCES

This model was written by Savi Maharaj.
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

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@
