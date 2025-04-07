

  steroids_to_exclude <- read.csv(
    'P:/ORD_Waljee_202107017D/PRIDE1819/Data/DataCleaned/steroids to exclude.csv')
  names(steroids_to_exclude) <- "LocalDrugNameWithDose" 
  
  steroids_to_exclude <- steroids_to_exclude |> 
    mutate(rx_name = tolower(LocalDrugNameWithDose))     

  setDT(steroids_to_exclude)
  
  # HS051
  setDT(rxoutHS051Steroids) 
  rxoutHS051Steroids[, DispensedDate   := as.Date(DispensedDate)] 
  rxoutHS051Steroids[, ReleaseDateTime := as.Date(ReleaseDateTime)] 
  rxoutHS051Steroids[, IssueDate       := as.Date(IssueDate)] 

  rxoutHS051Steroids[, rx_date := as.IDate(fcoalesce(DispensedDate, ReleaseDateTime, IssueDate))]  
  rxoutHS051Steroids[, rx_year := year(rx_date)]
  rxoutHS051Steroids[, rx_name := tolower(LocalDrugNameWithDose)]     #   
  steroids2021 <- rxoutHS051Steroids[rx_year %in% 2021:2022, ]        # 

  # * exclude non-oral  --------------------------------------------------------------
  steroidsCleaning <- steroids2021[!steroids_to_exclude, on = 'rx_name']   #

  # * add dose ----------------------------------------------------------------------------
  steroidsCleaning[, dose := as.numeric(str_match(pattern='(\\d+\\.?\\d*)\\s?mg', string=rx_name)[,2])]

  # * is pack? ---------------------------------------------------------------------
  steroidsCleaning[, is_pack := grepl(pattern='(dose.?)?pac?k', rx_name)]

  # * steroids type -------------------------------------------------------------------------
  # Remember we exclude BUDESONIDE 
  steroidsCleaning[,   
    steroids_type := str_extract(
      rx_name, 
      pattern = glue_collapse(c(
        'methylprednisolone', 'prednisone', 'prednisolone', 'hydrocortisone', 'cortisone',
        'betamethasone', 'dexamethasone', 'triamcinolone'), sep = '|')
    )][order(steroids_type, rx_year)]

  #  ** dosepack convert -----------------------------------------------
  
  # type of dosepack                            # IN-PLACE UPDATES 
  steroidsCleaning[steroids_type == 'methylprednisolone' & is_pack == TRUE, steroids_type := 'prednisone']
  
  # small dose 
  steroidsCleaning[dose <= 4 & is_pack == TRUE, dose := 5L]

  # days supply
  steroidsCleaning[QtyNumeric %in% c(1, 21, 30) & is_pack == TRUE, DaysSupply := 6L          ]
  steroidsCleaning[QtyNumeric >= 6 & is_pack == TRUE             , DaysSupply := 6*QtyNumeric]

  # * excludes budesonide --------------------------------------------------------------
  steroidsCleaned <- steroidsCleaning[!is.na(steroids_type)]  


