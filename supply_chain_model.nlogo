; Initialize globals
globals[
  roads
  first-ex-patches
  second-ex-patches
  extractor-pick-ups
  manufacturer-drop-offs
  hospital-drop-offs
  intersections
]

; Initialize the breeds
breed [extractors extractor]
breed [manufacturers factory]
breed [hospitals hospital]
breed [patients patient]
breed [extr-transporters ex-truck]
breed [hosp-transporters hs-truck]

; Initialize internal values per breed
extr-transporters-own[
  delivery_speed
  raw_material_1_count
  raw_material_2_count
  raw_material_3_count
  raw_material_4_count
  start_patch
  destination
]
hosp-transporters-own[
  delivery_speed
  glove_stock
  ppe_stock
  mask_stock
  syringe_stock
  start_patch
  destination
]
extractors-own[
  extractor_capacity
  raw_material_1_count
  raw_material_2_count
  raw_material_3_count
  raw_material_4_count
]
manufacturers-own[
  warehouse_capacity
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
  ]
  create-manufacturers 2[
    set size 12
    set color brown
    set warehouse_capacity manufacturer-capacity
  ]
  create-hospitals 2 [
    set size 12
    set color gray
    set patient_count 0
    set glove_capacity glove-capacity
    set ppe_capacity ppe-capacity
    set mask_capacity mask-capacity
    set syringe_capacity syringe-capacity
  ]

   create-patients 100 [
    set size 1
    set color orange
    set health initial-health
  ]

  create-extr-transporters (transporter-multiplier * 2)[
    set size  2
    set color red
  ]

  create-hosp-transporters (transporter-multiplier * 2)[
    set size  2
    set color blue
  ]

end

