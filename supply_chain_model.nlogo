; Initialize globals
globals[
  roads
  first-ex-patches
  second-ex-patches
  extractor-pick-ups
  manufacturer-drop-offs
  hospital-drop-offs
  intersections
  dead-patients
  cured-patients
]

; Initialize the breeds
breed [extractors extractor]
breed [manufacturers factory]
breed [hospitals hospital]
breed [extr-transporters ex-truck]
breed [hosp-transporters hs-truck]
breed [patients patient]

; Initialize internal values per breed
extr-transporters-own[
  raw_material_1_count
  raw_material_2_count
  raw_material_3_count
  raw_material_4_count
  start_patch
  destination
  destination_type
]
hosp-transporters-own[
  glove_stock
  ppe_stock
  mask_stock
  syringe_stock
  start_patch
  destination
  destination_type
]
extractors-own[
  extractor_capacity
  raw_material_1_count
  raw_material_2_count
  raw_material_3_count
  raw_material_4_count
]
manufacturers-own[
  raw_material_1_count
  raw_material_2_count
  raw_material_3_count
  raw_material_4_count
  glove_stock
  ppe_stock
  mask_stock
  syringe_stock
]
hospitals-own[
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

  setup-patches
  setup-agents
  setup-positions

end

; Setup roads and patches
to setup-patches

    ask patches [
    set pcolor green + 3
    ]

  ;; initialize the global variables that hold patch agentsets
  set roads patches with [
    ; left vertical road
    (pxcor = -10 and pycor < 4 and pycor > -14) or
    ; right vertical road
    (pxcor = 10 and pycor < 4 and pycor > -14) or
    ; patients road
    (pxcor = 26 and pycor < 4 and pycor > -14) or
    ; top horizontal road
    (pycor = 3) or
    ; bottom horizontal road
    (pycor = -13)
  ]

  set intersections roads with [
    (pxcor = -10 and pycor = 3) or
    (pxcor = -10 and pycor = -13) or
    (pxcor = 10 and pycor = 3) or
    (pxcor = 10 and pycor = -13) or
    (pxcor = 26 and pycor = 3) or
    (pxcor = 26 and pycor = -13)
  ]

  ; Set patches to be traveled by the upper extractor
  set first-ex-patches patches with [
    (pxcor >= -30 and pxcor < -10) and
    pycor > 3
  ]

  ; Set patches to be traveled by the lower  extractor
  set second-ex-patches patches with [
    (pxcor >= -30 and pxcor < -10) and
    (pycor > -13 and pycor < 3)
  ]

  ; Set patches to be the pickup point
  set extractor-pick-ups patches with [

    (pycor = 3 or pycor = -13) and
   (pxcor > -23 and pxcor < -19)

  ]

  ; Set patches to be the drop off point from extractor to manufacturers
  set manufacturer-drop-offs patches with [

    (pycor = 3 or pycor = -13) and
   (pxcor > -1 and pxcor < 3)

  ]

  ; Set patches to be the drop off point from manufacturers to hospitals
  set hospital-drop-offs patches with [

    (pycor = 3 or pycor = -13) and
   (pxcor > 18 and pxcor < 22)

  ]

  ; Set colors of patches
  ask first-ex-patches [ set pcolor grey + 2]
  ask second-ex-patches [ set pcolor grey + 2]
  ask roads [ set pcolor white ]
  ask extractor-pick-ups [set pcolor yellow + 2]
  ask manufacturer-drop-offs [set pcolor brown + 2]
  ask hospital-drop-offs [set pcolor red + 2]

end

; Create agents with specific designs
to setup-agents

  ; Sets the default shape for every agents so that spawning is easy
  set-default-shape extractors "bulldozer top"
  set-default-shape manufacturers "factory"
  set-default-shape hospitals "hospital"
  set-default-shape patients "dot"
  set-default-shape extr-transporters "truck"
  set-default-shape hosp-transporters "truck"

  ; Create agents with hard-coded number for non-transporters
  create-extractors 2[
    set size 5
    set color yellow
    set heading 0
    set extractor_capacity extractor-capacity
    set raw_material_1_count 0
    set raw_material_2_count 0
    set raw_material_3_count 0
    set raw_material_4_count 0
  ]
  create-manufacturers 2[
    set size 12
    set color brown
    set raw_material_1_count manufacturer-raw-capacity
    set raw_material_2_count manufacturer-raw-capacity
    set raw_material_3_count manufacturer-raw-capacity
    set raw_material_4_count manufacturer-raw-capacity
    set glove_stock 0
    set ppe_stock 0
    set mask_stock 0
    set syringe_stock 0
  ]
  create-hospitals 2 [
    set size 12
    set color gray
    set patient_count 0
    set glove_capacity glove-capacity
    set ppe_capacity ppe-capacity
    set mask_capacity mask-capacity
    set syringe_capacity syringe-capacity
    set glove_stock glove-capacity
    set ppe_stock ppe-capacity
    set mask_stock mask-capacity
    set syringe_stock syringe-capacity
  ]

   create-patients initial-count [
    set size 1
    set color orange
    set health initial-health
  ]

  create-extr-transporters (transporter-multiplier * 2)[
    set size  2
    set color red
    set destination_type "delivery"
    set raw_material_1_count 0
    set raw_material_2_count 0
    set raw_material_3_count 0
    set raw_material_4_count 0
  ]

  create-hosp-transporters (transporter-multiplier * 2)[
    set size  2
    set color blue
    set destination_type "delivery"
    set glove_stock load-capacity
    set ppe_stock load-capacity
    set mask_stock load-capacity
    set syringe_stock load-capacity
  ]

end

; Places each non-moving breed in the grid
to setup-positions

  set dead-patients 0
  set cured-patients 0

  ; Hospitals
  let n 9
  foreach sort hospitals [ h ->
   ask h [
      setxy 20 n
      set n (n - 16)
      display
    ]
  ]

  ; Manufacturers
  set n 8.3
  foreach sort manufacturers [ m ->
   ask m [
      setxy 0 n
      set n (n - 16)
      display
    ]
  ]

  ; Extractors

  ask extractor 0 [
    move-to one-of first-ex-patches
  ]
  ask extractor 1 [
    move-to one-of second-ex-patches
  ]

  ; Transporters heading to extractors
  set n 0
  foreach sort extr-transporters [ tr ->
   ask tr [

      (ifelse
        n mod 2 = 0 [
          set start_patch patch 1 3
          setxy 1 3
        ][
          set start_patch patch 1 -13
          setxy 1 -13
        ]
      )

      ; Set random heading
      ifelse coin-flip?
      [
        set destination patch -21 3
      ]
      [
        set destination patch -21 -13
      ]

      set heading 270
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
          set start_patch patch 1 3
          setxy 1 3
        ][
          set start_patch patch 1 -13
          setxy 1 -13
        ]
      )

      ; Set random heading
      ifelse coin-flip?
      [
        set destination patch 20 3
      ]
      [
        set destination patch 20 -13
      ]

      set heading 90
      display
      set n (n + 1)

    ]
  ]

  foreach sort patients [ tr ->
   ask tr [


      ifelse coin-flip?
      [
        set start_patch patch 30 3
        setxy 30 3
        ; set heading towards turtle 4
        set destination patch 20 3
      ]
      [
        set start_patch patch 30 -13
        setxy 30 -13
        ; set heading towards turtle 5
        set destination patch 20 -13
      ]

      set heading -90
      display
    ]
  ]
