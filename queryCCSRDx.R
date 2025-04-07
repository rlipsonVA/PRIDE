
 
  codeString <- paste0('icd10code in (', paste0("'", icdCodes, "'", collapse = ","), ')')
  

  inpat <- 
  con() |> dbSendQuery(sql(glue(
    "
    select
       icn.PatientICN 
      , cast(inpat.AdmitDateTime as date) as DxDate 

      , dx.icd10sid 
      , icd10code 
      , icd10description 
      
    from Src.Inpat_InpatientDiagnosis dx
    inner join Src.Inpat_Inpatient inpat
    on dx.InpatientSID = inpat.InpatientSID

    inner join Src.SPatient_SPatient icn
    on dx.PatientSID = icn.PatientSID 
    
    inner join 
    (
      select a.icd10code, a.icd10sid, b.icd10description 
      from cdwwork.dim.icd10 a
      inner join cdwwork.dim.icd10descriptionversion b on a.icd10sid = b.icd10sid 
      where a.icd10sid > 1 and ({codeString})                                         
    ) icd10
    
    on dx.icd10sid = icd10.icd10sid 
    
    where
      (AdmitDateTime >= convert(datetime2(0), '{beginDate}') and AdmitDateTime <= convert(datetime2(0), '{endDate}'))
    "
      ))) |> dbFetch()

  # :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  # :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  outpat <- 
  con() |> dbSendQuery(sql(glue(
    "
    select  
      -- dx.VDiagnosisSID
      -- dx.PatientSID
        icn.PatientICN
      , cast(dx.VisitDateTime as date) as DxDate 

      , dx.icd10sid 
      , icd10code 
      , icd10description 
      
    from Src.Outpat_VDiagnosis dx
    inner join  Src.SPatient_SPatient icn on dx.PatientSID = icn.PatientSID 
    
    inner join 
    (
      select a.icd10code, a.icd10sid, b.icd10description 
      from cdwwork.dim.icd10 a
      inner join cdwwork.dim.icd10descriptionversion b on a.icd10sid = b.icd10sid 
      where a.icd10sid > 1 and ({codeString})                                      
    ) icd10 on dx.icd10sid = icd10.icd10sid 
    
    where 
      (VisitDateTime >= convert(datetime2(0), '{beginDate}') and VisitDateTime <= convert(datetime2(0), '{endDate}'))
    "
      ))) |> dbFetch()


  
  inpat |> mutate(src = 'in') |> distinct() |> 
    bind_rows(outpat |> mutate(src = 'out') |> distinct()) 
  
  
  