; Places each non-moving breed in the grid
to setup-positions

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
        set destination patch 21 3
      ]
      [
        set destination patch 21 -13
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

; Patients to move
to patient-move foreach sort patients [p ->

  ask p [

    ifelse (patch-here = destination)
    [

        set shape "circle"
        set color orange
        hide-turtle
        let hosp_number 0
        ifelse [pycor] of patch-here = 3
        [
          set hosp_number 4
        ]
        [
          set hosp_number 5
        ]

        ; increment patient count in the hospital if the patient is already in the hospital
        ask hospital hosp_number
        [
          ; if there is a slot in the current hospital, admit self
          ifelse ((patient_count + 1) <= patient-capacity)
          [

            if(glove_stock > 0 and ppe_stock > 0 and mask_stock > 0 and syringe_stock > 0)
            [
              set patient_count (patient_count + 1)
              ask p
              [
                set color green
                ask hospital hosp_number
                [
                  set glove_stock glove_stock - 1
                  set ppe_stock ppe_stock - 1
                  set mask_stock mask_stock - 1
                  set syringe_stock syringe_stock - 1
                ]
            ]
          ]

          ]
          [
            ; else reroute the patient to another hospital
            ask p
            [
              ; only reroute the unhealthy patients
              if(color != green)
              [
                ifelse (one-of hospitals with [patient_count < patient-capacity] = nobody)
                [
                  set health (health - 1)
                  death
                ]
                [
                  ; set destination [patch xcor ycor] of one-of hospitals with [patient_count < patient-capacity]
                  ; set heading towards one-of hospitals-on destination

                ; Change the start_patch and destination
                ; To be used for rotation when rerouting
                ifelse [pycor] of patch-here = 3
                [
                  set start_patch patch 30 3
                  set destination patch 20 -13
                ]
                [
                  set start_patch patch 30 -13
                  set destination patch 20 3
                ]
                ; Set different visuals to discern
                ; if the patient is rerouting
                  show-turtle
                  set color red
                  set shape "square"
                  rt 180
                  ; add the chance that the patient will die in transport
                  set health (health - 1)
                  death
                  forward 1

                ]
              ]
            ]
          ]

        ]

      ; coin-flip if the patient will get healthy or not
      if coin-flip?
      [
        ; not green = not healthy
        if (color != green)
        [
          set health (health - 1)
          death
        ]

      ]

    ]

    [
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

; Discharge if a patient is in the hospital
to discharge-patients foreach sort patients [p ->
  ask p [

    if (patch-here = destination) [

      let hosp_number 0
        ifelse [pycor] of patch-here = 3
        [
          set hosp_number 4
        ]
        [
          set hosp_number 5
        ]
        ask p
        [
          set health health + 1
          if (health >= 90)
          [
            die
            ask hospital hosp_number
            [
              set patient_count (patient_count - 1)
            ]
          ]

        ]

       if (color = green)
        [

          ; hide
        ]
    ]
  ]
]
end

; Admit a patient in the hospital if outside
to admit-patient
  if patient_count < patient-capacity
  [
    set patient_count patient_count + 1
    ; how to stop patients from moving if ever while "getting treated" (?)
  ]
end

; Creates a patient in near the hospitals
to spawn-patient

  if coin-flip?
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
      ; If the the transporter is a horizontal road
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
          x_dest = 21 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
          x_dest = 21 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt -90
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
            rt -90
          ]
          x_dest = 1 and y_cur = -13 ; Going to a manufacturer on the upper lane
          [
            rt 90
          ]
          x_dest = 21 and y_cur = 3 ; Going to an extractor on the lower lane
          [
            rt 90
          ]
          x_dest = 21 and y_cur = -13 ; Going to an extractor on the lower lane
          [
            rt -90
          ]
        )
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

      ; Switch start patch and destination patch
      let temp_dest (destination)
      set destination (start_patch)
      set start_patch (temp_dest)

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
            ifelse ( raw_mat1_to_give + cur_raw_mat1 ) <= manufacturer-capacity
            [
              set raw_material_1_count ( raw_mat1_to_give + cur_raw_mat1 ) ; add raw material, limit is the manufacturer capacity
              set raw_mat1_to_give 0
            ]
            [
              set raw_material_1_count manufacturer-capacity ; considered as full
              set raw_mat1_to_give ( raw_mat1_to_give - ( manufacturer-capacity - cur_raw_mat1 ) )
            ]

            ;;;;;;;;;;;;;;;;;;;;
            ;; Raw Material 2 ;;
            ;;;;;;;;;;;;;;;;;;;;
            ifelse ( raw_mat2_to_give + cur_raw_mat2 ) <= manufacturer-capacity
            [
              set raw_material_2_count ( raw_mat2_to_give + cur_raw_mat2 ) ; add raw material, limit is the manufacturer capacity
              set raw_mat2_to_give 0
            ]
            [
              set raw_material_2_count manufacturer-capacity ; considered as full
              set raw_mat2_to_give ( raw_mat2_to_give - ( manufacturer-capacity - cur_raw_mat2 ) )
            ]

            ;;;;;;;;;;;;;;;;;;;;
            ;; Raw Material 3 ;;
            ;;;;;;;;;;;;;;;;;;;;
            ifelse ( raw_mat3_to_give + cur_raw_mat3 ) <= manufacturer-capacity
            [
              set raw_material_3_count ( raw_mat3_to_give + cur_raw_mat3 ) ; add raw material, limit is the manufacturer capacity
              set raw_mat3_to_give 0
            ]
            [
              set raw_material_3_count manufacturer-capacity ; considered as full
              set raw_mat3_to_give ( raw_mat3_to_give - ( manufacturer-capacity - cur_raw_mat3 ) )
            ]

            ;;;;;;;;;;;;;;;;;;;;
            ;; Raw Material 4 ;;
            ;;;;;;;;;;;;;;;;;;;;
            ifelse ( raw_mat4_to_give + cur_raw_mat4 ) <= manufacturer-capacity
            [
              set raw_material_4_count ( raw_mat4_to_give + cur_raw_mat4 ) ; add raw material, limit is the manufacturer capacity
              set raw_mat4_to_give 0
            ]
            [
              set raw_material_4_count manufacturer-capacity ; considered as full
              set raw_mat4_to_give ( raw_mat4_to_give - ( manufacturer-capacity - cur_raw_mat4 ) )
            ]

          ]

          ; raw_mat_to_give becomes the remaining
          ; raw material of the transporter
          set raw_material_1_count (raw_mat1_to_give)
          set raw_material_2_count (raw_mat2_to_give)
          set raw_material_3_count (raw_mat3_to_give)
          set raw_material_4_count (raw_mat4_to_give)

        ]

      )

      ; Rotate to go back
      rt 180

    ]

    ; Rotate if in an intersection
    rotate-ext-transporters

    forward 1
    display
  ]

end