end

; Patients action each time step
to patient-move foreach sort patients [p ->
  ; for every patient
  ask p [
    ; check if the patient is already at a hospital
    ifelse (patch-here = destination)
    [
      ; if the patient is at a hospital,
      let hosp_number 0
      ; get which hospital the patient is at
      ifelse [pycor] of patch-here = 3
      [
        set hosp_number 4
      ]
      [
        set hosp_number 5
      ]

        set shape "circle"
        ; only do the logic below if the patient is not yet admitted (color != green)
        ifelse (color != green)
        [

        ; increment patient count in the hospital if the patient is already in the hospital
        ask hospital hosp_number
        [
          ; if there is a slot in the current hospital, admit self
          ifelse ((patient_count + 1) <= patient-capacity)
          [
            print "admitting self"
            set patient_count patient_count + 1
            set syringe_stock syringe_stock - 1 ; decrement dextrose on patient admission
            ask p [
              set color green
              ;hide-turtle
              set size 1
            ]
          ]
          [
            ; else reroute the patient to another hospital
            ask p
            [

              ; only reroute the patients that are not healing
              if (color != green)
              [
                ; try to reroute even if the other hospital is full, there might be a slot when we  get there

                ; Change the start_patch and destination
                ; To be used for rotation when rerouting
                ifelse [pycor] of patch-here = 3
                [
                  set start_patch patch 30 3
                  set destination patch 20 -13
                  set color violet

                ]
                [
                  set start_patch patch 30 -13
                  set destination patch 20 3
                  set color magenta
                ]
                ; Set different visuals to discern
                ; if the patient is rerouting
                  ; print "moving to another hospital"
                  ask hospital hosp_number
                    [
                      ;print "patient died from waiting"
                      set patient_count patient_count - 1
                    ]
                  show-turtle
                  set shape "square"
                  show-turtle
                  rt 180
                  ; add the chance that the patient will die in transport
                  set health health - 1
                  death
                  forward 1
                ]
              ]
            ]
          ]
      ]
      [
        ; these agents are already at the hospital but there is a chance that they are not yet admitted
        ask hospital hosp_number
        [
          ; further check if there are stocks
          ifelse(mask_stock > 0)
            [
              ask p
              [
                ; set the patient's color to green (healing)
                set color green
                ifelse (health >= 90)
                [
                  ; print "now healthy, discharging patient alive"
                  discharge
                  die
                  ; discharge alive
                  ask hospital hosp_number
                  [
                    set patient_count patient_count - 1
                  ]
                ]
                [
                  ; decrement hospital stock at each time step for each patient
                  ask hospital hosp_number
                  [
                    ; set glove_stock glove_stock - 1
                    ; set ppe_stock ppe_stock - 1
                    set mask_stock mask_stock - 1
                    ; set syringe_stock syringe_stock - 1
                  ]
                  ; and heal the patient
                  ; print "HEALING THE PATIENT"
                  set health health + 1
                ]
              ]
          ]
          [
            ; if admitted but no stocks, decrease health
            ask p
            [
              ;print "admitted but no stock of medical equipment. decreasing health"
              ; set color orange
              ; wait to die here instead

              set health health - 1
              death
              if (health = 0)
              [
                ;print "admitted but died because no stock of medical equipment"
                ; discharge dead
                ask hospital hosp_number
                [
                   set patient_count patient_count - 1
                ]
              ]
            ]
          ]
        ]
      ]
    ]

    [
      set health health - 1
      death ; patient died on the road
      rotate-moving-patient
      forward 1
      display
    ]

  ]
]
end

; Allows the patient to rotate on roads while rerouting
to rotate-moving-patient ; patient procedure

  let x_start [pxcor] of start_patch
  let y_start [pycor] of start_patch
  let x_dest  [pxcor] of destination
  let y_dest  [pycor] of destination
  let x_cur   [pxcor] of patch-here
  let y_cur   [pycor] of patch-here

    if
    (
      ; Check if the current patch is an intersection
      (member? patch-here intersections) and
      (y_start != y_dest)
    )
    [
      ;; COORDINATES GUIDE ;;
      (
      ifelse
      ( y_dest != y_cur) ; Horizontal lane
      [
        (
         ifelse
         y_dest = -13 and y_cur = 3 ; From top hospital going to the bottom hospital
         [
            rt 90
         ]
         y_dest = 3 and y_cur = -13 ; From bottom hospital going to the top hospital
         [
            rt -90
         ]
        )
      ]
      (y_dest = y_cur) ; Vertical lane
      [
        (
          ifelse
          y_dest = -13 and y_start = 3 ; From the top hospital going to the bottom hospital
          [
            rt 90
          ]
          y_dest = 3 and y_start = -13 ; From the bottom hospital going to the top hospital
          [
            rt -90
          ]
        )
      ]
      )

    ]

