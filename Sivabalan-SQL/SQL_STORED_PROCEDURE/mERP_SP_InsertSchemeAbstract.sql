Create Procedure mERP_SP_InsertSchemeAbstract
(
 @SchemeID nVarchar(255)=NULL,   
 @schActivityCode nVarchar(2000)=NULL,   
 @schDescription  nVarchar(4000)=NULL,   
 @Colour  nVarchar(100)=NULL,   
 @Schtype nVarchar(1000)=NULL,  
 @SchApplicableOn  nVarchar(100)=NULL,  
 @SchSKUGroup nVarchar(100)=NULL,  
 @RFAApplicable int=0,  
 @ClaimedAs nVarchar(1000)=NULL,  
 @SchMonth nVarchar(1000)=NULL,  
 @SchActiveFrom DateTime = NULL,  
 @SchActiveTo DateTime = NULL,  
 @LinesInBill int=1,    
 @nSchActive int=0, 
 @Budget decimal (18,6),
 @Status int=0,
 @SchExpiryDate DateTime = NULL,
 @PayoutFrequency nVarchar(1000)=NULL,  
 @BudgetOverRun int=0,
 @UniformAllocFlag int=0,
 @nSchPayoutPeriod nVarchar(4000)=NULL,
 @GraceDays int=0,
 @ViewDate DateTime = NULL,
 @SchSubType nVarchar(1000)=NULL,
 @SchCategory nvarchar(256) = NULL
)  
As  
Insert Into tbl_mERP_RecdSchAbstract(CS_RecSchID, CS_ActCode, CS_Description, CS_Color, CS_Type,   
 CS_ApplicableOn, CS_SKUGroup, CS_RFAApplicable, CS_ClaimedAs, CS_Month, CS_ActiveFrom, CS_ActiveTo,  
 CS_Active, CS_SKuCount, CS_Budget, CS_Status, CS_ExpiryDate, CS_PayoutFrequency, CS_BudgetOverRun, 
 CS_UniformAllocFlag, CS_PayoutPeriod, GraceDays, CS_ViewDate, CS_SchSubType, Category)  
  Values ( @SchemeID, @schActivityCode, @schDescription, @Colour, @Schtype, @SchApplicableOn, @SchSKUGroup,   
 @RFAApplicable, @ClaimedAs, @SchMonth, @SchActiveFrom, @SchActiveTo,  @nSchActive, @LinesInBill, @Budget, @status, @SchExpiryDate,
@PayoutFrequency, @BudgetOverRun, @UniformAllocFlag, @nSchPayoutPeriod, @GraceDays, @ViewDate, @SchSubType, @SchCategory)  
SELECT @@IDENTITY 

