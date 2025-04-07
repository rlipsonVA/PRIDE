

  # 1. Inclusions ---------------------------------------
  # * Vets (>= 18) 
  # * with PCP 21-22 
  # * AND did NOT go Millennium 
  # * and RX 21-22 
  coh1 <- demogsVeterans[criterionsVeterans, on = 'PatientICN'][age18 & PCP & !Millennium & RX, ]   # 5,361,257   
  
  # 2. Steroids ----------------------------------------------------------------------------------
  # And add steroid variables 
  coh2 <- steroidsVeterans[, .(PatientICN, GCUser, ProlongedGC)
                          ][coh1, on = 'PatientICN'
                          ][, .(PatientICN, Sta3n, GCUser, ProlongedGC,
                                Race = selfIDRace, sex, dob, dod, age2021)]  
  
  # 3. DXs ------------------------------------------------------------------------
  coh3 <- coh2 |> 
    left_join(ptDx, by = 'PatientICN')
  
  # 4. Encounter measures ---------------------------------------------------------
  coh4 <- measuresVeterans[coh3, on = 'PatientICN'
                          ][, N_visits     := NULL
                          ][, LastOutVisit := NULL] 
  
  # Race cat ----------------------------------------------------------------------
  coh4[, Race5 := case_when(
          Race == 'WHITE' ~ '1. White',
          Race == 'BLACK' ~ '2. Black',
          Race == 'ASIAN' ~ '3. Asian',
          is.na(Race)     ~ '5. Missing',
          TRUE            ~ '4. Other')]
  
  # Age cat -----------------------------------------------------------------------
  coh4[, age2021 := round(age2021)]
  coh4[, AgeCat := case_when(
            age2021 >= 18 & age2021 <= 35 ~ '18 - 35' 
          , age2021 >= 36 & age2021 <= 45 ~ '36 - 45' 
          , age2021 >= 46 & age2021 <= 55 ~ '46 - 55' 
          , age2021 >= 56 & age2021 <= 64 ~ '56 - 64' 
          , age2021 >= 65 & age2021 <= 74 ~ '65 - 74' 
          , age2021 >= 75                 ~ '75 +'    )]
        



