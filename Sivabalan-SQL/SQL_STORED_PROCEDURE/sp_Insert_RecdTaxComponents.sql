
Create Procedure [dbo].[sp_Insert_RecdTaxComponents] (
@TaxID int,
@CS_TaxCode int,
@CS_ComponentCode int,
@ComponentDescription nvarchar(255),
@ComponentType nvarchar(50),
@Rate decimal(18,6),
@ApplicableonComp nvarchar(50),
@ApplicableOnDesc nvarchar(50),
@ApplicableUOM nvarchar(50),
@PartOff Decimal(5,2),
@TaxType nvarchar(50),
@GSTComponent nvarchar(50),
@xmlDocNumber int,
@FirstPoint int,
@CS_RegisterStatus Int
)
As
Begin
Insert Into Recd_TaxComponents (TaxID,CS_TaxCode, CS_ComponentCode, ComponentDescription,ComponentType,Rate,
ApplicableonComp,ApplicableOnDesc,ApplicableUOM,PartOff,TaxType,GSTComponent,xmlDocNumber,FirstPoint,CS_RegisterStatus)
Values (@TaxID,@CS_TaxCode, @CS_ComponentCode, @ComponentDescription,@ComponentType,@Rate,
@ApplicableonComp,@ApplicableOnDesc,@ApplicableUOM,@PartOff,@TaxType,@GSTComponent,@xmlDocNumber,@FirstPoint,@CS_RegisterStatus)

End
