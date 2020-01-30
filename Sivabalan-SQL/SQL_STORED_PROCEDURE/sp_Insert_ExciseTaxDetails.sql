CREATE Procedure sp_Insert_ExciseTaxDetails (@TaxCode int,       
     @TaxComp_Code int,       
     @TaxComp_Desc nvarchar(255),       
     @TaxPer decimal(18,6),       
     @ApplicableOn nvarchar(255),       
     @Sp_Per decimal(18,6),  
     @Part_Of_Percent Decimal(18,6))    
As      
      
If @TaxComp_Code = 0       
Begin      
    Insert into ExciseTaxComponentDetail values(@TaxComp_Desc)       
    Select @TaxComp_Code = TaxComponent_Code from ExciseTaxComponentDetail where TaxComponent_Code = @@Identity      
End      
      
Insert into ExciseTaxComponents (Tax_Code,      
   TaxComponent_Code,      
   Tax_Percentage,      
   ApplicableOn,      
   Sp_Percentage,  
   PartOf)    
Values (@TaxCode,       
 @TaxComp_Code,       
 @TaxPer,       
 @ApplicableOn,       
 @Sp_Per,  
 @Part_Of_Percent)



