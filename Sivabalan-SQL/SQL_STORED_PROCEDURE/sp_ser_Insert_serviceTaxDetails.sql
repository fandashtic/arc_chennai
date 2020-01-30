CREATE Procedure sp_ser_Insert_serviceTaxDetails (@ServiceTaxCode int,       
     @ServiceTaxComp_Code int,       
     @ServiceTaxComp_Desc nvarchar(255),       
     @TaxPer decimal(18,6),       
     @ApplicableOn nvarchar(255),       
     @TaskRate_Per decimal(18,6))    
As      
      
If @ServiceTaxComp_Code = 0       
Begin      
    Insert into servicetaxcomponentdetail values(@ServiceTaxComp_Desc)       
    Select @ServiceTaxComp_Code = ServiceTaxComponent_Code from servicetaxcomponentdetail where servicetaxcomponent_Code = @@Identity      
End      
      
Insert into serviceTaxComponents (serviceTaxCode,      
   servicetaxComponent_code,      
   tax_percentage,      
   ApplicableOn,      
   taskrate_Percentage)    
Values (@serviceTaxCode,       
 @serviceTaxComp_Code,       
 @TaxPer,       
 @ApplicableOn,       
 @taskrate_Per)    

