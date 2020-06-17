;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This code creates a NetLogo visualization of a Facebook personal network, extracted 
;; as a .gdf file from Facebook using the Netvizz app (https://apps.facebook.com/netvizz/)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals 
[
  line-data
  show-names
]

turtles-own 
[
  userid       ;; corresponds to "name" field in .gdf file
  myname       ;; corresponds to "label" field
  sex
]              ;; This could be extended to record local and age-rank if required


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Import the Facebook network data.
;; It is assumed that the data file is a text file with the following format:
;; First line is a node definition header line
;; This is followed by lines of node data (name, label, sex, locale, agerank)
;; Then comes the edge definition header line
;; This is followed by lines of edge data (node1, node2)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to import-network
  clear-all
  file-open user-file
  if not file-at-end?   ;; Is there any data in the file?
  [
    set line-data file-read-line   ;; Read and discard the node definition header line.
  
    let reading-nodes true    ;; We are currently reading the node data.
    
    while [reading-nodes]     ;; Read all node data and create nodes
    [
      if not file-at-end?     ;; Is there any data remaining in the file.
      [
        set line-data split file-read-line ","   ;; Read next input line and split at commas to form list of strings.
        ifelse first (first line-data) = "e"     ;; Have we reached the edge definition header line?
        [
          set reading-nodes false
        ] 
        [
          create-turtles 1    ;; create a single node
          [
            set userid item 0 line-data
            set myname item 1 line-data
            set sex item 2 line-data
            set shape "circle"
          ]
        ]
      ]
    ]
  
    while [not file-at-end?]     ;; Read all edge data and create edges, stop when no data left
    [
      set line-data split file-read-line ","
      let node1 one-of turtles with [userid = item 0 line-data]
      let node2 one-of turtles with [userid = item 1 line-data]
      ask node1 [create-link-with node2]
    ]
  ]
  file-close
  set show-names false
  reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display / hide names
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to toggle-name-display
  ifelse show-names
  [ 
    set show-names false
    ask turtles [set label ""]
  ]
  [
    set show-names true
    ask turtles [set label myname]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This reporter scans a string for a given separator and splits the spring into
;; substrings, returning these as a list. Code credit: Jim Lyons, on the 
;; netlogo-users mailing list
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to-report split [ #string #sep ] ;; #sep must be non-empty string
  let result []                  ;; return value
  let w length #sep
  loop                           ;; exit when done
  [ 
    let next-pos position #sep #string
    if not is-number? next-pos
    [ 
      report reverse (fput #string result) 
    ]
    set result fput (substring #string 0 next-pos) result
    set #string substring #string (next-pos + w) (length #string)
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
332
26
1016
731
25
25
13.22
1
12
1
1
1
0
0
0
1
-25
25
-25
25
0
0
1
ticks
30.0

BUTTON
21
140
148
173
NIL
import-network
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
21
208
119
241
layout-circle
layout-circle turtles circle-radius
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
21
244
193
277
circle-radius
circle-radius
0
25
20
1
1
NIL
HORIZONTAL

BUTTON
22
303
165
336
layout-spring (once)
layout-spring turtles links tautness spring-length repulsion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
22
378
194
411
tautness
tautness
0
2
0.2
0.05
1
NIL
HORIZONTAL

SLIDER
21
418
193
451
spring-length
spring-length
1
10
5
1
1
NIL
HORIZONTAL

SLIDER
20
458
192
491
repulsion
repulsion
0
10
1
1
1
NIL
HORIZONTAL

BUTTON
22
340
189
373
layout-spring (repeated)
layout-spring turtles links tautness spring-length repulsion
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
20
575
307
746
degree distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [count link-neighbors] of turtles"

BUTTON
22
537
149
570
show/hide names
toggle-name-display
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
28
20
308
122
A tool for visualizing a FaceBook personal network that has been imported as a .gdf text file using NetVizz
16
0.0
1

TEXTBOX
156
151
306
169
Do this first.
11
0.0
1

TEXTBOX
152
213
302
231
Then, choose a layout.
11
0.0
1

BUTTON
20
498
189
531
reset default layout pars
set circle-radius 20\nset tautness 0.20\nset spring-length 5\nset repulsion 1
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

This is a tool for visualizing a Facebook personal network that has been extracted from Facebook using the NetVizz application

## HOW IT WORKS

When the import-network button is clicked, the user is prompted to navigate to a `.gdf` file containing the Facebook network information. The file is read in, and turtles and links are created, corresponding to the nodes and edges in the `.gdf` file. It is assumed that the file has the following format:

The first line is a node definition header line, that looks like this:
`nodedef>name VARCHAR,label VARCHAR,sex VARCHAR,locale VARCHAR,agerank INT`

This is followed by multiple node data lines, for example:
`12345678,Savi Maharaj,female,en_GB,101`

Next is an edge definition header line, looking like this:
`edgedef>node1 VARCHAR,node2 VARCHAR`

Finally, there are multiple edge data lines, each containing a pair of numbers representing two nodes that are linked by an edge.

## HOW TO USE IT

First, it is necessary to import the personal network data from Facebook. To do this, follow these steps:

* Sign in to Facebook in a web browser.
* Go to `https://apps.facebook.com/netvizz/`
* Click on "personal network".
* Click on "Start", leaving the check box unticked.
* Right click on "gdf file", choose "Save as", and save the `.gdf` file on your computer. I recommend giving it a nicer name than the default one.


Once you have the `.gdf` file with your personal network data, you can import it into Netlogo:

* Click the `import-network` button to import the network data. 
* Then click one of the three layout buttons to arrange the nodes and edges nicely on the screen. The `layout-spring (repeated)` option is particularly good for arranging the nodes as connected communities, so that you can see the structure of your social network.
* Use the `show/hide names` button to see the names of your friends. 

## THINGS TO NOTICE

Who is at the centre of your social universe? Do all your friends tend to know each other, or can you spot distinct groups of friends?  

## THINGS TO TRY

Try changing the parameters used by the layout procedures. Can you improve on the defaults?

Try colouring nodes by sex. One way to do this is to use the command center to run the (observer) commands below. Change the colours to suit your taste.

`ask turtles with [sex = "female"] [set color red]`
`ask turtles with [sex = "male"] [set color blue]`

Try resizing nodes to show the number of connections. One way to do this is to use the command center to run the (observer) command below. The numbers control the minimum size of a node and the increase in size for each connection. Try out different values until you get a result you like.

`ask turtles [set size 0.5 + (count link-neighbors) * 0.08]`

## EXTENDING THE MODEL

Try adding a dynamic process to the network, such as spreading a rumour, or sharing a video.


## CREDITS AND REFERENCES

Written by Savi Maharaj, 19/02/2014 for CSC9YM, Modelling for Complex Systems, Division of Computing Science and Mathematics, University of Stirling, UK.

The code for splitting a string was taken from a post by Jim Lyons on the netlogo-users list.
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
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
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
0
@#$#@#$#@