; Allows the hospital transporters to move
to hospital-transport ; hospital transporter procedure

  ; Transports the manufactured goods to the hospitals
  ask hosp-transporters[

    if (patch-here = destination) [

      ; Switch start patch and destination patch
      let temp_dest (destination)
      set destination (start_patch)
      set start_patch (temp_dest)

      ; Place current stock per item
      ; in a temporary variable
      let cur_glove_stock   glove_stock
      let cur_ppe_stock     ppe_stock
      let cur_mask_stock    mask_stock
      let cur_syringe_stock  syringe_stock

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

        ]

        ; Check if y-coordinate is 3 (upper manufacturer)
        ; or -13 (lower manufacturer)
        (member? patch-here manufacturer-drop-offs)
        [
          let manuf_number 0
          ifelse [pycor] of patch-here = 3
          [ set manuf_number 2 ]
          [ set manuf_number 3 ]

          ask factory manuf_number [

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
              set cur_glove_stock ( cur_glove_stock + ( load-capacity - cur_glove_stock ) )
              set glove_stock ( glove_stock - ( load-capacity - cur_glove_stock ) )
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
              set cur_ppe_stock ( cur_ppe_stock + ( load-capacity - cur_ppe_stock ) )
              set ppe_stock ( ppe_stock - ( load-capacity - cur_ppe_stock ) )
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
              set cur_mask_stock ( cur_mask_stock + ( load-capacity - cur_mask_stock ) )
              set mask_stock ( mask_stock - ( load-capacity - cur_mask_stock ) )
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
              set cur_syringe_stock ( cur_syringe_stock + ( load-capacity - cur_syringe_stock ) )
              set syringe_stock ( syringe_stock - ( load-capacity - cur_syringe_stock ) )
            ]

          ]

          ; The "cur" variables are now the
          ; actual current stock per item
          set glove_stock    (cur_glove_stock)
          set ppe_stock      (cur_ppe_stock)
          set mask_stock     (cur_mask_stock)
          set syringe_stock  (cur_syringe_stock)

        ]

      )


      ; Rotate to go back
      rt 180

    ]

    rotate-hosp-transporters
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

  ; Not yet using manufacturing rate
  ; Also used random counts for creating a product

  ask manufacturers
  [

    if ; Create a pair of gloves
    raw_material_1_count >= 5 and
    raw_material_2_count >= 1 and
    raw_material_3_count >= 2 and
    raw_material_4_count >= 4
    [
      set glove_stock (glove_stock + 1)
      set raw_material_1_count ( raw_material_1_count - 5 )
      set raw_material_2_count ( raw_material_2_count - 1 )
      set raw_material_3_count ( raw_material_3_count - 2 )
      set raw_material_4_count ( raw_material_4_count - 4 )
    ]

    if ; Create a PPE
    raw_material_1_count >= 5 and
    raw_material_2_count >= 5 and
    raw_material_3_count >= 5 and
    raw_material_4_count >= 2
    [
      set ppe_stock (ppe_stock + 1)
      set raw_material_1_count ( raw_material_1_count - 5 )
      set raw_material_2_count ( raw_material_2_count - 5 )
      set raw_material_3_count ( raw_material_3_count - 5 )
      set raw_material_4_count ( raw_material_4_count - 2 )
    ]

    if ; Create a mask
    raw_material_1_count >= 2 and
    raw_material_2_count >= 2 and
    raw_material_3_count >= 5 and
    raw_material_4_count >= 2
    [
      set mask_stock (ppe_stock + 1)
      set raw_material_1_count ( raw_material_1_count - 2 )
      set raw_material_2_count ( raw_material_2_count - 2 )
      set raw_material_3_count ( raw_material_3_count - 5 )
      set raw_material_4_count ( raw_material_4_count - 2 )
    ]


    if ; Create a syringe
    raw_material_1_count >= 1 and
    raw_material_2_count >= 5 and
    raw_material_3_count >= 5 and
    raw_material_4_count >= 1
    [
      set syringe_stock (syringe_stock + 1)
      set raw_material_1_count ( raw_material_1_count - 1 )
      set raw_material_2_count ( raw_material_2_count - 5 )
      set raw_material_3_count ( raw_material_3_count - 5 )
      set raw_material_4_count ( raw_material_4_count - 1 )
    ]

  ]

end

; function to kill a patient if health reaches 0
to death
  if health < 0 [
    set color black
    die
  ]

  ; here add a monitor based on the number of people that died
end

; Function at each time step (tick)
to go

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
  discharge-patients

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
363
442
427
475
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
1.0
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
142
230
175
extractor-capacity
extractor-capacity
10
100
100.0
1
1
per item
HORIZONTAL

SLIDER
10
181
230
214
extraction-rate-prob
extraction-rate-prob
2
10
6.0
1
1
per item
HORIZONTAL

TEXTBOX
15
126
165
144
Extractor variables
11
0.0
1

SLIDER
264
25
484
58
manufacturer-capacity
manufacturer-capacity
10
100
100.0
1
1
items
HORIZONTAL

SLIDER
264
76
484
109
manufacture-rate
manufacture-rate
1
100
25.0
1
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
10
241
230
274
patient-capacity
patient-capacity
10
100
20.0
1
1
patients
HORIZONTAL

SLIDER
1050
527
1273
560
admission-rate
admission-rate
10
100
19.0
1
1
patients per tick
HORIZONTAL

SLIDER
1051
564
1274
597
release-rate
release-rate
0
100
37.0
1
1
patients per tick
HORIZONTAL

SLIDER
8
369
231
402
ppe-capacity
ppe-capacity
0
100
10.0
1
1
PPEs
HORIZONTAL

SLIDER
10
285
230
318
mask-capacity
mask-capacity
0
100
10.0
1
1
masks
HORIZONTAL

SLIDER
8
411
232
444
glove-capacity
glove-capacity
0
100
10.0
1
1
gloves
HORIZONTAL

SLIDER
9
327
230
360
syringe-capacity
syringe-capacity
0
100
11.0
1
1
syringes
HORIZONTAL

TEXTBOX
15
223
165
241
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
1
100
50.0
1
1
per item
HORIZONTAL

TEXTBOX
901
560
1051
578
Just for later (if ever)
11
15.0
1

TEXTBOX
265
126
415
144
Patient variables
11
0.0
1

SLIDER
263
141
484
174
initial-health
initial-health
0
100
83.0
1
1
NIL
HORIZONTAL

BUTTON
447
443
510
476
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
