
  steroidPrescribers |> mutate(
    
      NpiPrimaryProviderGroupType = case_when(
        
        !is.na(primarySpecialization) & 
          primarySpecializationGroup != 'Cannot be grouped using specialization; look at classification' 
            ~ primarySpecializationGroup,
        
        # Unable to classify ->  NA  
        primaryClassificationGroup == 'Unable to classify' ~ NA_character_, 
        
        # then use class 
        is.na(primarySpecialization) |
          primarySpecializationGroup == 'Cannot be grouped using specialization; look at classification'
            ~ primaryClassificationGroup,
        
        TRUE ~ NA_character_)
      
      ,
      
      NpiSecondaryProviderGroupType = case_when(
        
        !is.na(secondarySpecialization) & 
          secondarySpecializationGroup != 'Cannot be grouped using specialization; look at classification' 
            ~ secondarySpecializationGroup,
        
        # Unable to classify ->  NA 
        secondaryClassificationGroup == 'Unable to classify' ~ NA_character_, 
        
        # then use class 
        is.na(secondarySpecialization) |
          secondarySpecializationGroup == 'Cannot be grouped using specialization; look at classification'
            ~ secondaryClassificationGroup,
        
        TRUE ~ NA_character_))
  

                                            
                                                      
                                                      
                                                      