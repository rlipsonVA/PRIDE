
  qr <- glue(
    "
    select RxOutpatFillSID
      , icn.PatientICN
      , a.Sta3n
      , a.IssueDate
      , a.DispensedDate
      , a.ReleaseDateTime
      , a.Qty
      , a.QtyNumeric
      , a.DaysSupply
      
      , a.ProviderSID
      , o.OrderStaffSID 
      
      , a.LocalDrugSID
      , b.LocalDrugNameWithDose
      -- , b.DrugNameWithoutDose
     
      , b.BestDrugClass
      
      , c.DrugClassSID
      , c.DrugClassCode
      , c.DrugClassification 

    from Src.RxOut_RxOutpatFill a
    inner join Src.CohortCrosswalk icn on a.PatientSID = icn.PatientSID
    inner join Src.RxOut_RxOutpat r on a.RxOutpatSID = r.RxOutpatSID 
    left join Src.CPRSOrder_CPRSOrder o on o.CPRSOrderIEN=r.CPRSOrderEntryNumber and o.Sta3n=r.Sta3n
    
    left join (
        select 
          LocalDrugSID, 
          DrugClassSID, 
          LocalDrugNameWithDose,
          BestDrugClass  
        from cdwwork.dim.localdrug
        where LocalDrugSID > 1 
        
      ) b on a.LocalDrugSID = b.LocalDrugSID
    
    left join cdwwork.dim.drugclass c on b.DrugClassSID = c.DrugClassSID 

    where 
      c.DrugClassCode = 'HS051' and 
      
      ((a.IssueDate >= convert(datetime2(0), '{beginDate}')
          and a.IssueDate <= convert(datetime2(0), '{endDate}')) or 
              
      (a.ReleaseDateTime >= convert(datetime2(0), '{beginDate}')
        and a.ReleaseDateTime <= convert(datetime2(0), '{endDate}')) or 
              
      (a.DispensedDate >= convert(datetime2(0), '{beginDate}')
        and a.DispensedDate <= convert(datetime2(0), '{endDate}')))  
    
    ")
  
  con() |> dbSendQuery(sql(qr)) |> dbFetch() |> process()  



