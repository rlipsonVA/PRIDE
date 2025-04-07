

  analyticCohort <- readRDS("Data/analyticCohort") 

  data4Table <-
    analytic_cohort                                            |> 
    mutate(
      GRP = if_else(GCUser, "2. GC User", "4. GC non-users")) |>
    bind_rows(
      analytic_cohort         |>
      filter(ProlongedGC==1) |> 
      mutate(GRP = "3. Long-term GC users")) |>
    bind_rows(analytic_cohort |> mutate(GRP = "1. All Veterans"))

   catVars <-
    c(
      "GCUser", 
      "ProlongedGC",
      
      "AgeCat", 
      
      "Race5",
      "sex",
    
      "Acute Bronchitis",      
      "Arterial or venous thrombosis",             
      "Atherosclerotic cardiovascular disease",   
      "Bacterial infections",         
      "Asthma",
      "Cataracts and glaucoma",             
      "Cerebrovascular disease",            
      "COPD",   
      "COVID",
      "Diabetes.x",               
      "Crystal arthropathies",   
      "Fractures",       
      "Fungal infections",    
      "Gout", 
      "Immune-mediated conditions",    
      "Inflammatory skin conditions",  
      "Influenza",                
      "Malignancy",          
      "Malignancy excluding NMSC",    
      "Organ transplant",      
      "Osteoporosis",  
      "Pneumonia",                     
      "Sepsis",  
      "URIs",                                  
      "Viral infections"                  
    

    )
  

  myVars <- c('age2021', 'N_outpats_pyr', 'N_inpats_pyr'
              , 'N_steroid_rx_pyr', 'Charlson', c(catVars))
  
  tbl_summary(
    data4Table
    , include = all_of(myVars)
    , by      = GRP
    , statistic = list(
         N_outpats_pyr      ~ "{median} ({p25}, {p75})"
         , N_inpats_pyr     ~ "{median} ({p25}, {p75})"
         , N_steroid_rx_pyr ~ "{median} ({p25}, {p75})"
         , Charlson         ~ "{median} ({p25}, {p75})"
         ,age2021           ~ "{mean} ({sd})"   
        #all_continuous() ~ "{median} ({p25}, {p75})"
        ) 
    
    ) 