end

; Creates a patient in near the hospitals
to spawn-patient

  if random 10 = 0
  [
    create-patients 1
    [
      set size 1
      set color orange
      ifelse coin-flip?
      [
        set start_patch patch 30 3
        setxy 30 3
        set destination patch 20 3
      ]
      [
        set start_patch patch 30 -13
        setxy 30 -13
        set destination patch 20 -13
      ]
      set health initial-health
      set heading -90
      ; set destination [patch xcor ycor] of one-of hospitals
      ; set heading towards one-of hospitals-on destination
    ]
  ]


end

; Get the patch of a turtle
to-report get-patch [turt]

  let dest 0
  ask turt [
    set dest (patch-here)
  ]
  report dest
end

; Get the x coordinate of a turtle
to-report get-coords-x [turt]

  let x 0
  ask turt [
   set x (xcor)
  ]

  report x
end

; Get the y coordinate of a turtle
to-report get-coords-y [turt]

  let y 0
  ask turt [
   set y (ycor)
  ]

  report y
end

; Randomize choice
to-report coin-flip?
  report random 2 = 0
end

; Allows the extractor transporters to change lanes
to rotate-ext-transporters ; ext-transpoter procedure

  let x_start [pxcor] of start_patch
  let y_start [pycor] of start_patch
  let x_dest  [pxcor] of destination
  let y_dest  [pycor] of destination
  let x_cur   [pxcor] of patch-here
  let y_cur   [pycor] of patch-here

    ; 3 or -13
    if
    (
      ; Check if the current patch is an intersection
      (member? patch-here intersections) and
      (y_start != y_dest)
    )
    [
      ;; COORDINATES GUIDE;;
      ; 2 is the x coordinate of the manufacturers
      ; -21 is the x coordinate of the extractors pickup point
      ; 3 is the y coordinate of the upper lane
      ; -13 is the y coordinate of the lower lane

      (
      ifelse
      ; If the the transporter is a horizontal road
      ( y_dest != y_cur and y_start != y_dest)
      [
        (
          ifelse
          x_dest = 1 and y_cur = 3 ; Going to a manufacturer on the lower lane
          [
            rt 90
          ]
          x_dest = 1 and y_cur = -13 ; Going to a manufacturer on the upper lane
          [
            rt -90
          ]
          x_dest = -21 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt -90
          ]
          x_dest = -21 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
        )
      ]
      ; If the transporter is in a vertical road
      (y_dest = y_cur and y_start != y_dest)
      [
        (
          ifelse
          x_dest = 1 and y_cur = 3 ; Going to a manufacturer on the lower lane
          [
            rt 90
          ]
          x_dest = 1 and y_cur = -13 ; Going to a manufacturer on the upper lane
          [
            rt -90
          ]
          x_dest = -21 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt -90
          ]
          x_dest = -21 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
        )
      ]
      )

    ]

end

; Allows the hospital transporters to change lanes
to rotate-hosp-transporters ;  hosp-transporter procedure

  let x_start [pxcor] of start_patch
  let y_start [pycor] of start_patch
  let x_dest  [pxcor] of destination
  let y_dest  [pycor] of destination
  let x_cur   [pxcor] of patch-here
  let y_cur   [pycor] of patch-here

    ; 3 or -13
    if
    (
      ; Check if the current patch is an intersection
      (member? patch-here intersections) and
      (y_start != y_dest)
    )
    [
      ;; COORDINATES GUIDE;;
      ; 2 is the x coordinate of the manufacturers
      ; -21 is the x coordinate of the extractors pickup point
      ; 3 is the y coordinate of the upper lane
      ; -13 is the y coordinate of the lower lane

      (
      ifelse
      ; If the transporter is in a vertical road turning at a horizontal road
      ( y_dest != y_cur and y_start != y_dest)
      [
        (
          ifelse
          x_dest = 1 and y_cur = 3 ; Going to a manufacturer on the lower lane
          [
            rt -90
          ]
          x_dest = 1 and y_cur = -13 ; Going to a manufacturer on the upper lane
          [
            rt 90
          ]
          x_dest = 20 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
          x_dest = 20 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt -90
          ]
        )
      ]
      ; If the transporter is in a horizontal road turning at a vertical road
      (y_dest = y_cur and y_start != y_dest)
      [
        (
          ifelse
          x_dest = 1 and y_cur = 3 ; Going to a manufacturer on the lower lane
          [
            rt -90
          ]
          x_dest = 1 and y_cur = -13 ; Going to a manufacturer on the upper lane
          [
            rt 90
          ]
          x_dest = 20 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
          x_dest = 20 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt -90
          ]
        )
      ]

      )

    ]

end

; Allows the hospital that are rotating to change lanes
to rotate-rerouting-hosp-transporters

  let x_start [pxcor] of start_patch
  let y_start [pycor] of start_patch
  let x_dest  [pxcor] of destination
  let y_dest  [pycor] of destination
  let x_cur   [pxcor] of patch-here
  let y_cur   [pycor] of patch-here

     ; Check if the current patch is an intersection
    if
    ( member? patch-here intersections )
    [
     (

      ifelse
      (y_start = -13 and y_dest = 3) ; Going from bottom hospital to top
       [
         rt 90
       ]
      (y_start = 3 and y_dest = -13); Going from top hospital to bottom
       [
         lt 90
       ]

     )
    ]

end

