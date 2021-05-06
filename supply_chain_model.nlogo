; Initialize the breeds
breed [extractors extractor]
breed [manufacturers factory]
breed [hospitals hospital]
breed [patients patient]
breed [extr-transporters ex-truck]
breed [hosp-transporters hs-truck]

; Initialize internal values per breed


extr-transporters-own[
  load_capacity
  delivery_speed
  current_load
  heading_towards
  start_patch
  destination
]
hosp-transporters-own[
  load_capacity
  delivery_speed
  current_load
  start_patch
  destination
]
extractors-own[
  extractor_capacity
  extraction_rate
  raw_material_1_count
  raw_material_1_type

  raw_material_2_count
  raw_material_2_type

  raw_material_3_count
  raw_material_3_type

  raw_material_4_count
  raw_material_4_type
]
manufacturers-own[
  warehouse_capacity
  manufacturing_rate
  current_inven
]
hospitals-own[
  patient_capacity
  patient_count

  glove_stock
  ppe_stock
  mask_stock
  syringe_stock

  glove_capacity
  ppe_capacity
  mask_capacity
  syringe_capacity
]
patients-own[
  health
  start_patch
  destination
]

; Intialize environment
to setup

  clear-all
  reset-ticks

  ; Sets the default shape for every agents so that spawning is easy
  set-default-shape extractors "bulldozer top"
  set-default-shape manufacturers "factory"
  set-default-shape hospitals "hospital"
  set-default-shape patients "dot"
  set-default-shape extr-transporters "truck"
  set-default-shape hosp-transporters "truck"

  ; Create agents with hard-coded number for non-transporters
  create-extractors 2[
    set size 7
    set color yellow
    set heading 0
    set extractor_capacity extractor-capacity
  ]
  create-manufacturers 2[
    set size 10
    set color brown
    set warehouse_capacity manufacturer-capacity
  ]
  create-hospitals 2 [
    set size 15
    set color gray
    set patient_count 0
    set patient_capacity patient-capacity
    set glove_capacity glove-capacity
    set ppe_capacity ppe-capacity
    set mask_capacity mask-capacity
    set syringe_capacity syringe-capacity
  ]

   create-patients 100 [
    set size 2
    set color white
    set health initial-health
  ]

  create-extr-transporters (transporter_multiplier * 2)[
    set size  3
    set color red
    set load_capacity load-capacity
  ]

  create-hosp-transporters (transporter_multiplier * 2)[
    set size  3
    set color blue
    set load_capacity load-capacity
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

  ; Transporters heading to extractors
  set n 0
  foreach sort extr-transporters [ tr ->
   ask tr [

      (ifelse
        n mod 2 = 0 [
          setxy -8 5
        ][
          setxy -8 -13
        ]
      )

      set start_patch patch-here
      ; Set random heading
      ifelse coin-flip?
      [
        set heading towards turtle 0
        set destination (get_patch turtle 0)
      ]
      [
        set heading towards turtle 1
        set destination (get_patch turtle 1)
      ]


      display
      set n (n + 1)

    ]
  ]

  ; Transporters heading to hospitals
  set n 0
  foreach sort hosp-transporters [ tr ->
   ask tr [

      (ifelse
        n mod 2 = 0 [
          setxy 2 5
        ][
          setxy 2 -13
        ]
      )

      set start_patch patch-here
      ; Set random heading
      ifelse coin-flip?
      [
        set heading towards turtle 4
        set destination (get_patch turtle 4)
      ]
      [
        set heading towards turtle 5
        set destination (get_patch turtle 5)
      ]

      display
      set n (n + 1)

    ]
  ]

  ; Patients heading to hospitals
  ; NOTE: incomplete pa 'to
  set n 0
  foreach sort patients [ tr ->
   ask tr [

      (ifelse
        n mod 2 = 0 [
          setxy 2 5
        ][
          setxy 2 -13
        ]
      )

      set start_patch patch-here
      ; Set random heading
      ifelse coin-flip?
      [
        set heading towards turtle 4
        set destination (get_patch turtle 4)
      ]
      [
        set heading towards turtle 5
        set destination (get_patch turtle 5)
      ]

      display
      set n (n + 1)
    ]
  ]
end

; patients to move
to patient-move
  ask patients[

    ;uncomment for health decr (and death)
    ;set health health - 1

    let temp_dest 0
    if (patch-here = destination) [
      ;get rid of this later
      set temp_dest (destination)
      set destination (start_patch)
      set start_patch (temp_dest)
      set heading towards destination

      ; if hospital 4 [patient-capacity] is full then go to 5, if also full, then die
      ; Problem atm: How would you know which turtle/hospital it would go to?
      ; if patient_capacity is NOT full, then call <admit-patient>

    ]
    forward 1

    death
  ]
end

to admit-patient
  if patient_count < patient_capacity
  [
    set patient_count patient_count + 1
    ; how to stop patients from moving if ever while "getting treated" (?)
  ]
end

; Get the patch of a turtle
to-report get_patch [turt]

  let dest 0
  ask turt [
    set dest (patch-here)
  ]
  report dest
end

; Randomize choice
to-report coin-flip?
  report random 2 = 0
end

; Allows the transporters to move
to transport

  ask extr-transporters[
    let temp_dest 0
    if (patch-here = destination) [
      set temp_dest (destination)
      set destination (start_patch)
      set start_patch (temp_dest)
      set heading towards destination

    ]
    forward 1
  ]
  ask hosp-transporters[
    let temp_dest 0
    if (patch-here = destination) [
    ;if any? other hospitals in-radius 2[
      set temp_dest (destination)
      set destination (start_patch)
      set start_patch (temp_dest)
      set heading towards destination
    ]
    forward 1
  ]

end

; function to kill a patient if health reaches 0
to death
  if health < 0 [die]
end

; Function at each time step (tick)
to go
  transport
  patient-move
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
534
16
1325
474
-1
-1
12.85
1
10
1
1
1
0
0
0
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
372
445
436
478
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

BUTTON
454
445
517
478
Go
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

SLIDER
13
32
217
65
transporter_multiplier
transporter_multiplier
1
10
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
117
15
218
33
will be multiplied to 2
11
0.0
1

SLIDER
10
102
231
135
extractor-capacity
extractor-capacity
10
100
35.0
1
1
items
HORIZONTAL

SLIDER
1025
526
1235
559
extraction-rate
extraction-rate
10
100
50.0
1
1
items per tick
HORIZONTAL

TEXTBOX
15
81
165
99
Extractor variables
11
0.0
1

SLIDER
279
109
499
142
manufacturer-capacity
manufacturer-capacity
10
100
76.0
1
1
items
HORIZONTAL

SLIDER
1024
566
1237
599
manufacture-rate
manufacture-rate
10
100
50.0
1
1
items per tick
HORIZONTAL

TEXTBOX
288
90
438
108
Manufacturer variables
11
0.0
1

SLIDER
11
162
233
195
patient-capacity
patient-capacity
10
100
73.0
1
1
patients
HORIZONTAL

SLIDER
1262
528
1485
561
admission-rate
admission-rate
10
100
50.0
1
1
patients per tick
HORIZONTAL

SLIDER
1263
565
1486
598
release-rate
release-rate
0
100
50.0
1
1
patients per tick
HORIZONTAL

SLIDER
10
297
233
330
ppe-capacity
ppe-capacity
0
100
36.0
1
1
PPEs
HORIZONTAL

SLIDER
8
206
230
239
mask-capacity
mask-capacity
0
100
49.0
1
1
masks
HORIZONTAL

SLIDER
9
344
233
377
glove-capacity
glove-capacity
0
100
31.0
1
1
gloves
HORIZONTAL

SLIDER
7
250
230
283
syringe-capacity
syringe-capacity
0
100
35.0
1
1
syringes
HORIZONTAL

TEXTBOX
16
144
166
162
Hospital variables
11
0.0
1

TEXTBOX
285
156
435
174
Transporter variables
11
0.0
1

SLIDER
281
172
501
205
load-capacity
load-capacity
0
100
35.0
1
1
items
HORIZONTAL

TEXTBOX
1020
504
1170
522
Just for later (if ever)
11
15.0
1

TEXTBOX
286
214
436
232
Patient variables
11
0.0
1

SLIDER
281
231
507
264
initial-health
initial-health
0
100
50.0
1
1
NIL
HORIZONTAL

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
