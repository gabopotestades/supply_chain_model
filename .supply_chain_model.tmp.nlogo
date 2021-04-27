; Initialize the breeds
breed [patients patient]
breed [hospitals hospital]
breed [transporters truck]
breed [manufacturers factory]
breed [extractors extractor]

; Initialize internal values per breed
patients-own[
  health
]
hospitals-own[
  patient_capacity
  medicine_stock
  ppe_stock
  mask_stock
  syringe_stock
]
transporters-own[
  load_capacity
  delivery_speed
  current_load
]
manufacturers-own[
  warehouse_capacity
  manufacturing_rate
  current_inven
]
extractors-own[
  extractor_capacity
  extraction_rate
  raw_material_count
  raw_material_type
]

; Intialize environment
to setup

  clear-all
  reset-ticks

  ; Sets the default shape for every agents so that spawning is easy
  set-default-shape transporters "truck"
  set-default-shape manufacturers "factory"
  set-default-shape extractors "bulldozer top"
  set-default-shape hospitals "hospital"
  set-default-shape patients "dot"

  create-transporters 8
  create-manufacturers 2
  create-extractors 2
  create-hospitals 2
  ; create-patients 100

  ask transporters [
    set size  3
    set color blue
  ]

  ask manufacturers [
    set size 10
    set color brown
  ]

  ask extractors [
    set size 7
    set color yellow
    set heading 0
  ]

  ask hospitals [
    set size 15
    set color gray
  ]

  ask patients [
    set size 2
    set color white
  ]

  setup-positions

end

; Places each non-moving breed in the grid
to setup-positions

  ; Hospitals
  let n 9
  foreach sort hospitals [ h ->
   ask h [
      setxy 20 n
      set n (n - 18)
      display
    ]
  ]

  ; Manufacturers
  set n 9
  foreach sort manufacturers [ m ->
   ask m [
      setxy -3 n
      set n (n - 18)
      display
    ]
  ]

  ; Extractors
  set n 14
  foreach sort extractors [ ex ->
   ask ex [
      setxy -26 n
      set n (n - 28)
      display
    ]
  ]

  ; Transporters
  let x 0
  let y 0
  set n 0
  foreach sort transporters [ tr ->
   ask tr [

      (ifelse
        n >= 0 and n < 2 [
          ask truck n [
            setxy -8 5
          ]
        ]
        n >= 2 and n < 4 [
          ask truck n [
            setxy -4 -9
          ]
        ]
        n >= 4 and n < 6  [
          ask truck n [
            setxy 2
          ]
        ]
        n >= 6  [
          ask truck n [
            setxy 2 -9
          ]
        ]
      )

      set n (n + 1)

    ]
  ]

  ;ifelse coin-flip? [right random 100][left random 100]

end
@#$#@#$#@
GRAPHICS-WINDOW
542
13
1325
466
-1
-1
12.85
1
10
1
1
1
0
1
1
1
-30
30
-17
17
0
0
1
ticks
30.0

BUTTON
34
28
98
61
Setup
setup
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

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

bulldozer top
true
0
Rectangle -7500403 true true 195 60 255 255
Rectangle -16777216 false false 195 60 255 255
Rectangle -7500403 true true 45 60 105 255
Rectangle -16777216 false false 45 60 105 255
Line -16777216 false 45 75 255 75
Line -16777216 false 45 105 255 105
Line -16777216 false 45 60 255 60
Line -16777216 false 45 240 255 240
Line -16777216 false 45 225 255 225
Line -16777216 false 45 195 255 195
Line -16777216 false 45 150 255 150
Polygon -1184463 true true 90 60 75 90 75 240 120 255 180 255 225 240 225 90 210 60
Polygon -16777216 false false 225 90 210 60 211 246 225 240
Polygon -16777216 false false 75 90 90 60 89 246 75 240
Polygon -16777216 false false 89 247 116 254 183 255 211 246 211 211 90 210
Rectangle -16777216 false false 90 60 210 90
Rectangle -1184463 true true 180 30 195 90
Rectangle -16777216 false false 105 30 120 90
Rectangle -1184463 true true 105 45 120 90
Rectangle -16777216 false false 180 45 195 90
Polygon -16777216 true false 195 105 180 120 120 120 105 105
Polygon -16777216 true false 105 199 120 188 180 188 195 199
Polygon -16777216 true false 195 120 180 135 180 180 195 195
Polygon -16777216 true false 105 120 120 135 120 180 105 195
Line -1184463 true 105 165 195 165
Circle -16777216 true false 113 226 14
Polygon -1184463 true true 105 15 60 30 60 45 240 45 240 30 195 15
Polygon -16777216 false false 105 15 60 30 60 45 240 45 240 30 195 15

circle
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

hospital
false
0
Rectangle -7500403 true true 90 75 210 285
Polygon -1 true false 210 285 255 255 255 45 210 75
Polygon -13345367 true false 90 75 45 45 45 255 90 285
Polygon -11221820 true false 45 45 90 15 210 15 255 45 210 75 90 75
Rectangle -2674135 true false 135 30 165 120
Rectangle -2674135 true false 105 60 195 90

line
true
0
Line -7500403 true 150 0 150 300

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

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
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
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