; Allows the extractor transporters to move
to extractor-transport ; extractor transporter procedure

  ; Transports the raw materials to the manufacturer
  ask extr-transporters[

    ; If the tranporter reached its destination
    if (patch-here = destination)
    [

      let tran_cur_raw_mat1_count raw_material_1_count
      let tran_cur_raw_mat2_count raw_material_2_count
      let tran_cur_raw_mat3_count raw_material_3_count
      let tran_cur_raw_mat4_count raw_material_4_count

      (

        ; Check if y-coordinate is 3 (upper extractor)
        ; or -13 (lower extractor)
        ifelse
        (member? patch-here extractor-pick-ups)
        [

          let extractor_number 0
          ifelse [pycor] of patch-here = 3
          [ set extractor_number 0 ]
          [ set extractor_number 1 ]

          ; Set the temporary raw materials values available to get
          let raw_mat1_to_get (load-capacity - raw_material_1_count)
          let raw_mat2_to_get (load-capacity - raw_material_2_count)
          let raw_mat3_to_get (load-capacity - raw_material_3_count)
          let raw_mat4_to_get (load-capacity - raw_material_4_count)

          ask extractor extractor_number
          [
            ; Get the raw materials from the extractors
            ; Ensures that the raw material to get is not more than the available
            ; raw material in the extractor
            ifelse raw_mat1_to_get <= raw_material_1_count
            [ set raw_material_1_count (raw_material_1_count - raw_mat1_to_get) ]
            [
              set raw_mat1_to_get raw_material_1_count
              set raw_material_1_count 0
            ]

            ifelse raw_mat2_to_get <= raw_material_2_count
            [ set raw_material_2_count (raw_material_2_count - raw_mat2_to_get) ]
            [
              set raw_mat2_to_get raw_material_2_count
              set raw_material_2_count 0
            ]

            ifelse raw_mat3_to_get <= raw_material_3_count
            [ set raw_material_3_count (raw_material_3_count - raw_mat3_to_get) ]
            [
              set raw_mat3_to_get raw_material_3_count
              set raw_material_3_count 0
            ]

            ifelse raw_mat4_to_get <= raw_material_4_count
            [ set raw_material_4_count (raw_material_4_count - raw_mat4_to_get) ]
            [
              set raw_mat4_to_get raw_material_4_count
              set raw_material_4_count 0
            ]

         ]

          ; After getting the raw materials,
          ; store in the transporter's value
          set raw_material_1_count raw_mat1_to_get
          set raw_material_2_count raw_mat2_to_get
          set raw_material_3_count raw_mat3_to_get
          set raw_material_4_count raw_mat4_to_get

          ; Switch start patch and destination patch
          let temp_dest (destination)
          set destination (start_patch)
          set start_patch (temp_dest)

       ]

        ; Check if y-coordinate is 3 (upper manufacturer)
        ; or -13 (lower manufacturer)
        (member? patch-here manufacturer-drop-offs)
        [

          let manuf_number 0
          ifelse [pycor] of patch-here = 3
          [ set manuf_number 2 ]
          [ set manuf_number 3 ]

          ; Set the temporary raw materials values available to get
          let raw_mat1_to_give raw_material_1_count
          let raw_mat2_to_give raw_material_2_count
          let raw_mat3_to_give raw_material_3_count
          let raw_mat4_to_give raw_material_4_count

          ask factory manuf_number
          [

            ; Add current inventory to the manufacturer destination
            let cur_raw_mat1 raw_material_1_count
            let cur_raw_mat2 raw_material_2_count
            let cur_raw_mat3 raw_material_3_count
            let cur_raw_mat4 raw_material_4_count

            ;;;;;;;;;;;;;;;;;;;;
            ;; Raw Material 1 ;;
            ;;;;;;;;;;;;;;;;;;;;
            ifelse ( raw_mat1_to_give + cur_raw_mat1 ) <= manufacturer-raw-capacity
            [
              set raw_material_1_count ( raw_mat1_to_give + cur_raw_mat1 ) ; add raw material, limit is the manufacturer capacity
              set raw_mat1_to_give 0
            ]
            [
              set raw_mat1_to_give ( raw_mat1_to_give - ( manufacturer-raw-capacity - cur_raw_mat1 ) )
              set raw_material_1_count manufacturer-raw-capacity ; considered as full
            ]

            ;;;;;;;;;;;;;;;;;;;;
            ;; Raw Material 2 ;;
            ;;;;;;;;;;;;;;;;;;;;
            ifelse ( raw_mat2_to_give + cur_raw_mat2 ) <= manufacturer-raw-capacity
            [
              set raw_material_2_count ( raw_mat2_to_give + cur_raw_mat2 ) ; add raw material, limit is the manufacturer capacity
              set raw_mat2_to_give 0
            ]
            [
              set raw_mat2_to_give ( raw_mat2_to_give - ( manufacturer-raw-capacity - cur_raw_mat2 ) )
              set raw_material_2_count manufacturer-raw-capacity ; considered as full
            ]

            ;;;;;;;;;;;;;;;;;;;;
            ;; Raw Material 3 ;;
            ;;;;;;;;;;;;;;;;;;;;
            ifelse ( raw_mat3_to_give + cur_raw_mat3 ) <= manufacturer-raw-capacity
            [
              set raw_material_3_count ( raw_mat3_to_give + cur_raw_mat3 ) ; add raw material, limit is the manufacturer capacity
              set raw_mat3_to_give 0
            ]
            [
              set raw_mat3_to_give ( raw_mat3_to_give - ( manufacturer-raw-capacity - cur_raw_mat3 ) )
              set raw_material_3_count manufacturer-raw-capacity ; considered as full
            ]

            ;;;;;;;;;;;;;;;;;;;;
            ;; Raw Material 4 ;;
            ;;;;;;;;;;;;;;;;;;;;
            ifelse ( raw_mat4_to_give + cur_raw_mat4 ) <= manufacturer-raw-capacity
            [
              set raw_material_4_count ( raw_mat4_to_give + cur_raw_mat4 ) ; add raw material, limit is the manufacturer capacity
              set raw_mat4_to_give 0
            ]
            [
              set raw_mat4_to_give ( raw_mat4_to_give - ( manufacturer-raw-capacity - cur_raw_mat4 ) )
              set raw_material_4_count manufacturer-raw-capacity ; considered as full
            ]

          ]

          ; raw_mat_to_give becomes the remaining
          ; raw material of the transporter
          set raw_material_1_count (raw_mat1_to_give)
          set raw_material_2_count (raw_mat2_to_give)
          set raw_material_3_count (raw_mat3_to_give)
          set raw_material_4_count (raw_mat4_to_give)
          let remaining_stocks 0

          set remaining_stocks (raw_material_1_count + raw_material_2_count + raw_material_3_count + raw_material_4_count)

          ; Switch start patch and destination patch
          set start_patch (patch-here)

          ; If there are remaining cargo, reroute
          ifelse remaining_stocks > ((manufacturer-raw-capacity * 4) * reroute-threshold) [
            set destination_type "reroute"
            ifelse [pycor] of patch-here = 3
            [ set destination patch 1 -13 ]
            [ set destination patch 1  3  ]
          ]
          [
            set destination_type "delivery"

            let extractor0_stocks 0
            let extractor1_stocks 0

            ask extractor 0
            [ set extractor0_stocks (raw_material_1_count + raw_material_2_count + raw_material_3_count + raw_material_4_count) ]

            ask extractor 1
            [ set extractor1_stocks (raw_material_1_count + raw_material_2_count + raw_material_3_count + raw_material_4_count) ]


            ; Check which factory has more stocks
            ifelse extractor0_stocks > extractor1_stocks
            [ set destination patch -21  3 ]
            [ set destination patch -21 -13 ]

          ]

        ]

      )

      ; Rotate to go back
      rt 180

    ]

    ; Rotate if in an intersection
    ifelse destination_type = "delivery"
    [
    rotate-ext-transporters
    ]
    [
     rotate-rerouting-hosp-transporters
    ]


    forward 1
    display
  ]

end

; Allows the hospital transporters to move
to hospital-transport ; hospital transporter procedure

  ; Transports the manufactured goods to the hospitals
  ask hosp-transporters[

    if (patch-here = destination) [

      ; Place current stock per item
      ; in a temporary variable
      let cur_glove_stock   glove_stock
      let cur_ppe_stock     ppe_stock
      let cur_mask_stock    mask_stock
      let cur_syringe_stock  syringe_stock
      let remaining_stocks 0

      (

        ; Check if y-coordinate is 3 (upper hospital)
        ; or -13 (lower hospital)
        ifelse (member? patch-here hospital-drop-offs)
        [

          let hosp_number 0
          ifelse [pycor] of patch-here = 3
          [ set hosp_number 4 ]
          [ set hosp_number 5 ]


          ask hospital hosp_number [

            ; Add stock to the hospital destination
            let stocks_to_be_transferred 0

            ; Glove stock of hospital
            ifelse (glove_stock + cur_glove_stock <= glove_capacity)
            [
              set glove_stock ( glove_stock + cur_glove_stock )
              set cur_glove_stock 0
            ]
            [
              set cur_glove_stock ( cur_glove_stock - ( glove_capacity - glove_stock) )
              set glove_stock glove_capacity
            ]

            ; PPE stock of hospital
            ifelse (ppe_stock + cur_ppe_stock <= ppe_capacity)
            [
              set ppe_stock ( ppe_stock + cur_ppe_stock )
              set cur_ppe_stock 0
            ]
            [
              set cur_ppe_stock ( cur_ppe_stock - ( ppe_capacity - ppe_stock) )
              set ppe_stock ppe_capacity
            ]


            ; Masks stock of hospital
            ifelse (mask_stock + cur_mask_stock <= mask_capacity)
            [
              set mask_stock ( mask_stock + cur_mask_stock )
              set cur_mask_stock 0
            ]
            [
              set cur_mask_stock ( cur_mask_stock - ( mask_capacity - mask_stock) )
              set mask_stock mask_capacity
            ]

            ; Syringe stock of hospital
            ifelse (syringe_stock + cur_syringe_stock <= syringe_capacity)
            [
              set syringe_stock (syringe_stock + cur_syringe_stock )
              set cur_syringe_stock 0
            ]
            [
              set cur_syringe_stock ( cur_syringe_stock - ( syringe_capacity - syringe_stock) )
              set syringe_stock syringe_capacity
            ]


          ]

          ; Set the current stock of the transporters
          ; based on the stock that was given to the hospitals
          set glove_stock   cur_glove_stock
          set ppe_stock     cur_ppe_stock
          set mask_stock    cur_mask_stock
          set syringe_stock cur_syringe_stock
          set remaining_stocks (cur_glove_stock + cur_ppe_stock + cur_mask_stock + cur_syringe_stock)


          ; Switch start patch and destination patch
          set start_patch (patch-here)

          ; If there are remaining cargo, reroute
          ; ifelse remaining_stocks > ((load-capacity * 4) * reroute-threshold) [
          ifelse mask_stock > mask_stock * reroute-threshold [
            set destination_type "reroute"
            ifelse [pycor] of patch-here = 3
            [ set destination patch 20 -13 ]
            [ set destination patch 20  3  ]
          ]
          [
            set destination_type "delivery"

            let factory2_stocks 0
            let factory3_stocks 0

            ask factory 2
            [ set factory2_stocks (glove_stock + ppe_stock + mask_stock + syringe_stock) ]

            ask factory 3
            [ set factory3_stocks (glove_stock + ppe_stock + mask_stock + syringe_stock) ]


            ; Check which factory has more stocks
            ifelse factory2_stocks > factory3_stocks
            [ set destination patch 1   3 ]
            [ set destination patch 1 -13 ]

          ]
        ]

        ; Check if y-coordinate is 3 (upper manufacturer)
        ; or -13 (lower manufacturer)
        (member? patch-here manufacturer-drop-offs)
        [
          let manuf_number 0
          ifelse [pycor] of patch-here = 3
          [ set manuf_number 2 ]
          [ set manuf_number 3 ]

          ask factory manuf_number
          [

            ; Deduct from inventory of a manufacturer

            ;;;;;;;;;;;;;;;;
            ; Gloves stock ;
            ;;;;;;;;;;;;;;;;
            ifelse (cur_glove_stock + glove_stock) <= load-capacity
            [
              set cur_glove_stock ( cur_glove_stock + glove_stock )
              set glove_stock 0
            ]
            [
              set glove_stock (glove_stock - (load-capacity - cur_glove_stock))
              set cur_glove_stock load-capacity
            ]

            ;;;;;;;;;;;;;;;;
            ;  PPE stock   ;
            ;;;;;;;;;;;;;;;;
            ifelse (cur_ppe_stock + ppe_stock) <= load-capacity
            [
             set cur_ppe_stock ( cur_ppe_stock + ppe_stock )
             set ppe_stock 0
            ]
            [
              set ppe_stock (ppe_stock - (load-capacity - cur_ppe_stock))
              set cur_ppe_stock load-capacity
            ]

            ;;;;;;;;;;;;;;;;
            ; Masks stock  ;
            ;;;;;;;;;;;;;;;;
            ifelse (cur_mask_stock + mask_stock) <= load-capacity
            [
              set cur_mask_stock ( cur_mask_stock + mask_stock )
              set mask_stock 0
            ]
            [
              set mask_stock (mask_stock - (load-capacity - cur_mask_stock))
              set cur_mask_stock load-capacity
            ]

            ;;;;;;;;;;;;;;;;
            ;;Syringe stock;
            ;;;;;;;;;;;;;;;;
            ifelse (cur_syringe_stock + syringe_stock) <= load-capacity
            [
              set cur_syringe_stock ( cur_syringe_stock + syringe_stock )
              set syringe_stock 0
            ]
            [
              set syringe_stock (syringe_stock - (load-capacity - cur_syringe_stock))
              set cur_syringe_stock load-capacity
            ]

          ]

          ; The "cur" variables are now the
          ; actual current stock per item
          set glove_stock    (cur_glove_stock)
          set ppe_stock      (cur_ppe_stock)
          set mask_stock     (cur_mask_stock)
          set syringe_stock  (cur_syringe_stock)

          ; Switch start patch and destination patch
          let temp_dest (destination)
          set destination (start_patch)
          set start_patch (temp_dest)

        ]

      )


      ; Rotate to go back
      rt 180

    ]

    ifelse destination_type = "delivery"
    [
     rotate-hosp-transporters
    ]
    [
     rotate-rerouting-hosp-transporters
    ]

    forward 1
    display

  ]

end

; Allows the extractors to extract
to extract ; extractor procedure

  ask extractors
  [
    ; Extract each raw material individually
    let extracted_1 random extraction-rate-prob
    let extracted_2 random extraction-rate-prob
    let extracted_3 random extraction-rate-prob
    let extracted_4 random extraction-rate-prob

    ; Add the extracted to the current count per raw material
    set raw_material_1_count (raw_material_1_count + extracted_1)
    set raw_material_2_count (raw_material_2_count + extracted_2)
    set raw_material_3_count (raw_material_3_count + extracted_3)
    set raw_material_4_count (raw_material_4_count + extracted_4)

    ; If the current count is greater than capacity, limit to capacity
    if raw_material_1_count > extractor-capacity [set raw_material_1_count extractor-capacity]
    if raw_material_2_count > extractor-capacity [set raw_material_2_count extractor-capacity]
    if raw_material_3_count > extractor-capacity [set raw_material_3_count extractor-capacity]
    if raw_material_4_count > extractor-capacity [set raw_material_4_count extractor-capacity]

    ; Turn around if the current location is at the edge
    if patch-ahead 1 = nobody or [pcolor] of patch-ahead 1 != grey + 2
    [
      rt 180
    ]

    ; Move every 10 seconds
    if ticks mod 10 = 0
    [
      rt random 40
      lt random 40
      fd 0.5
    ]

  ]

end

; Allows the manufacturers to create products
; depending on the available raw materials
to manufacture ; manufacturer procedure

  ; manufacturing rate
  ; used to random counts in creating a product
  let glove_random random manufacture-rate
  let ppe_random random manufacture-rate
  let mask_random random manufacture-rate
  let syringe_random random manufacture-rate

  ask manufacturers
  [

    if ; Create a pair of gloves
    raw_material_1_count >= 1 and
    raw_material_2_count >= 1 and
    raw_material_3_count >= 1 and
    raw_material_4_count >= 1
    [
      set glove_stock (glove_stock + glove_random)
      set raw_material_1_count ( raw_material_1_count - 1 )
      set raw_material_2_count ( raw_material_2_count - 1 )
      set raw_material_3_count ( raw_material_3_count - 1 )
      set raw_material_4_count ( raw_material_4_count - 1 )
    ]

    if ; Create a PPE
    raw_material_1_count >= 1 and
    raw_material_2_count >= 1 and
    raw_material_3_count >= 1 and
    raw_material_4_count >= 1
    [
      set ppe_stock (ppe_stock + ppe_random)
      set raw_material_1_count ( raw_material_1_count - 1 )
      set raw_material_2_count ( raw_material_2_count - 1 )
      set raw_material_3_count ( raw_material_3_count - 1 )
      set raw_material_4_count ( raw_material_4_count - 1 )
    ]

    if ; Create a mask
    raw_material_1_count >= 1 and
    raw_material_2_count >= 1 and
    raw_material_3_count >= 1 and
    raw_material_4_count >= 1
    [
      set mask_stock (mask_stock + mask_random)
      set raw_material_1_count ( raw_material_1_count - 1 )
      set raw_material_2_count ( raw_material_2_count - 1 )
      set raw_material_3_count ( raw_material_3_count - 1 )
      set raw_material_4_count ( raw_material_4_count - 1 )
    ]


    if ; Create a syringe
    raw_material_1_count >= 1 and
    raw_material_2_count >= 1 and
    raw_material_3_count >= 1 and
    raw_material_4_count >= 1
    [
      set syringe_stock (syringe_stock + syringe_random)
      set raw_material_1_count ( raw_material_1_count - 1 )
      set raw_material_2_count ( raw_material_2_count - 1 )
      set raw_material_3_count ( raw_material_3_count - 1 )
      set raw_material_4_count ( raw_material_4_count - 1 )
    ]

    ; If the current count is greater than manufacturer-product-capacity, then limit products to the capacity
    if glove_stock > manufacturer-product-capacity [set glove_stock manufacturer-product-capacity]
    if ppe_stock > manufacturer-product-capacity [set ppe_stock manufacturer-product-capacity]
    if mask_stock > manufacturer-product-capacity [set mask_stock manufacturer-product-capacity]
    if syringe_stock > manufacturer-product-capacity [set syringe_stock manufacturer-product-capacity]

  ]

end

; decrement ppe on every fixed interval
; decrement gloves on every fixed interval, but lower interval than ppe
to hospital-decrement-ppe foreach sort hospitals [h ->
  ; fixed interval
  if ticks mod 47 = 0
  [
    ask h
    [
      print "decrementing ppe and glove stock"
      ; randomize the 0.25 multiplier
      set ppe_stock (ppe_stock - patient-capacity * 0.25)
      set glove_stock (ppe_stock - patient-capacity * 0.25)
    ]
  ]
]
end


to discharge
  set cured-patients cured-patients + 1
end

; function to kill a patient if health reaches 0
to death
  if health < 0 [
    ; count patients that died with color black
    set color black
    set dead-patients dead-patients + 1
    die
  ]

  ; here add a monitor based on the number of people that died
end

; Function at each time step (tick)
to go

  if ticks = 10000 [ stop ]
  ; Extractor procedure
  extract

  ; Extractor Transporter procedures
  extractor-transport

  ; Manufacturer procedures
  manufacture

  ; Hospital Transporter procedures
  hospital-transport

  ; Patient procedures
  patient-move
  spawn-patient
  hospital-decrement-ppe
  tick

end
@#$#@#$#@
GRAPHICS-WINDOW
507
28
1298
486
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
509
496
573
529
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

SLIDER
10
77
230
110
transporter-multiplier
transporter-multiplier
1
10
2.0
1
1
NIL
HORIZONTAL

TEXTBOX
130
60
231
78
will be multiplied to 2
11
0.0
1

SLIDER
10
176
230
209
extractor-capacity
extractor-capacity
100
1000
100.0
100
1
per item
HORIZONTAL

SLIDER
10
215
230
248
extraction-rate-prob
extraction-rate-prob
2
100
10.0
1
1
per item
HORIZONTAL

TEXTBOX
15
160
165
178
Extractor variables
11
0.0
1

SLIDER
264
25
493
58
manufacturer-product-capacity
manufacturer-product-capacity
100
5000
2300.0
100
1
items
HORIZONTAL

SLIDER
266
113
494
146
manufacture-rate
manufacture-rate
10
200
20.0
10
1
items per tick
HORIZONTAL

TEXTBOX
265
10
415
28
Manufacturer variables
11
0.0
1

SLIDER
9
275
229
308
patient-capacity
patient-capacity
10
200
20.0
10
1
patients
HORIZONTAL

SLIDER
9
363
232
396
ppe-capacity
ppe-capacity
100
1000
500.0
100
1
PPEs
HORIZONTAL

SLIDER
12
406
232
439
mask-capacity
mask-capacity
100
5000
1300.0
100
1
masks
HORIZONTAL

SLIDER
9
320
233
353
glove-capacity
glove-capacity
100
1000
500.0
100
1
gloves
HORIZONTAL

SLIDER
11
449
232
482
syringe-capacity
syringe-capacity
100
1000
200.0
100
1
syringes
HORIZONTAL

TEXTBOX
15
257
165
275
Hospital variables
11
0.0
1

TEXTBOX
10
10
160
28
Transporter variables
11
0.0
1

SLIDER
10
26
230
59
load-capacity
load-capacity
100
1000
300.0
100
1
per item
HORIZONTAL

TEXTBOX
266
159
416
177
Patient variables
11
0.0
1

SLIDER
264
182
493
215
initial-health
initial-health
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
1515
27
1643
72
mask stock of hosp 4
[mask_stock] of hospital 4
17
1
11

MONITOR
1649
28
1771
73
syringe stock of hosp 4
[syringe_stock] of hospital 4
17
1
11

MONITOR
1304
79
1383
124
gloves hosp 5
[glove_stock] of hospital 5
17
1
11

MONITOR
1388
78
1509
123
ppe stock of hosp 5
[ppe_stock] of hospital 5
17
1
11

MONITOR
1516
80
1644
125
mask stock of hosp 5
[mask_stock] of hospital 5
17
1
11

MONITOR
1650
80
1772
125
syringe hosp 5
[syringe_stock] of hospital 5
17
1
11

SLIDER
265
71
493
104
manufacturer-raw-capacity
manufacturer-raw-capacity
100
1000
500.0
100
1
NIL
HORIZONTAL

PLOT
1305
388
1543
508
Hospital 1 Stocks
time
stocks
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Gloves" 1.0 0 -11053225 true "" "plot [glove_stock] of hospital 4"
"PPE" 1.0 0 -11221820 true "" "plot [ppe_stock] of hospital 4"
"Mask" 1.0 0 -2674135 true "" "plot [mask_stock] of hospital 4"
"Syringe" 1.0 0 -7171555 true "" "plot [syringe_stock] of hospital 4"

MONITOR
1304
28
1384
73
gloves hosp 4
[glove_stock] of hospital 4
17
1
11

MONITOR
1390
27
1509
72
ppe stocks of hosp 4
[ ppe_stock ] of hospital 4
17
1
11

PLOT
1547
388
1784
508
Hospital 2 Stocks
time
stocks
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Gloves" 1.0 0 -11053225 true "" "plot [glove_stock] of hospital 5"
"PPE" 1.0 0 -11221820 true "" "plot [ppe_stock] of hospital 5"
"Mask" 1.0 0 -2674135 true "" "plot [mask_stock] of hospital 5"
"Syrine" 1.0 0 -7171555 true "" "plot [syringe_stock] of hospital 5"

PLOT
1305
259
1543
381
Manufacturer 1 Stocks
time
stocks
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Gloves" 1.0 0 -11053225 true "" "plot [glove_stock] of factory 2"
"PPE" 1.0 0 -11221820 true "" "plot [ppe_stock] of factory 2"
"Mask" 1.0 0 -2674135 true "" "plot [mask_stock] of factory 2"
"Syringe" 1.0 0 -7171555 true "" "plot [syringe_stock] of factory 2"

PLOT
1547
258
1786
380
Manufacturer 2 Stocks
time
stocks
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Gloves" 1.0 0 -11053225 true "" "plot [glove_stock] of factory 3"
"PPE" 1.0 0 -11221820 true "" "plot [ppe_stock] of factory 3"
"Mask" 1.0 0 -2674135 true "" "plot [mask_stock] of factory 3"
"Syringe" 1.0 0 -7171555 true "" "plot [syringe_stock] of factory 3"

PLOT
1305
131
1543
252
Extractor 1 Materials
time
count
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Raw 1" 1.0 0 -11053225 true "" "plot [raw_material_1_count] of extractor 0"
"Raw 2" 1.0 0 -11221820 true "" "plot [raw_material_2_count] of extractor 0"
"Raw 3" 1.0 0 -2674135 true "" "plot [raw_material_3_count] of extractor 0"
"Raw 4" 1.0 0 -7171555 true "" "plot [raw_material_4_count] of extractor 0"

PLOT
1546
131
1782
252
Extractor 2 Materials
time
count
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Raw 1" 1.0 0 -11053225 true "" "plot [raw_material_1_count] of extractor 1"
"Raw 2" 1.0 0 -11221820 true "" "plot [raw_material_2_count] of extractor 1"
"Raw 3" 1.0 0 -2674135 true "" "plot [raw_material_3_count] of extractor 1"
"Raw 4" 1.0 0 -7171555 true "" "plot [raw_material_4_count] of extractor 1"

PLOT
1305
516
1783
666
Patient Mortality Rate
time
mortality rate
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Dead" 1.0 0 -16777216 true "" "plot dead-patients"
"Discharged" 1.0 0 -14439633 true "" "plot cured-patients"

SLIDER
10
121
230
154
reroute-threshold
reroute-threshold
0
1
0.35
0.05
1
NIL
HORIZONTAL

MONITOR
713
573
837
618
Discharged Patients
cured-patients
17
1
11

MONITOR
714
624
837
669
Dead Patients
dead-patients
17
1
11

PLOT
896
516
1296
666
Patient Count
time
patient count
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Hospital 1" 1.0 0 -14439633 true "" "plot [patient_count] of hospital 4"
"Hospital 2" 1.0 0 -12345184 true "" "plot [patient_count] of hospital 5"

MONITOR
714
520
872
565
Total Patients Hospitalized
[patient_count] of hospital 4 + [patient_count] of hospital 5
17
1
11

SLIDER
264
223
492
256
initial-count
initial-count
0
100
70.0
1
1
patients
HORIZONTAL

BUTTON
585
496
648
529
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

@#$#@#$#@
## WHAT IS IT?

A supply chain is a network of entities that collaborate to generate goods or services from a set of basic materials and distribute them to a client or consumer. In essence, a supply chain is the entire process of generating a finished product and delivering it to a client. Obtaining raw resources, refining the materials, developing a product using the refined resources, and delivering the finished product to the consumer are all part of this process. 

## HOW IT WORKS

Extractors

Responsible for gathering raw materials from a certain place and delivering them to manufacturers via delivery vehicles. Move across the grid in search of an extraction region. Extracts four raw materials at each time step, with the extraction rate varying with each step.

Manufacturers

Produces items for use in hospitals from raw materials extracted by extractors. Stationary in one grid location. They make the goods based on the materials that are available, the production pace, and the raw materials given by the transporters from the extractors at each time step. 

Hospitals

Provides medical care to patients by utilizing items designed by the producers. Stationary in one grid location. They treat patients at each time step using the products brought by the transporters from the manufacturers.  

Patients

People who require medical attention and are admitted to hospitals. In the supply chain, they are regarded as the final user of the finished product. When admitted, stationary agents are stationed within the hospital. They consume medical supplies to stay alive and are discharged from the hospital if a particular health criterion is met. Patients who are unable to be admitted due to the hospital's full capacity might try to visit other facilities to see if there is a free capacity where they can be admitted.

Transporters

Vehicles entrusted with transporting raw materials from Extractors to Manufacturers or from Manufacturers to Hospitals. There are two kinds of transporters: those for extractors and those for hospitals. They are initially based at the manufacturer's facility. They move and convey the load from extractors to manufacturers or manufacturers to hospitals at each time step.  

## HOW TO USE IT

Certain sliders must be set before proceeding. These variables dictate how many 'trucks' there are, the load capacity of each truck/transporter, and their reroute threshold for Transporters. A transporter with a higher load capacity can carry more things. Extractors must also have their maximum capacity and extraction rate adjusted. This influences the amount of raw materials they can collect and store on themselves per time step. The maximum capacity for medical equipment as well as the maximum number of patients that can be admitted must be configured. This will have an impact on how much medical equipment a hospital can handle as well as how patients interact with it. Maximum product and raw capacity of manufacturers must be configured. These are the maximum quantities of finished medical items and raw materials that they can hold at any given moment. Lower starting health indicates a more serious epidemic and will necessitate a lengthier hospital stay. A lower first [patient] count indicates that the illness is not prevalent at first.      

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

Consider the following scenario: a catastrophic epidemic with widespread infection.
It's worth noting that each simulation took 10000 time steps. 

Severe epidemic and widespread infection 
(initial-health = 30; initial-count = 90)

It is clear that as the number of patient deaths rises, so does the availability of masks (in red line). In this simulation, hospitals can only carry 1000 masks, which is insufficient to handle the enormous influx of patients. In this simulation, the other medical equipment is insignificant because only the mask supplies are directly related to the patient discharge/mortality rate.


If the hospital mask capacity is increased to, say, 2500, the results change dramatically. This is located in number two. 

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

square
false
0
Rectangle -7500403 true true 30 30 270 270

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
true
0
Rectangle -7500403 true true 45 105 187 296
Polygon -7500403 true true 193 4 150 4 134 41 104 56 104 92 194 93
Rectangle -1 true false 60 105 105 105
Polygon -16777216 true false 112 62 141 48 141 81 112 82
Circle -16777216 true false 174 24 42
Rectangle -7500403 true true 185 86 194 119
Circle -16777216 true false 174 114 42
Circle -16777216 true false 174 234 42
Circle -7500403 false true 174 234 42
Circle -7500403 false true 174 114 42
Circle -7500403 false true 174 24 42
@#$#@#$#@
NetLogo 6.1.1
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
